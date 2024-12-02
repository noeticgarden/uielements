
#if canImport(SwiftUI) && compiler(>=6) // Require Xcode 16's SDKs:
import Foundation
import SwiftUI

/// Adds and removes marks to the specified marks collection when the user performs any direct or indirect touches, or mouse or trackpad clicks, on the receiver.
///
/// This modifier will show multiple marks if multiple events are occurring at the same time.
///
/// > Note: No spatial events can occur on tvOS. To detect the user moving their finger on a trackpad, use ``ExperimentalViewMethods/marksContinuousHover(coordinateSpace:amongst:)-8m7gu`` instead.
///
/// Marks will be added and removed from the specified collection with a private key type.
///
/// Make sure the `coordinateSpace` corresponds to the coordinate space of the displaying ``MarksView``. You can, for example, use the `surround(_:)` modifier from UIElements to place the view at the same coordinate space as another, and have a known coordinate space value that then will apply to both.
///
/// > Important: This modifier is experimental API and subject to change without notice.
extension ExperimentalViewMethods {
    @available(macOS 15, *)
    @available(iOS 18, *)
    @available(tvOS 18, *)
    @available(watchOS 11, *)
    @available(visionOS 1, *)
    public func marksSpatialEvents(coordinateSpace: some CoordinateSpaceProtocol = .local, amongst marks: Binding<Marks>) -> some View {
#if os(tvOS)
        content
#else
        content.modifier(_ShowsSpatialMarksModifier(coordinateSpace: coordinateSpace, marks: marks))
#endif
    }
}

#if !os(tvOS)
import Spatial

@available(macOS 15, *)
@available(iOS 18, *)
@available(tvOS 18, *)
@available(watchOS 11, *)
@available(visionOS 1, *)
extension SpatialEventCollection.Event {
    var shims: _EventShim { .init(event: self) }
}

@available(macOS 15, *)
@available(iOS 18, *)
@available(tvOS 18, *)
@available(watchOS 11, *)
@available(visionOS 1, *)
struct _EventShim {
    let event: SpatialEventCollection.Event
    
    var location3D: Point3D {
#if os(visionOS)
        event.location3D
#else
        Point3D(x: event.location.x, y: event.location.y)
#endif
    }
}

@available(macOS 15, *)
@available(iOS 18, *)
@available(tvOS 18, *)
@available(watchOS 11, *)
@available(visionOS 1, *)
struct _ShowsSpatialMarksModifier<CoordinateSpace: CoordinateSpaceProtocol>: ViewModifier {
    let coordinateSpace: CoordinateSpace
    @Binding var marks: Marks
    
    func semantics(for event: SpatialEventCollection.Event) -> Mark.Semantics? {
        switch event.kind {
        case .touch: fallthrough
        case .directPinch: fallthrough
        case .indirectPinch:
            return .touch
            
        case .pencil: fallthrough
        case .pointer: fallthrough
        @unknown default:
            return nil
        }
    }
    
    var gesture: some Gesture {
        SpatialEventGesture(coordinateSpace: coordinateSpace)
            .onChanged { events in
                print(events)
                
                for event in events {
                    let id = event.id
                    
                    switch event.phase {
                    case .active:
                        marks[id] = .point(event.shims.location3D, represents: semantics(for: event))
                        
                    case .ended: fallthrough
                    case .cancelled:
                        marks.removeValue(for: event.id)
                        
                    @unknown default:
                        break
                    }
                }
            }
            .onEnded { events in
                for event in events {
                    marks.removeValue(for: event.id)
                }
            }
    }
    
    func body(content: Content) -> some View {
        content
            .gesture(gesture)
    }
}

#if compiler(>=6)
@available(macOS 15, *)
@available(iOS 18, *)
@available(tvOS 18, *)
@available(watchOS 11, *)
@available(visionOS 1, *)
#Preview {
    @Previewable @State var marks = Marks()
    
    MarksView(marks: marks)
        .experimental.marksSpatialEvents(amongst: $marks)
        .background(Color.red.opacity(0.2))
}
#endif

#endif // !os(tvOS)

#endif
