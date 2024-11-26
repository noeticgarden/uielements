
#if canImport(SwiftUI)
import SwiftUI
import Spatial

#if !os(visionOS)
struct EdgeInsets3D: Equatable {
    var top: CGFloat
    var leading: CGFloat
    var bottom: CGFloat
    var trailing: CGFloat

    var front: CGFloat

    var back: CGFloat

    init(horizontal: CGFloat = 0, vertical: CGFloat = 0, depth: CGFloat = 0) {
        self.top = vertical
        self.leading = horizontal
        self.bottom = vertical
        self.trailing = horizontal
        self.front = depth
        self.back = depth
    }

    init(top: CGFloat = 0, leading: CGFloat = 0, bottom: CGFloat = 0, trailing: CGFloat = 0, front: CGFloat = 0, back: CGFloat = 0) {
        self.top = top
        self.leading = leading
        self.bottom = bottom
        self.trailing = trailing
        self.front = front
        self.back = back
    }
}
#endif

struct _GeometryReader<Content: View>: View {
#if os(visionOS)
    private typealias _Reader = GeometryReader3D
#else
    private typealias _Reader = GeometryReader
#endif
    
    let builder: (_GeometryProxy) -> Content
    init(@ViewBuilder builder: @escaping (_GeometryProxy) -> Content) {
        self.builder = builder
    }

    var body: some View {
        _Reader { proxy in
            builder(.init(proxied: proxy))
        }
    }
}

struct _GeometryProxy {
#if os(visionOS)
    fileprivate typealias Proxied = GeometryProxy3D
#else
    fileprivate typealias Proxied = GeometryProxy
#endif
    
    private let proxied: Proxied
    fileprivate init(proxied: Proxied) {
        self.proxied = proxied
    }
    
    var size: Size3D {
#if os(visionOS)
        proxied.size
#else
        let size = proxied.size
        return Size3D(
            width: size.width,
            height: size.height,
            depth: 0
        )
#endif
    }
    
    subscript<T>(anchor: Anchor<T>) -> T {
        proxied[anchor]
    }
    
    @available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, visionOS 1.0, *)
    func frame(in coordinateSpace: some CoordinateSpaceProtocol) -> Rect3D {
#if os(visionOS)
        proxied.frame(in: coordinateSpace)
#else
        let frame = proxied.frame(in: coordinateSpace)
        return Rect3D(
            origin: .init(
                x: frame.origin.x,
                y: frame.origin.y,
                z: 0
            ),
            size: Size3D(
                width: size.width,
                height: size.height,
                depth: 0
            )
        )
#endif
    }
    
    var safeAreaInsets: EdgeInsets3D {
#if os(visionOS)
        proxied.safeAreaInsets
#else
        let insets = proxied.safeAreaInsets
        return .init(
            top: insets.top,
            leading: insets.leading,
            bottom: insets.bottom,
            trailing: insets.trailing
        )
#endif
    }
}

#endif
