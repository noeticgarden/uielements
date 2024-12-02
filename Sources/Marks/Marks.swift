
#if canImport(SwiftUI)
import SwiftUI
import UIElements
import Spatial

/// Marks are geometric elements that can be highlighted to the user by a ``MarksView``.
///
/// Each mark has a ``location-swift.property`` that indicates the placement and area of the screen that this mark intends to highlight. For example, show a point on a ``MarksView`` by creating a mark whose location is ``Location-swift.enum/point(_:)``. For example:
///
/// ```swift
/// let point = Mark.point(x: 10, y: 30)
/// ```
///
/// Each mark may represent a semantic element, such as a touch. These have different representations for the ``MarksView`` that displays them; for example, touches are displayed in a larger area so that they can be visible even if the user's hand is in the way.
///
/// Use the ``represents`` property to indicate that a mark has a specific semantic meaning:
///
/// ```swift
/// var mark = Mark.point(eventLocation)
/// mark.represents = .touch
/// ```
///
/// Marks are `Comparable` and sort in order of their ``maxZ`` value.
public struct Mark: Hashable, Sendable, Comparable {
    public static func < (lhs: Mark, rhs: Mark) -> Bool {
        lhs.maxZ < rhs.maxZ
    }
    
    /// Represents a location that can be marked.
    ///
    /// The coordinate system of a mark is the same as the one of the view that displays it.
    public enum Location: Hashable, Sendable {
        /// Marks a point in space.
        case point(Point3D)
    }
    
    /// The location where the mark will be displayed.
    public var location: Location

    /// Represents what a mark can indicate on screen.
    ///
    /// Set these values with the ``Mark/represents`` property. They will not change what is marked, but they will change how the mark will be represented.
    public enum Semantics: Hashable, Sendable {
        /// This mark represents the user touching a user interface element.
        case touch
    }
    
    /// Indicates what this mark represents.
    ///
    /// This will not change what is marked, but it will change how the mark will be represented by ``MarksView``.
    public var represents: Semantics?
    
    /// The minimum Y value of the mark's location.
    public var minY: Double {
        switch location {
        case .point(let point3D):
            point3D.y
        }
    }
    
    /// The maximum Z value of the mark's location.
    ///
    /// Marks sort by maximum Z value.
    public var maxZ: Double {
        switch location {
        case .point(let point3D):
            point3D.z
        }
    }
    
    /// Creates a point mark at the specified location.
    public static func point(_ point: Point3D, represents semantics: Semantics? = nil) -> Self {
        .init(location: .point(point), represents: semantics)
    }
    
    /// Creates a point mark at the specified coordinates.
    public static func point(x: CGFloat = 0, y: CGFloat = 0, z: CGFloat = 0, represents semantics: Semantics? = nil) -> Self {
        .init(location: .point(Point3D(x: x, y: y, z: z)), represents: semantics)
    }
    
    /// Creates a point mark at the location specified by the vector.
    public static func point(_ point: some ThreeComponentVector<Double>, represents semantics: Semantics? = nil) -> Self {
        .init(location: .point(Point3D(componentsOf: point)), represents: semantics)
    }
    
    /// Creates a point mark at the location specified by the vector.
    public static func point<F: BinaryFloatingPoint>(_ point: some ThreeComponentVector<F>, represents semantics: Semantics? = nil) -> Self {
        return .init(location: .point(Point3D(componentsOf: point.map { Double($0) })), represents: semantics)
    }
    
    /// Creates a point mark at the location specified by the vector.
    public static func point<F: BinaryFloatingPoint>(_ point: some TwoComponentVector<F>, represents semantics: Semantics? = nil) -> Self {
        return .init(location: .point(Point3D(componentsOf: point.map { Double($0) }, missing: 0)), represents: semantics)
    }
}

/// A collection of marks to be displayed by a ``MarksView``.
///
/// Mark collections are similar to dictionaries. Use this type to indicate which marks may be visible in a ``MarksView``. Each mark in a marks collection is identified using a `Hashable` value, and you can insert or remove those marks by using the collection's ``subscript(_:)``. If you have marks that are always displayed, you can use the ``init(marks:)`` constructor to supply them in the form of one or more ``IdentifiedMark``s.
///
/// Multiple sources can contribute to a single marks collection. For example, if you use the ``ExperimentalViewMethods/marksSpatialEvents(coordinateSpace:amongst:)`` modifier, it will add and remove its own marks to the collection. To ensure you do not conflict with other users of the collection, define your own specific `Hashable` type. For example:
///
/// ```swift
/// enum MyMarks: Hashable {
///     case topLeading
///     case bottomTrailing
/// }
///
/// let marks = Marks {
///     IdentifiedMark(id: MyMarks.topLeading,
///         mark: .point(topLeadingPoint))
///     IdentifiedMark(id: MyMarks.bottomTrailing,
///         mark: .point(topLeadingPoint))
/// }
/// ```
///
public struct Marks: Hashable {
    /// The base type of the storage of the marks collection.
    public typealias Values = [AnyHashable: Mark]
    
