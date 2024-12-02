
/// Represents a vector transformed by a ``Vector/map(zero:_:)`` operation.
///
/// You don't usually interact with this type directly. You get a value of this type if you transform the components of a vector into a different type with the ``Vector/map(zero:_:)`` family of methods.
///
/// Use the ``Vector/init(componentsOf:missing:)`` constructor to turn values of this type into other specific vector types.
public struct TransformedVector<Original: Vector, Value, Zero: ZeroProvider>: Vector where Zero.Value == Value {
    var values: [Component: Value]
    
    public init(values: (Original.Component) throws -> Value) rethrows {
        var saved: [Component: Value] = [:]
        for component in Original.components {
            saved[component] = try values(component)
        }
        self.values = saved
    }
    
    public subscript(component: Original.Component) -> Value {
        get { values[component]! }
        set { values[component] = newValue }
    }
    
    public static var components: Original.Components {
        Original.components
    }
    
    public static var zero: TransformedVector<Original, Value, Zero> {
        Original.zero.map(zero: Zero.self) { _ in Zero.zero }
    }
}

/// A protocol that provides zero values for other types.
///
/// You don't usually interact with this protocol, unless you are working with ``Vector``s of non-numeric types.
///
/// Implement your conforming type to return a 'zero' value to initialize a ``Vector`` with via the ``zero`` property. For numeric values, this will usually be 0.
public protocol ZeroProvider {
    /// The value this provider can initialize.
    associatedtype Value
    
    /// The initial 'zero' value for the specified type.
    static var zero: Value { get }
}

public enum _BinaryIntegerZeroProvider<Value: BinaryInteger>: ZeroProvider {
    public static var zero: Value { .init(0) }
}

public enum _BinaryFloatingPointZeroProvider<Value: BinaryFloatingPoint>: ZeroProvider {
    public static var zero: Value { .init(0) }
}

extension TransformedVector: TwoComponentVector where Original: TwoComponentVector {
    public init(values: (Value, Value)) {
        self.values = [Original.Component.first: values.0, Original.Component.second: values.1]
    }
}

extension TransformedVector: ThreeComponentVector where Original: ThreeComponentVector {
    public init(values: (Value, Value, Value)) {
        self.values = [Original.Component.first: values.0, Original.Component.second: values.1, Original.Component.third: values.2]
    }
}

extension Vector {
    /// Creates a new vector by mapping each component to a new value.
    ///
    /// The vector will be of the same type as the receiver. Use another <doc:/documentation/UIElements/Vector/mapByComponent(_:)-9snf0> method to change the type of values in the receiver.
    public func mapByComponent(_ transform: (Value, Component) throws -> Value) rethrows -> Self {
        try Self.init { component in
            try transform(self[component], component)
        }
    }
    
    /// Creates a new vector by mapping each of its values to a new value.
    ///
    /// If you need to know what component each value is provided for, use <doc:/documentation/UIElements/Vector/mapByComponent(_:)-30tpf> instead.
    ///
    /// The vector will be of the same type as the receiver. Use another <doc:/documentation/UIElements/Vector/map(_:)-3qyrf> method to change the type of values in the receiver.
    public func map(_ transform: (Value) throws -> Value) rethrows -> Self {
        try mapByComponent { value, component in try transform(value) }
    }
    
    /// Creates a new vector by mapping each of its values to a new value of a different type.
    ///
    /// This method creates a vector of a different type than the receiver. Use the ``Vector/init(componentsOf:missing:)`` constructor with the result to pick a specific vector type.
    ///
    /// > Note: This method requires you to specify a provider for the `zero` values of the final result. You only need to call this if the resulting vector does not use a numeric type for its components. Use the <doc:/documentation/UIElements/Vector/mapByComponent(_:)-4v7y2> or <doc:/documentation/UIElements/Vector/mapByComponent(_:)-9snf0> methods for numeric types instead.
    public func mapByComponent<X, Z>(zero: Z.Type, _ transform: (Value, Component) throws -> X) rethrows -> TransformedVector<Self, X, Z> where Z: ZeroProvider, Z.Value == X {
        try TransformedVector { component in
            try transform(self[component], component)
        }
    }
    
