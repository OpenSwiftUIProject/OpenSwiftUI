//
//  LayoutDirectionBehavior.swift
//  OpenSwiftUICore
//
//  Audited for 6.0.87
//  Status: Complete

/// A description of what should happen when the layout direction changes.
///
/// A `LayoutDirectionBehavior` can be used with the `layoutDirectionBehavior`
/// view modifier or the `layoutDirectionBehavior` property of `Shape`.
public enum LayoutDirectionBehavior: Hashable, Sendable {
    /// A behavior that doesn't mirror when the layout direction changes.
    case fixed

    /// A behavior that mirrors when the layout direction has the specified
    /// value.
    ///
    /// If you develop your view or shape in an LTR context, you can use
    /// `.mirrors(in: .rightToLeft)` (which is equivalent to `.mirrors`) to
    /// mirror your content when the layout direction is RTL (and keep the
    /// original version in LTR). If you developer in an RTL context, you can
    /// use `.mirrors(in: .leftToRight)` to mirror your content when the layout
    /// direction is LTR (and keep the original version in RTL).
    case mirrors(in: LayoutDirection)

    /// A behavior that mirrors when the layout direction is right-to-left.
    public static var mirrors: LayoutDirectionBehavior {
        .mirrors(in: .rightToLeft)
    }

    package func shouldFlip(in direction: @autoclosure () -> LayoutDirection?) -> Bool {
        switch self {
        case .fixed:
            return false
        case let .mirrors(`in`):
            return direction() == `in`
        }
    }
}
