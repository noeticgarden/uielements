
#if canImport(Spatial)
import Spatial

extension Point3D: ThreeComponentVector, KeyPathVector {
    // Swift 5.10 requires an explicit typealias:
    public typealias Components = Component.AllCases
    public typealias Value = Double
    
    /// The components of a `Point3D`, for ``ThreeComponentVector`` conformance.
    public enum Component: ThreeComponents, Sendable, Hashable, CaseIterable {
        case x
        case y
        case z
        
        public static let first  = Self.x
        public static let second = Self.y
        public static let third  = Self.z
    }
    
    public init(values: (Double, Double, Double)) {
        self.init(
            x: values.0,
            y: values.1,
            z: values.2
        )
    }
    
    public static func keyPath(for component: Component) -> WritableKeyPath<Self, Double> {
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

extension Size3D: ThreeComponentVector, KeyPathVector {
    // Swift 5.10 requires an explicit typealias:
    public typealias Components = Component.AllCases
    public typealias Value = Double
    
    /// The components of a `Size3D`, for ``ThreeComponentVector`` conformance.
    public enum Component: ThreeComponents, Sendable, Hashable, CaseIterable {
        case width
        case height
        case depth
        
        public static let first  = Self.width
        public static let second = Self.height
        public static let third  = Self.depth
    }
    
    public init(values: (Double, Double, Double)) {
        self.init(
            width: values.0,
            height: values.1,
            depth: values.2
        )
    }
    
    public static func keyPath(for component: Component) -> WritableKeyPath<Self, Double> {
        switch component {
        case .width:
            \.width
        case .height:
            \.height
        case .depth:
            \.depth
        }
    }
}

extension Vector3D: ThreeComponentVector, KeyPathVector {
    // Swift 5.10 requires an explicit typealias:
    public typealias Components = Component.AllCases
    public typealias Value = Double
    
    /// The components of a `Vector3D`, for ``ThreeComponentVector`` conformance.
    public enum Component: ThreeComponents, Sendable, Hashable, CaseIterable {
        case x
        case y
        case z
        
        public static let first  = Self.x
        public static let second = Self.y
        public static let third  = Self.z
    }
    
    public init(values: (Double, Double, Double)) {
        self.init(
            x: values.0,
            y: values.1,
            z: values.2
        )
    }
    
    public static func keyPath(for component: Component) -> WritableKeyPath<Self, Double> {
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

#endif
