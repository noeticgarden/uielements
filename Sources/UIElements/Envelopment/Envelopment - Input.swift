
#if canImport(SwiftUI)
import SwiftUI

/// A builder for placing views on the face of an ``Envelopment``.
///
/// You typically don't use this directly, but you will provide values to closures decorated with it as you use the ``Envelopment/init(subviews:)-1mb6`` or ``Envelopment/init(subviews:)-3fr0w`` constructors of an envelopment. Pass any number of ``EnvelopmentFaces`` in the bodies of that closure. See the documentation for ``Envelopment`` for more information.
@resultBuilder
public enum _EnvelopmentBuilder: _ElementsBuilder {
    public typealias Element = EnvelopmentFace
    
    public static func buildFinalResult(_ component: [Self.Element]) -> _EnvelopmentFaces {
        .init(content: component)
    }
}

/// A container that places a view on one of the faces of an ``Envelopment``.
///
/// You typically use this as part of a call of an envelopment's ``Envelopment/init(subviews:)-1mb6`` or ``Envelopment/init(subviews:)-3fr0w`` constructors. It will mark the view you pass to be placed on the face you specify.
///
/// See ``Envelopment`` and ``Envelopment/Placement`` for how placements affect your views.
public struct EnvelopmentFace {
    let placement: Envelopment.Placement
    let view: AnyView
    
    /// Creates a new face, placing the content at the specified placement.
    ///
    /// You typically create instances of this type in the closure you pass to an ``Envelopment``'s ``Envelopment/init(subviews:)-1mb6`` or ``Envelopment/init(subviews:)-3fr0w`` constructors. See the documentation there for examples.
    public init(placement: Envelopment.Placement, @ViewBuilder content: () -> some View) {
        self.placement = placement
        self.view = AnyView(content())
    }
}

/// An opaque type that represents the content of all faces of an envelopment.
///
/// You do not interact directly with this type. See ``Envelopment`` for its use.
public struct _EnvelopmentFaces {
    struct Face: Identifiable {
        let id: Int
        let content: EnvelopmentFace
    }
    
    let faces: [Face]
    
    init(content: [EnvelopmentFace]) {
        self.faces = content.enumerated().map {
            Face(id: $0.offset, content: $0.element)
        }
    }
    
    @ViewBuilder
    func views(_ placed: Envelopment.Placement) -> some View {
        ForEach(faces) { face in
            if face.content.placement == placed {
                face.content.view
            }
        }
    }
}

#endif
