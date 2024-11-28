
/// A utility protocol that provides a default implementation for result builders that gather multiple elements into an array.
///
/// To use this protocol, define your own conforming type and tag it with `@resultBuilder`. For example:
///
/// ```swift
/// @resultBuilder
/// struct IntsBuilder: _ElementsBuilder {
///     typealias Element = Int
/// }
///
/// @IntsBuilder var ints: [Int] {
///     4
///     8
///     for int in [15, 16] {
///         int
///     }
///     if jokeGoesTheFullDistance {
///         23
///         42
///     }
/// }
/// ```
///
/// This result builder supports all currently supported control flow modes (iteration, switching, conditionals). If you need to support fewer modes, you may need to write your own implementation.
///
/// By default, result builders that conform to this protocol will create closures that return an array of ``Element``. This may be sufficient as-is for your use case, like in the example above. In other cases, you may want to receive inputs that are not `Element`, or produce results that are not `[Element]`. In that case, just add your own `buildExpression(…)` or `buildFinalResult(…)` implementations. For example:
///
/// ```swift
/// @resultBuilder
/// struct AveragesBuilder: ElementsBuilder {
///     typealias Element = Double
///
///     public static func buildFinalResult(_ elements: [Element]) -> Double {
///         return elements.reduce(0, +) / Double(elements.count)
///     }
/// }
/// ```
///
/// This builder will now return `Double` instead, and the average it provides will be computed at the final step after gathering the elements.
public protocol _ElementsBuilder {
    /// The element that is gathered. The closures that use this result builder will return `[Element]` by default.
    associatedtype Element
}

extension _ElementsBuilder {
    public static func buildExpression(_ expression: Element) -> [Element] {
        [expression]
    }
    
    public static func buildBlock(_ components: [Element]...) -> [Element] {
        components.flatMap { $0 }
    }
    
    public static func buildArray(_ components: [[Element]]) -> [Element] {
        components.flatMap { $0 }
    }
    
    public static func buildOptional(_ component: [Element]?) -> [Element] {
        component ?? []
    }
    
    public static func buildEither(first component: [Element]) -> [Element] {
        component
    }
    
    public static func buildEither(second component: [Element]) -> [Element] {
        component
    }
}
