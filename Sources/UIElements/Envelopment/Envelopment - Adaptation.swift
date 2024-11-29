
#if canImport(SwiftUI)
import SwiftUI

enum EnvelopmentZeroDepthAdaptationKey: EnvironmentKey {
    static let defaultValue: Envelopment.Adaptation? = nil
}

extension EnvironmentValues {
    var envelopmentZeroDepthAdaptation: Envelopment.Adaptation? {
        get { self[EnvelopmentZeroDepthAdaptationKey.self] }
        set { self[EnvelopmentZeroDepthAdaptationKey.self] = newValue }
    }
}

extension View {
    /// Sets the behavior of an ``Envelopment`` when it is displayed with its depth set to zero.
    ///
    /// This behavior will apply when the view is displayed on a 2D screen, or when it is displayed in a 3D environment in visionOS but the depth of the view is set to zero.
    ///
    /// See the ``Envelopment/Adaptation`` type for what type of adaptation behaviors are available. If you pass `nil`, the default behavior will apply.
    public func envelopmentZeroDepthAdaptation(_ adaptation: Envelopment.Adaptation?) -> some View {
        environment(\.envelopmentZeroDepthAdaptation, adaptation)
    }
}

extension Envelopment {
    /// Determines how an ``Envelopment`` adapts when displayed with zero depth.
    ///
    /// Envelopments displayed with depth greater than zero on visionOS will display views on each of their faces. When they have their depth set to zero, or when they are displayed in a 2D view hierarchy (for example, on iOS or macOS), they will adapt their display accordingly.
    ///
    /// By default:
    ///
    /// - Using the ``init(subviews:)-1mb6`` constructor, without ``State``, will adapt by only ever showing the back face and hiding all faces, including the front. This is the simplest behavior, and only shows to the user the face aligned to them.
    ///
    /// - Using the ``init(subviews:)-3fr0w`` constructor, receiving a ``State``, will adapt by simulating an isometric frontal view of the contents of the envelopment. This means that the back and front views will show to the user, with the front view flipped horizontally. You can use the ``State/hasDepth`` property of that `State` to customize the display of those views and adapt them manually to the situation at hand.
    ///
    /// If neither works for you, you can alter the behavior of an envelopment by using the ``SwiftUICore/View/envelopmentZeroDepthAdaptation(_:)`` and specifying a value of this type.
    public enum Adaptation: Hashable, Sendable {
        /// Adapts to an environment with zero depth by showing only one face's view on the back surface of the envelopment.
        ///
        /// If the face you select is not ``Envelopment/Placement/back``, this will replace the back face's view, if any. It will be oriented toward the user, not rotated, with the origin at the envelopment's origin.
        ///
        /// This behavior with the ``Envelopment/Placement/back`` placement is the default behavior for envelopments constructed with the ``Envelopment/init(subviews:)-1mb6`` constructor.
        case showsSingleFace(Envelopment.Placement)
        
        /// Adapts to an environment with zero depth by simulating the isometric projection of the front view of the envelopment.
        ///
        /// This will show two views: the view on the back face, and the view on the front face, flipped to simulate the positioning it would have facing inward on the front face. Other views will be hidden.
        ///
        /// This behavior is the default behavior for envelopments constructed with the ``Envelopment/init(subviews:)-3fr0w`` constructor.
        case simulatesFrontView
    }
}

#endif
