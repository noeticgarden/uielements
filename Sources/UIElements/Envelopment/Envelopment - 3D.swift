
#if canImport(SwiftUI) && os(visionOS)
import SwiftUI

struct _Envelopment3D: View {
    let subviews: (Envelopment.State) -> _EnvelopmentFaces
    let geometry: _GeometryProxy
    let adaptation: Envelopment.Adaptation
    
    init(@_EnvelopmentBuilder subviews: @escaping (Envelopment.State) -> _EnvelopmentFaces, geometry: _GeometryProxy, adaptation: Envelopment.Adaptation) {
        self.subviews = subviews
        self.geometry = geometry
        self.adaptation = adaptation
    }
    
    var body: some View {
        let size = geometry.size
        let state = Envelopment.State(hasDepth: size.depth > 0)
        let subviews = self.subviews(state)
        
        Group {
            Group {
                if state.hasDepth || adaptation == .showsSingleFace(.back) || adaptation == .simulatesFrontView {
                    subviews.views(.back)
                        .frame(maxWidth: size.width, maxHeight: size.height)
                        .frame(maxDepth: size.depth)
                }
                
                if state.hasDepth || adaptation == .simulatesFrontView {
                    subviews.views(.front)
                        .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
                        .frame(maxWidth: size.width, maxHeight: size.height)
                        .frame(maxDepth: size.depth)
                        .offset(z: state.hasDepth ? size.depth - 1 : 0)
                }
                
                if state.hasDepth || adaptation == .showsSingleFace(.frontOutward) || adaptation == .simulatesFrontView {
                    subviews.views(.frontOutward)
                        .frame(maxWidth: size.width, maxHeight: size.height)
                        .frame(maxDepth: size.depth)
                        .offset(z: state.hasDepth ? size.depth : 0)
                }
                
                if !state.hasDepth, case .showsSingleFace(let placement) = adaptation, placement != .back && placement != .frontOutward {
                    subviews.views(placement)
                        .frame(maxWidth: size.width, maxHeight: size.height)
                        .frame(maxDepth: size.depth)
                }
            }
            .frame(maxWidth: size.width, maxHeight: size.height)
            .frame(maxDepth: size.depth)
            
            subviews.views(.leading)
                .frame(maxWidth: size.depth, maxHeight: size.height)
                .frame(maxDepth: size.depth)
                .rotation3DEffect(.degrees(90), axis: (0, 1, 0))
                .offset(z: size.depth / 2)
                .offset(x: -size.width / 2, y: 0)
            
            subviews.views(.trailing)
                .frame(maxWidth: size.depth, maxHeight: .infinity)
                .frame(maxDepth: size.width)
                .rotation3DEffect(.degrees(-90), axis: (0, 1, 0))
                .offset(z: size.depth / 2)
                .offset(x: size.width / 2, y: 0)
            
            subviews.views(.top)
                .frame(maxWidth: size.width, maxHeight: size.depth)
                .frame(maxDepth: size.width)
                .rotation3DEffect(.degrees(-90), axis: (1, 0, 0))
                .offset(z: size.depth / 2)
                .offset(x: 0, y: -size.height / 2)
            
            subviews.views(.bottom)
                .frame(maxWidth: size.width, maxHeight: size.depth)
                .frame(maxDepth: size.height)
                .rotation3DEffect(.degrees(90), axis: (1, 0, 0))
                .offset(z: size.depth / 2)
                .offset(x: 0, y: size.height / 2)
        }
        .frame(maxWidth: size.width, maxHeight: size.height)
        .frame(depth: size.depth)
        .position(
            .init(projecting: geometry.frame(in: .local).center)
        )
        .offset(
            z: -size.depth / 2
        )
    }
}

private func area(_ color: some ShapeStyle) -> some View {
    RoundedRectangle(cornerRadius: 15)
        .foregroundStyle(color)
        .border(.red)
        .opacity(0.25)
}

#Preview {
    let sticker =
    Circle()
        .foregroundStyle(.mint)
        .border(.yellow)

    _GeometryReader { geometry in
        _Envelopment3D(
            subviews: { state in
                ZStack {
                    area(.blue)
                    sticker
                        .frame(maxWidth: 230)
                        .offset(z: state.hasDepth ? 10 : 0)
                }
                .envelopmentPlacement(.back)
                
                ZStack {
                    area(.red)
                    sticker
                    Text("Hi!")
                        .font(.system(size: 125))
                }
                .envelopmentPlacement(.frontOutward)

                ZStack {
                    area(.yellow)
                    sticker
                        .frame(maxWidth: 150)
                        .offset(z: state.hasDepth ? 10 : 0)
                }
                .envelopmentPlacement(.leading)

                ZStack {
                    area(.pink)
                    sticker
                        .frame(maxWidth: 280)
                        .offset(z: state.hasDepth ? 10 : 0)
                }
                .envelopmentPlacement(.trailing)

                ZStack {
                    area(.cyan)
                    sticker
                        .frame(maxWidth: 90)
                        .offset(z: state.hasDepth ? 5 : 0)
                }
                .envelopmentPlacement(.top)

                ZStack {
                    area(.indigo)
                    sticker
                        .frame(maxWidth: 380)
                        .offset(z: state.hasDepth ? 5 : 0)
                }
                .envelopmentPlacement(.bottom)
            },
            geometry: geometry,
            adaptation: .simulatesFrontView
        )
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .frame(maxDepth: .infinity)
}

#endif
