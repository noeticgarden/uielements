
#if canImport(SwiftUI) && os(visionOS)
import SwiftUI
import RealityKit

struct Sphere: View {
    @PhysicalMetric(from: .meters)
    var oneMeter = 1
    
    @State var visibleSize: Size3D?
    
    var body: some View {
        RealityView { content in
            let mesh: MeshResource = .generateSphere(radius: 0.1)
            let entity = ModelEntity(mesh: mesh, materials: [SimpleMaterial(color: .red, isMetallic: true)])
            content.add(entity)
            
            let size = entity.visualBounds(relativeTo: nil)
            Task { @MainActor in
                self.visibleSize = Size3D(size.extents)
            }
        }
        .frame(maxWidth:  (visibleSize?.width).flatMap  { $0 * oneMeter } ?? .infinity,
               maxHeight: (visibleSize?.height).flatMap { $0 * oneMeter } ?? .infinity)
        .frame(maxDepth:  (visibleSize?.depth).flatMap  { $0 * oneMeter } ?? .infinity)
    }
}
#endif