    /// Creates a new vector by mapping each of its values to a new value of a different integer type.
    ///
    /// This method creates a vector of a different type than the receiver. Use the ``Vector/init(componentsOf:missing:)`` constructor with the result to pick a specific vector type.
    public func mapByComponent<X: BinaryInteger>(_ transform: (Value, Component) throws -> X) rethrows -> TransformedVector<Self, X, _BinaryIntegerZeroProvider<X>> {
        try mapByComponent(zero: _BinaryIntegerZeroProvider<X>.self, transform)
    }
    
    /// Creates a new vector by mapping each of its values to a new value of a different floating-point type.
    ///
    /// This method creates a vector of a different type than the receiver. Use the ``Vector/init(componentsOf:missing:)`` constructor with the result to pick a specific vector type.
    public func mapByComponent<X: BinaryFloatingPoint>(_ transform: (Value, Component) throws -> X) rethrows -> TransformedVector<Self, X, _BinaryFloatingPointZeroProvider<X>> {
        try mapByComponent(zero: _BinaryFloatingPointZeroProvider<X>.self, transform)
    }
    
    /// Creates a new vector by mapping each of its values to a new value of a different type.
    ///
    /// This method creates a vector of a different type than the receiver. Use the ``Vector/init(componentsOf:missing:)`` constructor with the result to pick a specific vector type.
    ///
    /// If you need to know what component each value is provided for, use ``mapByComponent(zero:_:)`` instead.
    ///
    /// > Note: This method requires you to specify a provider for the `zero` values of the final result. You only need to call this if the resulting vector does not use a numeric type for its components. Use the <doc:/documentation/UIElements/Vector/map(_:)-5cdi5> or <doc:/documentation/UIElements/Vector/map(_:)-3qyrf> methods for numeric types instead.
    public func map<X, Z>(zero: Z.Type, _ transform: (Value) throws -> X) rethrows -> TransformedVector<Self, X, Z> where Z: ZeroProvider, Z.Value == X {
        try mapByComponent(zero: zero) { value, _ in
            try transform(value)
        }
    }
    
    /// Creates a new vector by mapping each of its values to a new value of a different integer type.
    ///
    /// This method creates a vector of a different type than the receiver. Use the ``Vector/init(componentsOf:missing:)`` constructor with the result to pick a specific vector type.
    ///
    /// If you need to know what component each value is provided for, use <doc:/documentation/UIElements/Vector/mapByComponent(_:)-4v7y2> instead.
    public func map<X: BinaryInteger>(_ transform: (Value) throws -> X) rethrows -> TransformedVector<Self, X, _BinaryIntegerZeroProvider<X>> {
        try map(zero: _BinaryIntegerZeroProvider<X>.self, transform)
    }
    
    /// Creates a new vector by mapping each of its values to a new value of a different floating-point type.
    ///
    /// This method creates a vector of a different type than the receiver. Use the ``Vector/init(componentsOf:missing:)`` constructor with the result to pick a specific vector type.
    ///
    /// If you need to know what component each value is provided for, use <doc:/documentation/UIElements/Vector/mapByComponent(_:)-4v7y2> instead.
    public func map<X: BinaryFloatingPoint>(_ transform: (Value) throws -> X) rethrows -> TransformedVector<Self, X, _BinaryFloatingPointZeroProvider<X>> {
        try map(zero: _BinaryFloatingPointZeroProvider<X>.self, transform)
    }
    
    /// Edits each of the components of the vector in turn.
    ///
    /// The return value of the `transform` closure will be used to update the receiver.
    ///
    /// The closure can throw an error. If any calls throw an error, the receiver will be left unmodified.
    public mutating func editByComponent(_ transform: (Value, Component) throws -> Value) rethrows {
        var me = self
        for component in Self.components {
            me[component] = try transform(self[component], component)
        }
        self = me
    }
    
    /// Edits each of the values of the vector in turn.
    ///
    /// The return value of the `transform` closure will be used to update the receiver. If you need to know what component each value is provided for, use ``editByComponent(_:)`` instead.
    ///
    /// The closure can throw an error. If any calls throw an error, the receiver will be left unmodified.
    public mutating func edit(_ transform: (Value) throws -> Value) rethrows {
        try editByComponent { value, _ in
            try transform(value)
        }
    }
    
