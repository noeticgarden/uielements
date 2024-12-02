
#if canImport(SwiftUI)
import SwiftUI

extension ExperimentalViewMethods {
    /// Adds and removes marks to the specified marks collection when the user hovers on the receiver.
    ///
    /// On platforms that support mouse or trackpad pointers, a mark will be shown at the location of the pointer during the hover.
    ///
    /// On tvOS, a continuous hover will start on a view when it is focused and end when it is unfocused, and will remain centered on the view unless the finger is moving on the trackpad. The mark will appear when focused, be removed when unfocused, and move from the center to the sides depending on the user touching the trackpad or not.
    ///
    /// Marks will be added and removed from the specified collection with a private key type.
    ///
    /// Make sure the `coordinateSpace` corresponds to the coordinate space of the displaying ``MarksView``. You can, for example, use the `surround(_:)` modifier from UIElements to place the view at the same coordinate space as another, and have a known coordinate space value that then will apply to both.
    ///
    /// > Important: This modifier is experimental API and subject to change without notice.
    @available(macOS 14, *)
    @available(iOS 17, *)
    @available(tvOS 17, *)
    @available(watchOS 10, *)
    @available(visionOS 1, *)
    public func marksContinuousHover(coordinateSpace: some CoordinateSpaceProtocol = .local, amongst marks: Binding<Marks>) -> some View {
#if os(watchOS)
        content
#else
        content.onContinuousHover(coordinateSpace: coordinateSpace) {
            marks.wrappedValue.set($0)
        }
#endif
    }
    
    /// Adds and removes marks to the specified marks collection when the user hovers on the receiver.
    ///
    /// On platforms that support mouse or trackpad pointers, a mark will be shown at the location of the pointer during the hover.
    ///
    /// On tvOS, a continuous hover will start on a view when it is focused and end when it is unfocused, and will remain centered on the view unless the finger is moving on the trackpad. The mark will appear when focused, be removed when unfocused, and move from the center to the sides depending on the user touching the trackpad or not.
    ///
    /// Marks will be added and removed from the specified collection with a private key type.
    ///
    /// Make sure the `coordinateSpace` corresponds to the coordinate space of the displaying ``MarksView``. You can, for example, use the `surround(_:)` modifier from UIElements to place the view at the same coordinate space as another, and have a known coordinate space value that then will apply to both.
    ///
    /// > Note: This method uses static coordinate spaces and is suitable for back-deployment. The variant that doesn't use deprecated methods, ``marksContinuousHover(coordinateSpace:amongst:)-8m7gu``,  is preferred where possible.
    ///
    /// > Important: This modifier is experimental API and subject to change without notice.
    @available(iOS, introduced: 16.0, deprecated: 100000.0)
    @available(macOS, introduced: 13.0, deprecated: 100000.0)
    @available(tvOS, introduced: 16.0, deprecated: 100000.0)
    @available(visionOS, introduced: 1.0, deprecated: 100000.0)
    public func marksContinuousHover(coordinateSpace: CoordinateSpace = .local, amongst marks: Binding<Marks>) -> some View {
#if os(watchOS)
        content
#else
        content.onContinuousHover(coordinateSpace: coordinateSpace) {
            marks.wrappedValue.set($0)
        }
#endif
    }
}

#if !os(watchOS)
struct HoverMarkKey: Sendable, Hashable {
    public init() {}
}

extension Marks {
    var hoverMark: Mark? {
        get { self[HoverMarkKey()] }
        set { self[HoverMarkKey()] = newValue }
    }
    
    public mutating func set(_ hoverPhase: HoverPhase) {
        switch hoverPhase {
        case .active(let cgPoint):
            self.hoverMark = .point(.init(x: cgPoint.x, y: cgPoint.y, z: 0))
        case .ended:
            self.hoverMark = nil
        }
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
        .experimental.marksContinuousHover(amongst: $marks)
}
#endif

#endif // !os(watchOS)

#endif
