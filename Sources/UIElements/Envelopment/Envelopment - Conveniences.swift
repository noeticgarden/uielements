
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
    ///         .foregroundStyle(.red.opacity(0.15))
    /// }
    /// ```
    ///
    /// Return `EmptyView()` to skip placing a view in the specified placement.
    ///
    /// The envelopment you construct this way will adapt to showing only the back face when its depth is zero. Use the ``SwiftUICore/View/envelopmentZeroDepthAdaptation(_:)`` modifier to change this behavior.
    public init(preferring orientation: Orientation = .inward, @ViewBuilder eachSide faceContent: @escaping (Envelopment.Placement) -> some View) {
        self.init {
            for placement in Placement.allCases(preferring: orientation) {
                EnvelopmentFace(placement: placement) {
                    faceContent(placement)
                }
            }
        }
    }
    
    /// Creates an envelopment by providing a view for each of the specified placements.
    ///
    /// The `faceContent` closure will be invoked with each placement in the `placements` you provide that corresponds to the `orientation` you specify. (If you specify `nil`, all placements you provide will be used.) If any of the placements you pass support only one orientation, you will be asked for a view for them for the one orientation they possess, even if it doesn't match your `orientation` preference.
    ///
    /// Use this constructor to set multiple similar subviews. For example, you could return the same view for all placements you specify:
    ///
    /// ```swift
    /// Envelopment(placements: .vertical) { _ in
    ///     Rectangle()
    ///         .foregroundStyle(.red.opacity(0.15))
    /// }
    /// ```
    ///
    /// Return `EmptyView()` to dynamically skip placing a view in the specified placement.
    ///
    /// The envelopment you construct this way will adapt to showing only the back face when its depth is zero. Use the ``SwiftUICore/View/envelopmentZeroDepthAdaptation(_:)`` modifier to change this behavior.
    public init(placements: Placements, preferring orientation: Orientation? = .inward,  @ViewBuilder eachSide faceContent: @escaping (Envelopment.Placement) -> some View) {
        var allPlacements = placements
        if let orientation {
            allPlacements.prefer(orientation)
        }
        
        self.init { [allPlacements] in
            for placement in allPlacements {
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

extension Envelopment {
    /// A set of any number of ``Placement`` values.
    ///
    /// Use this as an input to ``Envelopment/init(placements:preferring:eachSide:)``, or to your own code that operates with a set of ``Placement`` values.
    public struct Placements: Sendable, Hashable {
        var contents: Set<Placement> = []
        
        /// Creates a set of no placements.
        public init() {}
        
        /// Creates a set that contains the placements you provide.
        ///
        /// If the sequence contains a placement multiple times, the placement will be added only once.
        public init(_ placements: some Sequence<Placement>) {
            self.contents = Set(placements)
        }
        
        /// Creates a placement set that's the union of the two operands.
        public static func + (_ lhs: Self, _ rhs: some Sequence<Placement>) -> Self {
            lhs.union(.init(rhs))
        }
        
        /// Creates a placement set that contains the placement in the left operand that the right operand does not contain.
        public static func - (_ lhs: Self, _ rhs: some Sequence<Placement>) -> Self {
            var new = lhs
            for placement in rhs {
                new.remove(placement)
            }
            return new
        }
        
        /// Forms a union with another placement set.
        public static func += (_ lhs: inout Self, _ rhs: some Sequence<Placement>) {
            lhs.formUnion(.init(rhs))
        }
        
        /// Removes all placements in the right operand from the left operand.
        public static func - (_ lhs: inout Self, _ rhs: some Sequence<Placement>) {
            for placement in rhs {
                lhs.remove(placement)
            }
        }
    }
}

extension Envelopment.Placements: Sequence {
    public typealias Element = Envelopment.Placement
    
    public func makeIterator() -> Iterator {
        Iterator(proxied: contents.makeIterator())
    }
    
    public struct Iterator: IteratorProtocol {
        var proxied: Set<Envelopment.Placement>.Iterator
        
        public mutating func next() -> Envelopment.Placement? {
            proxied.next()
        }
    }
}

extension Envelopment.Placements: SetAlgebra {
    public func union(_ other: Envelopment.Placements) -> Envelopment.Placements {
        .init(self.contents.union(other.contents))
    }
    
    public func intersection(_ other: Envelopment.Placements) -> Envelopment.Placements {
        .init(self.contents.intersection(other.contents))
    }
    
    public func symmetricDifference(_ other: Envelopment.Placements) -> Envelopment.Placements {
        .init(self.contents.symmetricDifference(other.contents))
    }
    
    @discardableResult
    public mutating func insert(_ newMember: Envelopment.Placement) -> (inserted: Bool, memberAfterInsert: Envelopment.Placement) {
        self.contents.insert(newMember)
    }
    
    @discardableResult
    public mutating func remove(_ member: Envelopment.Placement) -> Envelopment.Placement? {
        self.contents.remove(member)
    }
    
    @discardableResult
    public mutating func update(with newMember: Envelopment.Placement) -> Envelopment.Placement? {
        self.contents.update(with: newMember)
    }
    
    public mutating func formUnion(_ other: Envelopment.Placements) {
        self.contents.formUnion(other.contents)
    }
    
    public mutating func formIntersection(_ other: Envelopment.Placements) {
        self.contents.formIntersection(other.contents)
    }
    
    public mutating func formSymmetricDifference(_ other: Envelopment.Placements) {
        self.contents.formSymmetricDifference(other.contents)
    }
}

extension Envelopment.Placements {
    /// A placement set that contains only ``Envelopment/Placement/back``.
    public static let back: Self = [.back]
    /// A placement set that contains only ``Envelopment/Placement/leading``.
    public static let leading: Self = [.leading]
    /// A placement set that contains only ``Envelopment/Placement/front``.
    public static let front: Self = [.front]
    /// A placement set that contains only ``Envelopment/Placement/trailing``.
    public static let trailing: Self = [.trailing]
    /// A placement set that contains only ``Envelopment/Placement/top``.
    public static let top: Self = [.top]
    /// A placement set that contains only ``Envelopment/Placement/bottom``.
    public static let bottom: Self = [.bottom]
    /// A placement set that contains only ``Envelopment/Placement/frontOutward``.
    public static let frontOutward: Self = [.frontOutward]
    
    /// A placement set that contains every possible placement.
    public static let all = Self.init(Envelopment.Placement.allCases)
    /// A placement set that contains every possible placement that is oriented vertically.
    public static let vertical: Self = [.back, .leading, .front, .trailing, .frontOutward]
    /// A placement set that contains every possible placement that is oriented horizontally.
    public static let horizontal: Self = [.top, .bottom]
    
    /// Returns a placement set of all orientations that match the provided orientation, for each orientation where that is possible.
    public func preferring(_ orientation: Envelopment.Orientation) -> Self {
        self.intersection(.init(Envelopment.Placement.allCases(preferring: orientation)))
    }
    
    /// Removes from the placement set all orientations that do not match the provided orientation, for each orientation where that is possible.
    public mutating func prefer(_ orientation: Envelopment.Orientation) {
        self.formIntersection(.init(Envelopment.Placement.allCases(preferring: orientation)))
    }
}

#endif
