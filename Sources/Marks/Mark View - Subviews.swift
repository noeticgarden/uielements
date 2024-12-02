
#if canImport(SwiftUI)
import SwiftUI
import Spatial
import UIElements

struct _PointMark: View {
    let drawable: MarksDrawingCache.DrawableMark
    let point: Point3D
    let geometry: _Shims.GeometryProxy
    
    var format: FloatingPointFormatStyle<Double> {
        .number.precision(.fractionLength(0...0))
    }
    
    var backgroundMaterial: some ShapeStyle {
        if #available(watchOS 10, *) {
            AnyShapeStyle(.regularMaterial)
        } else {
            AnyShapeStyle(Color(white: 0.2))
        }
    }
    
    @ViewBuilder
    var circle: some View {
        let isTouch = drawable.mark.represents == .touch
        let size: CGFloat = isTouch ? 50 : 5
        let foreground = isTouch ? drawable.color.opacity(0.2) : drawable.color
        let border = isTouch ? drawable.color : Color.clear
        
        ZStack {
            Circle()
                .stroke(border)
                .frame(width: size, height: size)
            
            Circle()
                .foregroundStyle(foreground)
                .frame(width: size, height: size)
        }
    }
    
    var avoidanceDistance: CGFloat {
        let isTouch = drawable.mark.represents == .touch
        return isTouch ? 25 : 0
    }
    
    var body: some View {
        ZStack {
            circle
            
            Text("\(point.x.formatted(format)), \(point.y.formatted(format)), \(point.z.formatted(format))")
                .font(.system(size: 9).monospacedDigit())
                .foregroundStyle(.secondary)
                .padding([.leading, .trailing], 5)
                .padding([.top, .bottom], 2)
#if os(visionOS)
                .glassBackgroundEffect(in: .capsule)
#else
                .background(backgroundMaterial, in: .capsule)
#endif
                .offset(x: 0, y: {
                    if drawable.mark.minY <= 0.1 * geometry.cgRectFrame(in: .local).maxY {
                        12 + avoidanceDistance
                    } else {
                        -(12 + avoidanceDistance)
                    }
                }())
        }
    }
}
#endif