    /// Creates a new vector by enumerating each of the components in turn.
    ///
    /// This is similar to the <doc:/documentation/UIElements/Vector/init(values:)-4ipqw> constructor, except it provides an `offset` parameter. It is the enumeration index of the component in the order of components.
    public init(enumerating byComponent: (_ offset: Int, _ component: Component) throws -> Value) rethrows {
        var index = 0
        try self.init { component in
            let result = try byComponent(index, component)
            index += 1
            return result
        }
    }
}

extension Vector where Value: BinaryFloatingPoint {
    /// Adds two vectors together, component by component.
    public static func + (_ lhs: Self, _ rhs: Self) -> Self {
        Self.init {
            lhs[$0] + rhs[$0]
        }
    }
    
    /// Subtracts two vectors together, component by component.
    public static func - (_ lhs: Self, _ rhs: Self) -> Self {
        Self.init {
            lhs[$0] - rhs[$0]
        }
    }
    
    /// Adds the second vector to the first, component by component.
    public static func += (_ lhs: inout Self, _ rhs: Self) {
        lhs.editByComponent {
            $0 + rhs[$1]
        }
    }
    
    /// Subtracts the second vector to the first, component by component.
    public static func -= (_ lhs: inout Self, _ rhs: Self) {
        lhs.editByComponent {
            $0 - rhs[$1]
        }
    }
    
    /// Creates a new vector, multiplying each component in the left operand by a constant.
    public static func * (_ lhs: Self, _ rhs: Value) -> Self {
        lhs.map {
            $0 * rhs
        }
    }
    
    /// Creates a new vector, dividing each component in the left operand by a constant.
    public static func / (_ lhs: Self, _ rhs: Value) -> Self {
        lhs.map {
            $0 / rhs
        }
    }
    
    /// Multiplies each component in the left operand by a constant.
    public static func *= (_ lhs: inout Self, _ rhs: Value) {
        lhs.edit {
            $0 * rhs
        }
    }

    /// Divides each component in the left operand by a constant.
    public static func /= (_ lhs: inout Self, _ rhs: Value) {
        lhs.edit {
            $0 / rhs
        }
    }
}

extension Vector {
    /// Creates a new vector by taking as many components from another vector as needed.
    ///
    /// Only use this constructor with a vector with equal or more components than this type. If you do not, you will get a runtime precondition failure. If you are not sure about the number of components in the other type, use <doc:/documentation/UIElements/Vector/init(componentsOf:missing:)>.
    public init<V: Vector>(truncating vector: V) where V.Value == Value {
        let components = Array(V.components)
        self.init { offset, component in
            if offset < components.count {
                vector[components[offset]]
            } else {
                preconditionFailure("The vector must have more or equal components than the vector you're attempting to create.")
            }
        }
    }
    
    /// Creates a new vector from the components of another.
    ///
    /// If the vector has fewer components than needed, the rest of the vector will be filled with the `default` value you provide.
    public init<V: Vector>(componentsOf vector: V, missing default: Value) where V.Value == Value {
        let components = Array(V.components)
        self.init { offset, component in
            if offset < components.count {
                vector[components[offset]]
            } else {
                `default`
            }
        }
    }
    
    /// Creates a new vector by taking exactly as many components as needed from the other vector.
    ///
    /// If there are not enough components in the other vector, this will return `nil`.
    public init?<V: Vector>(exactlyComponentsOf vector: V) where V.Value == Value {
        let components = Array(V.components)
        do {
            try self.init { offset, component in
                if offset < components.count {
                    vector[components[offset]]
                } else {
                    throw NotEnoughComponentsError()
                }
            }
        } catch {
            return nil
        }
    }
}

private struct NotEnoughComponentsError: Error {}

extension TwoComponentVector {
    /// Creates a new vector by taking two components from another two-component vector.
    ///
    /// This is equivalent to <doc:/documentation/UIElements/TwoComponentVector/init(componentsOf:)>.
    public init<V: TwoComponentVector<Value>>(truncating vector: V) {
        self.init(componentsOf: vector)
    }
    
    /// Creates a new vector by taking the first two components from another three-component vector.
    public init<V: ThreeComponentVector<Value>>(truncating vector: V) {
        self.init(values: (vector[.first], vector[.second]))
    }
    
    /// Creates a new vector by taking the first two components from another two-component vector.
    public init<V: TwoComponentVector<Value>>(componentsOf vector: V) {
        self.init(values: (vector[.first], vector[.second]))
    }
    
