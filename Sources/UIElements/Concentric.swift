
#if canImport(SwiftUI)
import SwiftUI
import Spatial

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
/// > Note: This container has an ideal size equal to the size of its subviews. If you need it to fill more space, use the [`frame`](https://developer.apple.com/documentation/swiftui/view/frame(minwidth:idealwidth:maxwidth:minheight:idealheight:maxheight:alignment:)) family of modifiers to set its maximum dimensions to `.infinity`. (This is a change in [v0.2.2](doc:What's-New).)
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
#if compiler(>=6)
        case regular(AnyView)
#endif
    }
    let content: Content
    
    #if compiler(>=6)
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
    #endif
    
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
    
    func placing(_ view: some View, id: AnyHashable, in geometry: _Shims.GeometryProxy) -> some View {
        let size = geometry.size
        
        return view
            .modifier(_SizeExfiltrator { newSize in
                sizeCatcher.sizes[id] = newSize
            })
            .frame(maxWidth: size.width, maxHeight: size.height, alignment: .center)
#if os(visionOS)
            .frame(maxDepth: size.depth, alignment: .center)
#endif
    }
    
    @StateObject var sizeCatcher = SizeCatcher()
    
    public var body: some View {
        var keys: Set<AnyHashable> = []
        
        _Shims.GeometryReader { geometry in
            switch content {
            case .shimmed(let concentricViews):
                {
                    keys = Set(concentricViews.views.map { $0.id })
                    return EmptyView()
                }()
                
                ForEach(concentricViews.views) { concentricView in
                    placing(concentricView, id: concentricView.id, in: geometry)
                }
                
#if compiler(>=6)
            case .regular(let anyView):
                if #available(iOS 18, macOS 15, tvOS 18, watchOS 11, visionOS 2, *) {
                    ForEach(subviews: anyView) { subview in
                        {
                            keys.insert(subview.id)
                            return EmptyView()
                        }()
                        
                        placing(subview, id: subview.id, in: geometry)
                    }
                }
#endif
            }
            
            {
                Task { @MainActor in
                    sizeCatcher.keys = keys
                }
                return EmptyView()
            }()
        }
        .frame(idealWidth: sizeCatcher.maximumSize?.width ?? .infinity,
               idealHeight: sizeCatcher.maximumSize?.height ?? .infinity)
#if os(visionOS)
        .frame(idealDepth: sizeCatcher.maximumSize?.depth ?? .infinity)
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

@MainActor
final class SizeCatcher: ObservableObject {
    @Published var keys: Set<AnyHashable> = [] {
        didSet {
            for key in sizes.keys {
                if !self.keys.contains(key) {
                    sizes[key] = nil
                }
            }
        }
    }
    
    @Published var sizes: [AnyHashable: Size3D] = [:]
    
    var maximumSize: Size3D? {
        guard !sizes.isEmpty else {
            return nil
        }
        
        let result = sizes.reduce(.zero) { partialResult, next in
            Size3D(width: max(partialResult.width, next.value.width),
                   height: max(partialResult.height, next.value.height),
                   depth: max(partialResult.depth, next.value.depth))
        }
        
        return result
    }
}

#if compiler(>=6) // Require Xcode 16's SDKs for previews.
#Preview {
    HStack {
        ForEach(0..<6) { _ in
            Concentric {
                Rectangle()
                    .frame(width: 100, height: 200)
                    .foregroundStyle(.red)
                    .fixedSize()
                
                Rectangle()
                    .frame(width: 150, height: 100)
                    .foregroundStyle(.blue)
                
                Circle()
                    .frame(width: 80, height: 80)
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
                .frame(width: 120, height: 120)
#if os(visionOS)
                .frame(depth: 120)
#endif
            }
        }
    }
}

#Preview("Concentric — Shimming subview iteration") {
    HStack {
        ForEach(0..<6) { _ in
            Concentric {
                Rectangle()
                    .frame(width: 100, height: 200)
                    .foregroundStyle(.red)
                    .fixedSize()
                
                Rectangle()
                    .frame(width: 150, height: 100)
                    .foregroundStyle(.blue)
                
                Circle()
                    .frame(width: 80, height: 80)
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
                .frame(width: 120, height: 120)
#if os(visionOS)
                .frame(depth: 120)
#endif
            }
        }
    }
}
#endif // compiler(>=6)

#endif
