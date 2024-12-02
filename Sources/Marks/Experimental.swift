
#if canImport(SwiftUI)
import SwiftUI

/// Exposes experimental modifiers from this module for SwiftUI `View`s.
///
/// Use the ``SwiftUICore/View/experimental`` property to use these modifiers with your view. For example:
///
/// ```swift
/// Rectangle()
///     .experimental.marksDragGestures(amongs: $marks)
/// ```
///
/// > Important: Methods in this type are experimental API and subject to change without notice.
@MainActor
public struct ExperimentalViewMethods<Content: View> {
    let content: Content
}

extension View {
    /// Allows access to experimental modifiers for a view.
    ///
    /// Prefix your invocations of experimental modifiers with this property. For example:
    ///
    /// ```swift
    /// Rectangle()
    ///     .experimental.marksDragGestures(amongs: $marks)
    /// ```
    ///
    /// > Important: Methods you access this way are experimental API and subject to change without notice.
    public var experimental: ExperimentalViewMethods<Self> { .init(content: self) }
}

#endif
