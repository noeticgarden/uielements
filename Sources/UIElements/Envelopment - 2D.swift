
#if canImport(SwiftUI)
import SwiftUI

struct _Envelopment2D: View {
    let subviews: (Envelopment.State) -> _EnvelopmentFaces
    let geometry: _GeometryProxy
    
    init(@_EnvelopmentBuilder subviews: @escaping (Envelopment.State) -> _EnvelopmentFaces, geometry: _GeometryProxy) {
        self.subviews = subviews
        self.geometry = geometry
    }
    
    var body: some View {
        let state = Envelopment.State(hasDepth: false)
        let subviews = self.subviews(state)
        
        subviews.views(.back)
            .frame(maxWidth: geometry.size.width, maxHeight: geometry.size.height)
        
        subviews.views(.front)
            .frame(maxWidth: geometry.size.width, maxHeight: geometry.size.height)
            .shims.rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
    }
}

#Preview {
    let back =
    RoundedRectangle(cornerRadius: 15)
        .foregroundStyle(.blue)
        .border(.red)
    
    let front =
    Circle()
        .foregroundStyle(.mint)
        .border(.yellow)

    _GeometryReader { geometry in
        _Envelopment2D(
            subviews: { state in
                back.envelopmentPlacement(.back)
                if state.hasDepth {
                    front.envelopmentPlacement(.front)
                }
            },
            geometry: geometry
        )
    }
}

#endif
