
/// A unified protocol for operations on vector values.
///
/// The ``Vector`` type provides convenience API for types that represents vectors — fixed-order, fixed-count collections of heterogeneous elements. This allows you to operate on these vectors component by component without duplicating code, convert between different vector types with similar numbers of components, and perform multi-element math in a single call.
///
/// Each vector type has a ``Components`` type, which describes the order and name of each component of the vector. You can get and set values at specific indices of the vector by using ``subscript(_:)``.
///
/// You can create a vector conforming to this protocol by iterating over its components with the ``init(values:)`` constructor:
///
/// ```swift
/// let top, offset, inset: CGPoint
/// …
/// let result = CGPoint {
///     // Creates a value of this by
///     // operating on these values,
///     // component by component.
///     top[$0] + offset[$0] - inset[$0]
/// }
/// ```
public protocol Vector<Value> {
    /// A type that describes each component of this ``Vector`` type.
    ///
    /// Each component needs to be described by a distinct, different componnt value. For example, a `SIMD3` represents each component in turn with its ``Swift/SIMD3/Component/x``, ``Swift/SIMD3/Component/y``, and ``Swift/SIMD3/Component/z``.
    associatedtype Component: Hashable, Sendable
    /// The type of each component in this vector.
    associatedtype Value
    
    /// A type that provides an ordered list of components of this ``Vector`` type.
    associatedtype Components: Sequence<Component>
    /// The ordered list of components of this type.
    static var components: Components { get }
    
    /// Accesses or edits each component in the vector.
    subscript(component: Component) -> Value { get set }
    
    /// Provides a 'zero', initialized vector for common constructor use.
    static var zero: Self { get }
    
    /// Creates a new vector by providing a value for each component.
    init(values: (Component) throws -> Value) rethrows
}

extension Vector {
    public init(values: (Component) throws -> Value) rethrows {
        self = .zero
        for component in Self.components {
            self[component] = try values(component)
        }
    }
}

extension Vector where Component: CaseIterable, Components == Component.AllCases {
    public static var components: Component.AllCases {
        Component.allCases
    }
}

/// A convenience protocol for ``Vector``s, allowing default implementations to associates each component to a key path.
public protocol KeyPathVector: Vector {
    /// Returns the key path that corresponds to a specific component.
    static func keyPath(for component: Component) -> WritableKeyPath<Self, Value>
}

extension KeyPathVector {
    /// Provides a default implementation for reading and writing components that are stored in key paths, as long as the receiver conforms to the ``KeyPathVector`` protocol.
    public subscript(component: Component) -> Value {
        get {
            self[keyPath: Self.keyPath(for: component)]
        }
        set {
            self[keyPath: Self.keyPath(for: component)] = newValue
        }
    }
}

// -----

/// A vector that has exactly two components.
///
/// The vector's `Component` type must conform to ``TwoComponents``, which allows you to refer to the two components in this vector using ``TwoComponents/first`` and ``TwoComponents/second``.
public protocol TwoComponentVector<Value>: Vector where Component: TwoComponents {
    /// Creates a new two-element vector with the specified values in component order.
    init(values: (Value, Value))
}

/// The components of a two-component vector.
///
/// Vectors of the ``TwoComponentVector`` type must have their components type conform to this protocol.
public protocol TwoComponents {
    /// The distinct value that represents the first component in the vector.
    static var first:  Self { get }
    /// The distinct value that represents the second component in the vector.
    static var second: Self { get }
}

// -----

/// A vector that has exactly three components.
///
/// The vector's `Component` type must conform to ``ThreeComponents``, which allows you to refer to the two components in this vector using ``ThreeComponents/first``, ``ThreeComponents/second`` and ``ThreeComponents/third``.
public protocol ThreeComponentVector<Value>: Vector where Component: ThreeComponents {
    /// Creates a new three-element vector with the specified values in component order.
    init(values: (Value, Value, Value))
}

/// The components of a three-component vector.
///
/// Vectors of the ``ThreeComponentVector`` type must have their components type conform to this protocol.
public protocol ThreeComponents {
    /// The distinct value that represents the first component in the vector.
    static var first:  Self { get }
    /// The distinct value that represents the second component in the vector.
    static var second: Self { get }
    /// The distinct value that represents the third component in the vector.
    static var third:  Self { get }
}
