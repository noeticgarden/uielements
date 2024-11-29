
#if canImport(SwiftUI)
import SwiftUI

struct _Envelopment2D: View {
    let subviews: (Envelopment.State) -> _EnvelopmentFaces
    let geometry: _GeometryProxy
    let adaptation: Envelopment.Adaptation
    
    init(@_EnvelopmentBuilder subviews: @escaping (Envelopment.State) -> _EnvelopmentFaces, geometry: _GeometryProxy, adaptation: Envelopment.Adaptation) {
        self.subviews = subviews
        self.geometry = geometry
        self.adaptation = adaptation
    }
    
    var body: some View {
        let state = Envelopment.State(hasDepth: false)
        let subviews = self.subviews(state)
        
        if adaptation == .showsSingleFace(.back) ||
            adaptation == .simulatesFrontView {
            subviews.views(.back)
                .frame(maxWidth: geometry.size.width, maxHeight: geometry.size.height)
        }
        
        if adaptation == .simulatesFrontView {
            subviews.views(.front)
                .frame(maxWidth: geometry.size.width, maxHeight: geometry.size.height)
                .shims.rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
        }
        
        if adaptation == .showsSingleFace(.frontOutward) ||
            adaptation == .simulatesFrontView {
            subviews.views(.frontOutward)
                .frame(maxWidth: geometry.size.width, maxHeight: geometry.size.height)
        }
        
        if case .showsSingleFace(let placement) = adaptation,
           placement != .back && placement != .frontOutward {
            subviews.views(placement)
                .frame(maxWidth: geometry.size.width, maxHeight: geometry.size.height)
        }
    }
}

#if compiler(>=6) // Require Xcode 16's SDKs for previews.
#Preview {
    let back =
    RoundedRectangle(cornerRadius: 15)
        .foregroundStyle(.blue)
        .border(.red)
    
    let bottom =
    Rectangle()
        .aspectRatio(1, contentMode: .fit)
        .foregroundStyle(.orange)
        .border(.yellow)
    
    let front =
    ZStack {
        Circle()
            .foregroundStyle(.mint)
            .border(.yellow)
        Text("Hi!")
            .font(.title)
            .foregroundStyle(.black)
    }
    
    let frontOutward =
    ZStack {
        Circle()
            .foregroundStyle(.indigo)
            .border(.yellow)
        Text("Hi!")
            .font(.title)
            .foregroundStyle(.red)
    }

    _GeometryReader { geometry in
        _Envelopment2D(
            subviews: { state in
                back.envelopmentPlacement(.back)
                front.envelopmentPlacement(.front)
                bottom.envelopmentPlacement(.bottom)
                frontOutward.envelopmentPlacement(.frontOutward)
            },
            geometry: geometry,
            adaptation: .simulatesFrontView
        )
    }
}
#endif // compiler(>=6)

#endif
