
#if canImport(SwiftUI)
import SwiftUI

/// A SwiftUI container that causes its subviews to be placed at its center, regardless of subview sizing.
///
/// Most SwiftUI container place views as a function of the size of other views. For example, [`VStack`](https://developer.apple.com/documentation/swiftui/vstack) places view one after another by measuring their height.
///
/// Often, we want views to overlap. On desktop OSes, a [`ZStack`](https://developer.apple.com/documentation/swiftui/zstack) will cause by default views to be centered, and will only use their width and height to calculate its own ideal width and height. However, on visionOS, the `ZStack` will also use a view's depth and place views one after another stacking in depth toward the user; this will offset their centers toward the user similar to how a `VStack` offsets centers down to layout. This means that the layout of a `ZStack` may fail somewhat surprisingly to cover the same roles it does on other OSes.
///
/// This container places views with coincident centers at the center of its own bounds, on all OSes. On 2D systems, it will place views' centers at the middle of its width and height. On 3D systems, it will do so at the middle of its width, height, and depth.
///
/// The above means that views with equal width, height, and, on visionOS, depth, will occupy the same coordinates relative to the container. It is flexible and will occupy as much space as possible in its container; in turn, it will limit its subviews to the size it occupies.
///
/// Use a concentric container to place content so that their rendering overlaps in space. For example, you could use it to overlay your own controls atop a [`RealityView`](https://developer.apple.com/documentation/realitykit/realityview), or place content between views placed on the faces of an ``Envelopment``.
///
/// ## Backdeployment
///
/// Full functionality of the class requires Apple OSes releases from Fall 2024 or later. That includes macOS 15, iOS 18, tvOS 18, watchOS 11 and visionOS 2.
///
/// For Apple OS releases prior to Fall 2024, this class simulates subview management rather than use a [`ViewBuilder`](https://developer.apple.com/documentation/swiftui/viewbuilder). This means that some scenarios do not work the way you may expect them to. For example, the following will work when targeting newer OSes, but may fail to align `A()`, `B()` and `C()` when targeting iOS 17, macOS 14, and related releases:
///
/// ```swift
/// struct MyViews: View {
///     var body: some View {
///         A()
///         B()
///         C()
///     }
/// }
///
/// …
///
/// Concentric {
///     MyViews()
/// }
/// ```
///
/// When targeting those releases, instead make sure to statically provide those views within the constructor itself. The following will align the views correctly:
///
/// ```swift
/// Concentric {
///     A()
///     B()
///     C()
/// }
/// ```
public struct Concentric: View {
    enum Content {
        case shimmed(ConcentricViews)
        case regular(AnyView)
    }
    let content: Content
    
    /// Creates a concentric container that aligns all subviews specified in its view builder.
    ///
    /// Any view that is not a singular container will have its contents expanded and aligned, similar to how a `Form` extracts subviews row by row.
    ///
    /// > Note: This constructor requires Apple OS releases from Fall 2024 or later. For more limited functionality, your code will be directed to use ``init(erasing:)`` instead if it uses a deployment target prior to iOS 18, macOS 15, visionOS 2, and related releases.
    @available(
        iOS 18,
        macOS 15,
        tvOS 18,
        watchOS 11,
        visionOS 2, *
    )
    public init(@ViewBuilder subviews: () -> some View) {
        self.content = .regular(AnyView(subviews()))
    }
    
    /// Creates a concentric container that aligns all subviews specified in the provided closure, erasing their identities.
    ///
    /// This constructor takes a closure that works similarly to one provided to a [`ViewBuilder`](https://developer.apple.com/documentation/swiftui/viewbuilder). It will be able to extract and align subviews on releases before the API to iterate subview contents was made available.
    ///
    /// ### Backdeployment
    ///
    /// To support prior releases, this constructor is unable unpack subviews that are themselves wrapped in another view. For example, the following example may not work when targeting a release that causes this constructor to be invoked:
    ///
    /// ```swift
    /// struct MyViews: View {
    ///     var body: some View {
    ///         A()
    ///         B()
    ///         C()
    ///     }
    /// }
    ///
    /// …
    ///
    /// Concentric {
    ///     MyViews()
    /// }
    /// ```
    ///
    /// To avoid issues, when you use this constructor, make sure to statically provide those views within the constructor itself. The following will align the views correctly:
    ///
    /// ```swift
    /// Concentric {
    ///     A()
    ///     B()
    ///     C()
    /// }
    /// ```
    ///
    /// > Note: The above syntax will be compiled to invoke ``init(subviews:)`` instead if your deployment target is set to at least iOS 18, macOS 15, and related OSes, which does not have this issue.
    @_disfavoredOverload
    public init(@_IterableViewBuilder erasing subviews: () -> [AnyView]) {
        self.content = .shimmed(ConcentricViews(views: subviews()))
    }
    
