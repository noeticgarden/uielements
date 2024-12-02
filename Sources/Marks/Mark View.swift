
#if canImport(SwiftUI)
import SwiftUI
import UIElements

/// A marks view displays one or more marks within its bounds.
///
/// To specify what to display in a marks view, use a ``Marks`` container. Add your own marks, or collect them from modifiers like ``ExperimentalViewMethods/marksContinuousHover(coordinateSpace:amongst:)-8m7gu`` or ``ExperimentalViewMethods/marksSpatialEvents(coordinateSpace:amongst:)``. Pass the result to the ``init(marks:)`` constructor of this view.
///
/// Marks are specified in the local coordinate system of this view. Use the UIElements module's `surround(_:)` modifier or a similar technique to place the view such that the coordinate system it uses concides with the elements you want to highlight.
///
/// All marks are specified with 3D coordinates. If the marks view is displayed with depth, it will display its subviews offset the Z axis appropriately. Otherwise, the marks are layered in Z axis order, but will be displayed flat on the view. Note that this can occur on visionOS if you explicitly set the depth of this view to zero.
///
/// You can animate the state of the ``Marks`` container; use a [`withAnimation(_:_:)`](https://developer.apple.com/documentation/swiftui/withanimation(_:_:)) call or an appropriate binding when setting the container.
///
/// Each mark will be given a color that will persist for as long as a mark with that identifier is provided to the view. If you update the view to remove the identifier, the color will be reset.
public struct MarksView: View {
    let marks: Marks
    @State var drawingCache = MarksDrawingCache()
    
    /// Creates a marks view that displays the specified marks.
    ///
    /// To edit the marks that will be displayed, change the ``Marks`` container you are passing in, and make sure the change updates the view. You can make this happen by making the ``Marks`` container a `@State` value, or by placing it in an appropriate property of an `Observable` model; or by specifying the marks container in the body of your view.
    ///
    /// For example:
    ///
    /// ```swift
    /// struct MyView {
    ///     @State var marks = Marks()
    ///
    ///     var body: some View {
    ///         VStack {
    ///             MarksView(marks: marks)
    ///             Button("New Mark") {
    ///                 let pointMark: Mark = …
    ///                 marks[…] = pointMark
    ///             }
    ///         }
    ///     }
    /// }
    /// ```
    public init(marks: Marks) {
        self.marks = marks
    }
    
    var allMarks: [IdentifiedMark] {
        marks.identifiedMarks.sorted()
    }
    
    public var body: some View {
        _Shims.GeometryReader { geometry in
            ForEach(drawingCache.drawableMarks(for: marks)) { drawable in
                switch drawable.mark.location {
                case .point(let point):
                    _PointMark(drawable: drawable, point: point, geometry: geometry)
                    .position(x: point.x, y: point.y)
                    #if os(visionOS)
                    .offset(z: geometry.size.depth > 0 ? point.z : 0)
                    #endif
                }
            }
        }
    }
}

final class MarksDrawingCache {
    static func makePalette() -> [Color] {
        [.indigo,
         .blue,
         .cyan,
         .mint,
         .green,
         .purple,
         .orange,
         .pink,
         .red,
         .yellow]
    }
    
    var colors = makePalette()
    var drawables: [AnyHashable: DrawableMark] = [:]
    
    func nextColor() -> Color {
        if colors.isEmpty {
            colors = Self.makePalette()
        }
        
        return colors.removeFirst()
    }
    
    func drawableMarks(for marks: Marks) -> [DrawableMark] {
        for (key, drawable) in drawables {
            if !marks.contains(key) {
                drawables.removeValue(forKey: key)
                // Return the unused color to the palette:
                colors.append(drawable.color)
            }
        }
        
        for (key, mark) in marks.values.sorted(by: { $0.value < $1.value }) {
            let drawable = drawables[key]
            if drawable?.mark != mark {
                drawables[key] = .init(id: key, mark: mark, color: drawable?.color ?? nextColor())
            }
        }
        
        return drawables.values.sorted(by: { $0.mark < $1.mark })
    }
    
    public struct DrawableMark: Identifiable {
        var id: IdentifiedMark.ID
        var mark: Mark
        var color: Color
    }
}

#if compiler(>=6) && !os(tvOS)
@available(macOS 14, *)
@available(iOS 17, *)
@available(tvOS 17, *)
@available(watchOS 10, *)
@available(visionOS 1, *)
#Preview {
    @Previewable @State var y = 20.0
    @Previewable @State var isTouch = true
    
    VStack {
        HStack {
            Toggle("Is Touch", isOn: $isTouch.animation())
                .padding(.trailing, 30)
            LabeledContent("Y Coordinate:") {
                Slider(value: $y, in: 0...500)
            }
        }
        .padding()
        
        MarksView(marks: Marks {
            IdentifiedMark(id: "Nice", mark: .point(.init(x: 120, y: y, z: 20), represents: isTouch ? .touch : nil))
            IdentifiedMark(id: "Wow",  mark: .point(.init(x: 250, y: 140, z: 10)))
            IdentifiedMark(id: "Fine", mark: .point(.init(x: 320, y: 30, z: 100)))
        })
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
#endif // compiler >= 6

#endif
