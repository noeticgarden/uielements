
#if canImport(CoreGraphics)
import CoreGraphics
#endif

import Foundation

extension CGPoint: TwoComponentVector, KeyPathVector {
    // Swift 5.10 requires an explicit typealias:
    public typealias Components = Component.AllCases
    public typealias Value = CGFloat
    
    /// The components of a `CGPoint`, for ``TwoComponentVector`` conformance.
    public enum Component: TwoComponents, Sendable, Hashable, CaseIterable {
        public static let first  = Self.x
        public static let second = Self.y
        
        case x
        case y
    }
    
    public init(values: (CGFloat, CGFloat)) {
        self.init(x: values.0, y: values.1)
    }
    
    public static func keyPath(for component: Component) -> WritableKeyPath<Self, CGFloat> {
        switch component {
        case .x:
            \.x
        case .y:
            \.y
        }
    }
}

extension CGSize: TwoComponentVector, KeyPathVector {
    // Swift 5.10 requires an explicit typealias:
    public typealias Components = Component.AllCases
    public typealias Value = CGFloat
    
    /// The components of a `CGSize`, for ``TwoComponentVector`` conformance.
    public enum Component: TwoComponents, Sendable, Hashable, CaseIterable {
        public static let first  = Self.width
        public static let second = Self.height
        
        case width
        case height
    }
    
    public init(values: (CGFloat, CGFloat)) {
        self.init(width: values.0, height: values.1)
    }
    
    public static func keyPath(for component: Component) -> WritableKeyPath<Self, CGFloat> {
        switch component {
        case .width:
            \.width
        case .height:
            \.height
        }
    }
}

#if canImport(CoreGraphics)
// CGVector is only available through Darwin's Core Graphics.
extension CGVector: TwoComponentVector, KeyPathVector {
    // Swift 5.10 requires an explicit typealias:
    public typealias Components = Component.AllCases
    public typealias Value = CGFloat
    
    /// The components of a `CGVector`, for ``TwoComponentVector`` conformance.
    public enum Component: TwoComponents, Sendable, Hashable, CaseIterable {
        public static let first  = Self.dx
        public static let second = Self.dy
        
        case dx
        case dy
    }
    
    public init(values: (CGFloat, CGFloat)) {
        self.init(dx: values.0, dy: values.1)
    }
    
    public static func keyPath(for component: Component) -> WritableKeyPath<Self, CGFloat> {
        switch component {
        case .dx:
            \.dx
        case .dy:
            \.dy
        }
    }
}
#endif
