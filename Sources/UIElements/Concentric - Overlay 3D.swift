
#if canImport(SwiftUI)
import SwiftUI
import Spatial

struct _Surround<Overlaid: View>: ViewModifier {
    let overlaid: Overlaid
    
    @State var size: Size3D?
    
    func body(content: Content) -> some View {
        Concentric {
            content
                .modifier(_SizeExfiltrator { newSize in
                    self.size = newSize
                })
            overlaid
        }
        .frame(width:  (size?.width).flatMap { CGFloat($0) },
               height: (size?.height).flatMap { CGFloat($0) })
#if os(visionOS)
        .frame(depth:  (size?.depth).flatMap  { CGFloat($0) })
#endif
    }
}

extension View {
    /// Creates a new view by surrounding the receiver with the content.
    ///
    /// This is similar to the [`overlay`](https://developer.apple.com/documentation/swiftui/view/overlay(alignment:content:)) modifier in SwiftUI, except it sizes the `content` to have the exact same frame as the receiver.
    ///
    /// On visionOS, the content will be placed at at the receiver's origin, and will have the exact same width, height, and depth. On other OSes, the content will be placed at the receiver's origin, and will have the exact same width and height. 
    public func surround(@ViewBuilder _ content: () -> some View) -> some View {
        modifier(_Surround(overlaid: content()))
    }
}

#if compiler(>=6) // Require Xcode 16's SDKs for previews.
#Preview {
#if os(visionOS)
    let view = Sphere()
#else
    let view = Rectangle()
        .foregroundStyle(.blue)
        .frame(width: 250, height: 250)
#endif
    
    view
        .surround {
            Envelopment { side in
                Rectangle()
                    .foregroundStyle(.red.opacity(0.1))
                    .border(.red)
            }
        }
}
#endif // compiler(>=6)

#endif
