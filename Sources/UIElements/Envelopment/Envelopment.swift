
#if canImport(SwiftUI)
import SwiftUI

extension View {
    // This method used to be public, but the Envelopment constructors were switched over to use EnvelopmentFace, and I didn't want to rewrite my previews.
    func envelopmentPlacement(_ placement: Envelopment.Placement) -> EnvelopmentFace {
        .init(placement: placement, content: { self })
    }
}

/// An envelopment is a SwiftUI container that envelops its bounds by displaying SwiftUI views on each of its faces.
///
/// An envelopment is a container view, similar to built-in SwiftUI containers. Unlike most containers, it does not arrange views on a plane, but instead places its subviews to fill the bounds of each of its faces.
///
/// On visionOS, where views have depth, this means that the envelopment can display up to 9 views: one each on the back, front, leading side, trailing side, top, and bottom faces of its bounds prism, which will delimit and envelop its bounds.
///
/// ![A screenshot of an envelopment on visionOS, displaying views that mark its sides as front, leading, bottom, trailing, top, and back.](placements-3d)
///
/// Use an envelopment to provide affordances as the user performs spatial gestures on a region, for debug display, or to surround the user with content. The Z axis of all managed views points to the center of the envelopment; views that are offset with a positive Z value from any of the placed subviews of an envelopment will move toward the center, allowing you to place spatial content that's relative to the edges of the bounds with ease.
///
/// ### Placement
///
/// An envelopment will accept any number of subviews via its initializers (``init(subviews:)-3fr0w`` and ``init(subviews:)-1mb6``). However, it will only display those subviews that have been placed on one of its faces. In the closure you pass, use the ``EnvelopmentFace`` container to place a subview on a face. For example:
///
/// ```swift
/// Envelopment {
///     EnvelopmentFace(placement: .back) {
///         BackWall()
///     }
///
///     EnvelopmentFace(placement: .bottom) {
///         Floor()
///     }
/// }
/// ```
///
/// ### 2D Usage
///
/// Envelopments also support being displayed on OSes with 2D displays. In that case, the view supports showing up to 2 subviews, one corresponding to the notional back face and one corresponding to the notional front face, simulating the isometric projection of the front perspective of the 3D version of this view.
///
/// ![A screenshot of an envelopment on macOS, displaying a 'back' view overlaid by a 'front' view that is flipped around its Y axis.](placements-2d)
///
/// While this makes the behavior of the envelopment predictable, it also means the user has no way to look around a front face to access a back face. You can use the ``Envelopment/State`` type, its ``Envelopment/State/hasDepth`` property, and the ``init(subviews:)-3fr0w`` constructor to detect this issue, which may also occur on visionOS if the view has a depth of zero, and alter or remove views that should not be shown. For example:
///
/// ```swift
/// Envelopment { state in
///     EnvelopmentFace(placement: .back) {
///         HeadsUpView()
///     }
///
///     EnvelopmentFace(placement: .front) {
///         AreaBoundary()
///             .opacity(state.hasDepth ? 1 : 0)
///     }
/// }
/// ```
public struct Envelopment: View {
    /// The current state of an ``Envelopment``, used to determine the content and display of its subviews.
    ///
    /// You don't construct an instance of this type; you will receive one in the closure you pass to ``Envelopment/init(subviews:)-1mb6``.
    public struct State {
        /// Indicates whether the envelopment's bounds have a depth greater than 0.
        ///
        /// If `true`, the ``Envelopment`` has space for contents that are offset on the Z axis from its subviews. Content with a positive Z offset will be displayed within the envelopment's 3D bounds, moving toward its center with increasing Z offsets.  Since the front view will completely obstruct the back view when an `Envelopment` has no depth, you may also want to vary the visibility or contents of that view to mitigate this problem.
        public var hasDepth: Bool
    }
    
    let subviews: (State) -> _EnvelopmentFaces
    
    /// A placement for a view contained in an ``Envelopment``.
    ///
    /// Use these values to specify which placement each ``EnvelopmentFace`` should have within the envelopment. Currently, you can place views on an envelopment facing inward, either at the back face of the envelopment (which faces and is oriented toward the user), or on the faces on the front, leading, trailing, top, or bottom sides.
    ///
    /// For more information on placement, see ``Envelopment``.
    public enum Placement: Hashable, Sendable, CaseIterable {
        /// This view will be placed on the back face of the envelopment, with the origin at the envelopment's origin and  its axes aligned to the envelopment's own, facing the user much as a traditional view does.
        case back
        
        /// This view will be placed on the leading-side face of the envelopment. Its origin will be at the top leading point of the envelopment's front face, and its X axis will end at the envelopment's origin.
        case leading
        
        /// This view will be placed on the front face of the envelopment. Its origin will be at the top trailing point of the envelopment's front face, and its X axis will end at the top leading point of that face.
        ///
        /// > Important: You should avoid using this placement and having a view placed at the ``front`` placement at the same time, or Z-fighting may occur.
        case front
        
        /// This view will be placed on the leading-side face of the envelopment. Its origin will be at the top trailing point of the envelopment's back face, and its X axis will end at the top trailing point of the front face.
        case trailing
        
        /// This view will be placed on the top face of the envelopment. Its origin will be at the top leading point of the envelopment's front face, and its Y axis will end at the envelopment's origin.
        case top
        
        /// This view will be placed on the bottom face of the envelopment. Its origin will be at the bottom leading point of the envelopment's back face, and its Y axis will end at the bottom leading point of its front face.
        case bottom
        
