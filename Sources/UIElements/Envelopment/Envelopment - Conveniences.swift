
#if canImport(SwiftUI)
import SwiftUI

extension Envelopment {
    /// Represents the orientation of a view placed on the bounds of the envelopment.
    public enum Orientation: Hashable, Sendable {
        /// The view is oriented toward the center of the envelopment.
        case inward
        /// The view is oriented toward the outside of the envelopment.
        case outward
    }
    
    /// Creates an envelopment by providing a view for each possible placement.
    ///
    /// The `faceContent` closure will be invoked with each placement that corresponds to the `orientation` you specify. Some placement may support only one orientation; if so, you will be asked for a view for them for the one orientation they possess, even if it doesn't match your preference.
    ///
    /// Use this constructor to set multiple similar subviews. For example, you could return the same view for all placements:
    ///
    /// ```swift
    /// Envelopment { _ in
    ///     Rectangle()
    ///         .foregroundStyle(.red.opacity(0.15)
    /// }
    /// ```
    ///
    /// Return `EmptyView()` to skip placing a view in the specified placement.
    ///
    /// By default, if set to have no depth, the envelopment will adapt to showing only the back face if constructed using this constructor. Use the ``SwiftUICore/View/envelopmentZeroDepthAdaptation(_:)`` modifier to change this behavior.
    public init(preferring orientation: Orientation = .inward, @ViewBuilder eachSide faceContent: @escaping (Envelopment.Placement) -> some View) {
        self.init {
            for placement in Placement.allCases(preferring: orientation) {
                EnvelopmentFace(placement: placement) {
                    faceContent(placement)
                }
            }
        }
    }
}

extension Envelopment.Placement {
    /// Returns placements, preferring those that match the criteria you specify.
    ///
    /// If a placement has only one orientation available, it will be returned. If it supports both, only the placement whose orientation matches will be returned.
    ///
    /// For example, if `orientation` is ``Envelopment/Orientation/inward``, then ``front`` will be returned, but not ``frontOutward``; for ``Envelopment/Orientation/outward``, ``frontOutward`` will be returned, but not ``front``. All other placements will be returned.
    public static func allCases(preferring orientation: Envelopment.Orientation) -> some Sequence<Self> {
        allCases.filter {
            (orientation == .inward && $0 != .frontOutward) ||
            (orientation == .outward && $0 != .front)
        }
    }
}

#endif
