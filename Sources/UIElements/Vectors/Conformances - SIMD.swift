
extension SIMD2: Vector where Scalar: ExpressibleByIntegerLiteral {}
extension SIMD2: TwoComponentVector, KeyPathVector where Scalar: ExpressibleByIntegerLiteral {
    public typealias Value = Scalar
    
    public static var zero: Self {
        .init(x: 0, y: 0)
    }
    
    // Swift 5.10 requires an explicit typealias:
    public typealias Components = Component.AllCases
    
    
    /// The components of a `SIMD2`, for ``TwoComponentVector`` conformance.
    public enum Component: TwoComponents, Hashable, Sendable, CaseIterable {
        case x
        case y
        
        public static var first:  Self { .x }
        public static var second: Self { .y }
    }
    
    public init(values: (Scalar, Scalar)) {
        self.init(values.0, values.1)
    }
    
    public static func keyPath(for component: Component) -> WritableKeyPath<Self, Scalar> {
        switch component {
        case .x:
            \.x
        case .y:
            \.y
        }
    }
}

extension SIMD3: Vector where Scalar: ExpressibleByIntegerLiteral {}
extension SIMD3: ThreeComponentVector, KeyPathVector where Scalar: ExpressibleByIntegerLiteral {
    public typealias Value = Scalar
    
    public static var zero: Self {
        .init(x: 0, y: 0, z: 0)
    }
    
    // Swift 5.10 requires an explicit typealias:
    public typealias Components = Component.AllCases
    
    /// The components of a `SIMD3`, for ``ThreeComponentVector`` conformance.
    public enum Component: ThreeComponents, Hashable, Sendable, CaseIterable {
        case x
        case y
        case z
        
        public static var first:  Self { .x }
        public static var second: Self { .y }
        public static var third:  Self { .z }
    }
    
    public init(values: (Scalar, Scalar, Scalar)) {
        self.init(values.0, values.1, values.2)
    }
    
    public static func keyPath(for component: Component) -> WritableKeyPath<Self, Scalar> {
        switch component {
        case .x:
            \.x
        case .y:
            \.y
        case .z:
            \.z
        }
    }
}