        /// This view will be placed on the front face of the envelopment, facing outward rather than inward. Its origin will be at the top leading point of the envelopment's front face, and its X axis will end at the top trailing point of the front face.
        ///
        /// Note that, since this placement faces outward, any content with a positive Z offset may be clipped.
        ///
        /// > Important: You should avoid using this placement and having a view placed at the ``front`` placement at the same time, or Z-fighting may occur.
        case frontOutward
    }

    let intrinsicAdaptation: Envelopment.Adaptation
    
    /// Creates an envelopment with subviews that depend on its state.
    ///
    /// Pass subviews by wrapping them in ``EnvelopmentFace``s and use the ``Envelopment/State`` provided to you to detect whether the envelopment has depth or not. For example:
    ///
    /// ```swift
    /// Envelopment { state in
    ///     EnvelopmentFace(placement: .back) {
    ///         BackView()
    ///     }
    ///
    ///     if state.hasDepth {
    ///         EnvelopmentFace(placement: .front) {
    ///             FrontView()
    ///         }
    ///     }
    ///
    ///     EnvelopmentFace(placement: .leading) {
    ///         LeadingView()
    ///     }
    ///
    ///     EnvelopmentFace(placement: .trailing) {
    ///         TrailingView()
    ///     }
    /// }
    /// ```
    ///
    /// The envelopment you construct this way will adapt to showing only the back face when its depth is zero. Use the ``SwiftUICore/View/envelopmentZeroDepthAdaptation(_:)`` modifier to change this behavior.
    public init(@_EnvelopmentBuilder subviews: @escaping (State) -> _EnvelopmentFaces) {
        self.subviews = subviews
        self.intrinsicAdaptation = .simulatesFrontView
    }
    
    /// Creates an envelopment with the specified subviews.
    ///
    /// Pass subviews by wrapping them in ``EnvelopmentFace``s. For example:
    ///
    /// ```swift
    /// Envelopment { state in
    ///     EnvelopmentFace(placement: .back) {
    ///         BackView()
    ///     }
    ///
    ///     EnvelopmentFace(placement: .front) {
    ///         FrontView()
    ///     }
    ///
    ///     EnvelopmentFace(placement: .leading) {
    ///         LeadingView()
    ///     }
    ///
    ///     EnvelopmentFace(placement: .trailing) {
    ///         TrailingView()
    ///     }
    /// }
    /// ```
    ///
    /// The envelopment you construct this way will simulate isometric perspective from the front when its depth is zero. Use the ``SwiftUICore/View/envelopmentZeroDepthAdaptation(_:)`` modifier to change this behavior.
    public init(@_EnvelopmentBuilder subviews: @escaping () -> _EnvelopmentFaces) {
        self.subviews = { _ in subviews() }
        self.intrinsicAdaptation = .showsSingleFace(.back)
    }
    
#if os(visionOS)
    private typealias _Envelopment3DIfAvailable = _Envelopment3D
#else
    private typealias _Envelopment3DIfAvailable = _Envelopment2D
#endif
    
    @Environment(\.envelopmentZeroDepthAdaptation) var adaptation
    
    public var body: some View {
        _Shims.GeometryReader { geometry in
            _Envelopment3DIfAvailable(subviews: subviews, geometry: geometry, adaptation: adaptation ?? intrinsicAdaptation)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
#if os(visionOS)
        .frame(maxDepth: .infinity)
#endif
    }
}

private func area(_ color: some ShapeStyle) -> some View {
    RoundedRectangle(cornerRadius: 15)
        .foregroundStyle(color)
        .border(.red)
        .opacity(0.25)
}

#if compiler(>=6) // Require Xcode 16's SDKs for previews.
@available(
    iOS 17.0,
    macOS 14.0,
    tvOS 17.0,
    watchOS 10.0,
    visionOS 1.0, *
)
#Preview {
    @Previewable @State var depth: CGFloat = 0
    
    let sticker =
    Circle()
        .foregroundStyle(.mint)
        .border(.yellow)
    
    _Shims.GeometryReader { geometry in
        VStack {
#if os(visionOS)
            Button("Toggle Depth") {
                withAnimation {
                    if depth < 300 {
                        depth = 300
                    } else {
                        depth = 0
                    }
                }
            }
            .padding()
            .glassBackgroundEffect()
#endif
            
            Envelopment { state in
                ZStack {
                    area(.blue)
                    sticker
                        .frame(maxWidth: 50)
                        .shims.offset(z: state.hasDepth ? 10 : 0)
                }
                .envelopmentPlacement(.back)

                ZStack {
                    area(.green)
                    sticker
                        .shims.offset(z: state.hasDepth ? -10 : 0)
                    Text("Hi")
                        .font(.system(size: 280))
                        .foregroundStyle(.black)
                }
                .envelopmentPlacement(.frontOutward)

                ZStack {
                    area(.yellow)
                    sticker
                        .frame(maxWidth: 150)
                        .shims.offset(z: state.hasDepth ? 10 : 0)
                }
                .envelopmentPlacement(.leading)

                ZStack {
                    area(.pink)
                    sticker
                        .frame(maxWidth: 280)
                        .shims.offset(z: state.hasDepth ? 10 : 0)
                }
                .envelopmentPlacement(.trailing)

                ZStack {
                    area(.cyan)
                    sticker
                        .frame(maxWidth: 90)
                        .shims.offset(z: state.hasDepth ? 5 : 0)
                }
                .envelopmentPlacement(.top)

                ZStack {
                    area(.indigo)
                    sticker
                        .frame(maxWidth: 380)
                        .shims.offset(z: state.hasDepth ? 5 : 0)
                }
                .envelopmentPlacement(.bottom)
            }
#if os(visionOS)
            .frame(depth: depth < 20 ? 0 : depth)
#endif
        }
    }
}
#endif // compiler(>=6)

#endif