    func placing(_ view: some View, in geometry: _GeometryProxy) -> some View {
        let size = geometry.size
        
        return view
            .frame(maxWidth: size.width, maxHeight: size.height, alignment: .center)
#if os(visionOS)
            .frame(maxDepth: size.depth, alignment: .center)
#endif
    }
    
    public var body: some View {
        _GeometryReader { geometry in
            switch content {
            case .shimmed(let concentricViews):
                ForEach(concentricViews.views) { concentricView in
                    placing(concentricView, in: geometry)
                }
                
            case .regular(let anyView):
                if #available(iOS 18, macOS 15, tvOS 18, watchOS 11, visionOS 2, *) {
                    ForEach(subviews: anyView) { subview in
                        placing(subview, in: geometry)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
#if os(visionOS)
        .frame(maxDepth: .infinity)
#endif
    }
}

struct ConcentricView: View, Identifiable {
    let id: Int
    let body: AnyView
}

@MainActor
struct ConcentricViews {
    let views: [ConcentricView]
    init(views: [AnyView]) {
        self.views = views.enumerated().map {
            ConcentricView(id: $0.offset, body: $0.element)
        }
    }
}

@resultBuilder
enum _IterableViewBuilder: _ElementsBuilder {
    typealias Element = AnyView
    static func buildExpression(_ expression: some View) -> [Self.Element] {
        [AnyView(expression)]
    }
}

#Preview {
    Concentric {
        Envelopment {
            for placement in Envelopment.Placement.allCases {
                EnvelopmentFace(placement: placement) {
                    Rectangle()
                        .foregroundColor(.blue.opacity(0.15))
                        .border(.cyan)
                }
            }
        }
        
        Concentric {
            Rectangle()
                .frame(width: 200, height: 500)
                .foregroundStyle(.red)
            
            Rectangle()
                .frame(width: 450, height: 300)
                .foregroundStyle(.blue)
            
            Circle()
                .frame(width: 400, height: 400)
                .foregroundStyle(.yellow)
            
            Envelopment {
                for placement in Envelopment.Placement.allCases {
                    EnvelopmentFace(placement: placement) {
                        Rectangle()
                            .foregroundColor(.green.opacity(0.15))
                            .border(.green)
                    }
                }
            }
            .frame(width: 320, height: 320)
#if os(visionOS)
            .frame(depth: 320)
#endif
        }
    }
}

#Preview("Concentric — Shimming subview iteration") {
    Concentric(erasing: {
        Envelopment {
            for placement in Envelopment.Placement.allCases {
                EnvelopmentFace(placement: placement) {
                    Rectangle()
                        .foregroundColor(.blue.opacity(0.15))
                        .border(.cyan)
                }
            }
        }
        
        Concentric {
            Rectangle()
                .frame(width: 200, height: 500)
                .foregroundStyle(.red)
            
            Rectangle()
                .frame(width: 450, height: 300)
                .foregroundStyle(.blue)
            
            Circle()
                .frame(width: 400, height: 400)
                .foregroundStyle(.yellow)
            
            Envelopment {
                for placement in Envelopment.Placement.allCases {
                    EnvelopmentFace(placement: placement) {
                        Rectangle()
                            .foregroundColor(.green.opacity(0.15))
                            .border(.green)
                    }
                }
            }
            .frame(width: 320, height: 320)
#if os(visionOS)
            .frame(depth: 320)
#endif
        }
    })
}

#endif