    /// Creates a new vector by taking two components from another two-component vector.
    ///
    /// This is equivalent to <doc:/documentation/UIElements/TwoComponentVector/init(componentsOf:)>.
    public init<V: TwoComponentVector<Value>>(exactlyComponentsOf vector: V){
        self.init(componentsOf: vector)
    }
}

extension ThreeComponentVector {
    /// Creates a new vector from the components of another two-component vector.
    ///
    /// The vector's third component will be filled with the `default` value you provide.
    public init<V: TwoComponentVector>(componentsOf vector: V, missing default: Value) where V.Value == Value {
        self.init(values: (vector[.first], vector[.second], `default`))
    }
    
    /// Creates a new vector by taking three components from another three-component vector.
    ///
    /// This is equivalent to <doc:/documentation/UIElements/ThreeComponentVector/init(componentsOf:)>.
    public init<V: ThreeComponentVector<Value>>(truncating vector: V) {
        self.init(componentsOf: vector)
    }
    
    /// Creates a new vector by taking three components from another three-component vector.
    public init<V: ThreeComponentVector<Value>>(componentsOf vector: V) {
        self.init(values: (vector[.first], vector[.second], vector[.third]))
    }
    
    /// Creates a new vector by taking three components from another three-component vector.
    ///
    /// This is equivalent to <doc:/documentation/UIElements/ThreeComponentVector/init(componentsOf:)>.
    public init<V: ThreeComponentVector<Value>>(exactlyComponentsOf vector: V){
        self.init(componentsOf: vector)
    }
}

extension TwoComponents {
    /// Returns the component of this type that is at the same relative position as the component you passed.
    static func matching<C: TwoComponents & Equatable>(_ component: C) -> Self {
        switch component {
        case .first:
            return .first
            
        case .second:
            return .second
            
        default:
            fatalError()
        }
    }
    
    /// Returns the component of this type that is at the same relative position as the component you passed.
    ///
    /// If there's no such component, it will return `nil`.
    static func matching<C: ThreeComponents & Equatable>(_ component: C) -> Self? {
        switch component {
        case .first:
            return .first
            
        case .second:
            return .second
            
        default:
            return nil
        }
    }
}

extension ThreeComponents {
    /// Returns the component of this type that is at the same relative position as the component you passed.
    static func matching<C: TwoComponents & Equatable>(_ component: C) -> Self {
        switch component {
        case .first:
            return .first
            
        case .second:
            return .second
            
        default:
            fatalError()
        }
    }
    
    /// Returns the component of this type that is at the same relative position as the component you passed.
    static func matching<C: ThreeComponents & Equatable>(_ component: C) -> Self {
        switch component {
        case .first:
            return .first
            
        case .second:
            return .second
            
        case .third:
            return .third
            
        default:
            fatalError()
        }
    }
}

extension TwoComponentVector {
    /// Accesses or edits the component that's at the matching position in this vector as the component you provide.
    public subscript<C: TwoComponents & Equatable>(matching component: C) -> Value {
        get {
            self[Component.matching(component)]
        }
        set {
            self[Component.matching(component)] = newValue
        }
    }
    
    /// Accesses or edits the component that's at the matching position in this vector as the component you provide.
    ///
    /// Returns `nil` if the component does not have a matching component. Trying to set a component to `nil` or to a component that doesn't have a matching position in this vector has no effect.
    public subscript<C: ThreeComponents & Equatable>(matching component: C) -> Value? {
        get {
            Component.matching(component).flatMap { self[$0] }
        }
        set {
            if let mine = Component.matching(component),
               let newValue {
                self[mine] = newValue
            }
        }
    }
}

extension ThreeComponentVector {
    /// Accesses or edits the component that's at the matching position in this vector as the component you provide.
    public subscript<C: TwoComponents & Equatable>(matching component: C) -> Value {
        get {
            self[Component.matching(component)]
        }
        set {
            self[Component.matching(component)] = newValue
        }
    }
    
    /// Accesses or edits the component that's at the matching position in this vector as the component you provide.
    public subscript<C: ThreeComponents & Equatable>(matching component: C) -> Value {
        get {
            self[Component.matching(component)]
        }
        set {
            self[Component.matching(component)] = newValue
        }
    }
}