    /// The core storage of the marks collection.
    public var values: Values
    
    /// Retrieves and sets marks in this collection by key.
    public subscript(key: some Hashable) -> Mark? {
        get { values[key] }
        set { values[key] = newValue }
    }
    
    /// Creates a marks collection from a dictionary of marks keyed by their identifiers.
    public init(_ values: [AnyHashable : Mark] = [:]) {
        self.values = values
    }
    
    /// Returns the set of identifier keys for values in this collection.
    ///
    /// Retrieve the corresponding values by passing the keys to ``subscript(_:)``.
    public var keys: Values.Keys {
        return values.keys
    }
    
    /// Returns the set of marks contained in this collection.
    ///
    /// These marks are not identified. Use the ``identifiedMarks`` property to retrieve both marks and their associated identifiers.
    public var marks: Values.Values {
        return values.values
    }
    
    /// Returns whether this marks container has a mark associated to the specified key.
    public func contains(_ key: some Hashable) -> Bool {
        return values[key] != nil
    }
    
    /// Removes the given key from the marks container, and the associated mark, if there was one.
    public mutating func removeValue(for key: some Hashable) {
        self[key] = nil
    }
    
    /// Removes the given identified mark from the collection, if it was present.
    ///
    /// The mark whose identifier key is the same as the mark you provide will be removed, even if it's not equal to the mark in the collection.
    public mutating func remove(_ mark: IdentifiedMark) {
        self.removeValue(for: mark.id)
    }
    
    /// Removes all marks whose keys are of the specified type.
    public mutating func removeAll<T>(keyedBy type: T.Type) {
        for key in keys {
            if key.base is T {
                values.removeValue(forKey: key)
            }
        }
    }
    
    /// Removes all marks whose keys are of the specified type, and that match the condition indicated.
    public mutating func removeAll<T>(keyedBy type: T.Type, where condition: (_ key: T, _ mark: Mark) -> Bool) {
        for (key, value) in values {
            if let typedKey = key.base as? T, condition(typedKey, value) {
                values.removeValue(forKey: key)
            }
        }
    }
}

/// A mark with an associated identifier, used by a ``Marks`` collection.
///
/// Use the ``mark`` property to get the original mark.
///
/// Identified marks are `Comparable`, and are sorted the same as their contained marks. See ``Mark`` for more information on intrinsic order.
public struct IdentifiedMark: Identifiable, Comparable {
    public static func < (lhs: IdentifiedMark, rhs: IdentifiedMark) -> Bool {
        lhs.mark < rhs.mark
    }
    
    /// The identifier associated with the mark.
    public var id: AnyHashable
    /// The mark that was associated with an identifier.
    public var mark: Mark
    
    /// Creates a new identified mark, associating a mark and the identifier you provide.
    ///
    /// Use this initializer with the ``Marks/init(marks:)`` constructor to quickly create a collection of known marks.
    public init(id: some Hashable, mark: Mark) {
        self.id = id
        self.mark = mark
    }
}

/// A marks builder is used by the ``Marks`` collection to quickly initialize to a set of identified marks.
///
/// Use the ``Marks/init(marks:)`` constructor to build such a collection.
@resultBuilder
enum MarksBuilder: _ElementsBuilder {
    typealias Element = IdentifiedMark
}

extension Marks {
    /// Creates a marks collection with the specified contents.
    ///
    /// Use one or more ``IdentifiedMark``s in the closure to indicate the contents of this collection. For example:
    ///
    /// ```swift
    /// let marks = Marks {
    ///     IdentifiedMark(id: MyMarks.center,
    ///         mark: .point(center))
    ///
    ///     if let topLeading {
    ///         IdentifiedMark(id: MyMarks.topLeading,
    ///             mark: .point(topLeading))
    ///     }
    ///     if let bottomTrailing {
    ///         IdentifiedMark(id: MyMarks.topLeading,
    ///             mark: .point(bottomTrailing))
    ///     }
    /// }
    /// ```
    public init(@MarksBuilder marks: () -> [IdentifiedMark]) {
        self.init(
            Dictionary(marks().map { ($0.id, $0.mark) },
                       uniquingKeysWith: { old, new in new })
        )
    }
    
    /// Creates a marks collection from the specified sequence of identified marks.
    ///
    /// If one or more marks have the same identifier, the one that comes later in the list will be in the collection, and the other 
    public init(_ marks: some Sequence<IdentifiedMark>) {
        self.init(
            Dictionary(marks.map { ($0.id, $0.mark) },
                       uniquingKeysWith: { old, new in new })
        )
    }
    
    /// Returns the set of identified marks that are contained in this collection.
    ///
    /// The returned values are not ordered.
    public var identifiedMarks: [IdentifiedMark] {
        values.map { key, value in
            IdentifiedMark(id: key, mark: value)
        }
    }
}

extension Marks: Sequence {
    public typealias Element = Values.Element
    
    public func makeIterator() -> Values.Iterator {
        values.makeIterator()
    }
}

#endif
