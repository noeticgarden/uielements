
#if canImport(SwiftUI)
import SwiftUI
import Spatial

public enum _Shims {
#if !os(visionOS)
    public struct EdgeInsets3D: Equatable {
        public var top: CGFloat
        public var leading: CGFloat
        public var bottom: CGFloat
        public var trailing: CGFloat
        
        public var front: CGFloat
        
        public var back: CGFloat
        
        public init(horizontal: CGFloat = 0, vertical: CGFloat = 0, depth: CGFloat = 0) {
            self.top = vertical
            self.leading = horizontal
            self.bottom = vertical
            self.trailing = horizontal
            self.front = depth
            self.back = depth
        }
        
        public init(top: CGFloat = 0, leading: CGFloat = 0, bottom: CGFloat = 0, trailing: CGFloat = 0, front: CGFloat = 0, back: CGFloat = 0) {
            self.top = top
            self.leading = leading
            self.bottom = bottom
            self.trailing = trailing
            self.front = front
            self.back = back
        }
    }
#endif
    
    public struct GeometryReader<Content: View>: View {
#if os(visionOS)
        private typealias _Reader = SwiftUI.GeometryReader3D
#else
        private typealias _Reader = SwiftUI.GeometryReader
#endif
        
        let builder: (GeometryProxy) -> Content
        public init(@ViewBuilder builder: @escaping (GeometryProxy) -> Content) {
            self.builder = builder
        }
        
        public var body: some View {
            _Reader { proxy in
                builder(.init(proxied: proxy))
            }
        }
    }
    
    public struct GeometryProxy {
#if os(visionOS)
        fileprivate typealias Proxied = SwiftUI.GeometryProxy3D
#else
        fileprivate typealias Proxied = SwiftUI.GeometryProxy
#endif
        
        private let proxied: Proxied
        fileprivate init(proxied: Proxied) {
            self.proxied = proxied
        }
        
        public var size: Size3D {
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
        
        public subscript<T>(anchor: Anchor<T>) -> T {
            proxied[anchor]
        }
        
        @available(iOS, introduced: 13.0, deprecated: 100000.0)
        @available(macOS, introduced: 10.15, deprecated: 100000.0)
        @available(tvOS, introduced: 13.0, deprecated: 100000.0)
        @available(watchOS, introduced: 6.0, deprecated: 100000.0)
        @available(visionOS, introduced: 1.0, deprecated: 100000.0)
        public func cgRectFrame(in coordinateSpace: CoordinateSpace) -> CGRect {
#if os(visionOS)
            switch coordinateSpace {
            case .global:
                return .init(truncating: proxied.frame(in: .global))
            case .local:
                return .init(truncating: proxied.frame(in: .local))
            case .named(let anyHashable):
                return .init(truncating: proxied.frame(in: .named(anyHashable)))
            @unknown default:
                fatalError()
            }
#else
            proxied.frame(in: coordinateSpace)
#endif
        }
        
        @available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, visionOS 1.0, *)
        public func frame(in coordinateSpace: some CoordinateSpaceProtocol) -> Rect3D {
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
        
        public var safeAreaInsets: EdgeInsets3D {
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
}

#endif
