
#if canImport(SwiftUI)
import Foundation
import SwiftUI
import Spatial

extension ExperimentalViewMethods {
    /// Adds and removes marks to the specified marks collection when the user performs a drag gesture on the receiver.
    ///
    /// Marks will be added and removed from the specified collection with a private key type.
    ///
    /// > Note: Drag gestures never occur on tvOS.
    ///
    /// Make sure the `coordinateSpace` corresponds to the coordinate space of the displaying ``MarksView``. You can, for example, use the `surround(_:)` modifier from UIElements to place the view at the same coordinate space as another, and have a known coordinate space value that then will apply to both.
    ///
    /// > Important: This modifier is experimental API and subject to change without notice.
    @available(macOS 14, *)
    @available(iOS 17, *)
    @available(tvOS 17, *)
    @available(watchOS 10, *)
    @available(visionOS 1, *)
    public func marksDragGestures(coordinateSpace: some CoordinateSpaceProtocol = .local, amongst marks: Binding<Marks>) -> some View {
#if os(tvOS)
        content
#else
        content.modifier(_ShowsDragMarksModifier(coordinateSpace: coordinateSpace, marks: marks))
#endif
    }
}

#if !os(tvOS)
struct DragMarkKey: Sendable, Hashable {
    let id = UUID()
}

@available(macOS 14, *)
@available(iOS 17, *)
@available(tvOS 17, *)
@available(watchOS 10, *)
@available(visionOS 1, *)
struct _ShowsDragMarksModifier<CoordinateSpace: CoordinateSpaceProtocol>: ViewModifier {
    let coordinateSpace: CoordinateSpace
    @State var key: DragMarkKey?
    @Binding var marks: Marks
    
    var gesture: some Gesture {
        DragGesture(minimumDistance: 1, coordinateSpace: coordinateSpace)
            .onChanged { value in
                let key: DragMarkKey
                
                if let aKey = self.key {
                    key = aKey
                } else {
                    key = DragMarkKey()
                    self.key = key
                }
                
                var represents: Mark.Semantics? = .touch
#if os(macOS)
                represents = nil
#endif
                
#if os(visionOS)
                marks[key] = .point(value.location3D, represents: represents)
#else
                marks[key] = .point(Point3D(x: value.location.x, y: value.location.y, z: 0), represents: represents)
#endif
            }
            .onEnded { value in
                if let key {
                    marks[key] = nil
#if !os(watchOS)
                    // Remove the hover mark until there's a new hover, too:
                    marks[HoverMarkKey()] = nil
#endif
                    self.key = nil
                }
            }
    }
    
    func body(content: Content) -> some View {
        content
            .allowsHitTesting(true)
            .contentShape(Rectangle())
            .gesture(gesture)
    }
}

#if compiler(>=6)
@available(macOS 14, *)
@available(iOS 17, *)
@available(tvOS 17, *)
@available(watchOS 10, *)
@available(visionOS 1, *)
#Preview {
    @Previewable @State var marks = Marks()
    
    MarksView(marks: marks)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .experimental.marksDragGestures(amongst: $marks)
        .background(Color.red.opacity(0.2))
}
#endif

#endif
#endif
