
#if canImport(SwiftUI)
import SwiftUI
import Spatial

extension View {
    var shims: _ViewShims<Self> {
        .init(content: self)
    }
}

struct _ViewShims<Content: View> {
    let content: Content
    
    func rotation3DEffect(_ angle: Angle, axis: (x: CGFloat, y: CGFloat, z: CGFloat), anchor: UnitPoint = .center, anchorZ: CGFloat = 0, perspective: CGFloat = 1) -> some View {
#if os(visionOS)
        content.perspectiveRotationEffect(angle, axis: axis, anchor: anchor, anchorZ: anchorZ, perspective: perspective)
#else
        content.rotation3DEffect(angle, axis: axis, anchor: anchor, anchorZ: anchorZ, perspective: perspective)
#endif
    }
    
    func offset(z: CGFloat) -> some View {
#if os(visionOS)
        content.offset(z: z)
#else
        content
#endif
    }
}

extension CGRect {
    var center: CGPoint {
        .init(
            x: midX,
            y: midY
        )
    }
}

extension CGPoint {
    init(truncating point: Point3D) {
        self.init(x: point.x, y: point.y)
    }
}

extension CGRect {
    init(truncating rect: Rect3D) {
        self.init(x: rect.origin.x, y: rect.origin.y, width: rect.size.width, height: rect.size.height)
    }
}

#endif
