import Foundation

/// A layout that arranges its children in a horizontal line.
@frozen
public struct _HStackLayout {
    /// The vertical alignment of children.
    public var alignment: VerticalAlignment
    
    /// The distance between adjacent children, or `nil` if the stack should
    /// choose a default distance for each pair of children.
    public var spacing: CGFloat?
 
    /// Creates an instance with the given spacing and vertical alignment.
    ///
    /// - Parameters:
    ///     - alignment: The guide for aligning the subviews in this stack. It
    ///     has the same vertical screen coordinate for all children.
    ///     - spacing: The distance between adjacent subviews, or `nil` if you
    ///     want the stack to choose a default distance for each pair of
    ///     subviews.
    @inlinable
    public init(alignment: VerticalAlignment = .center, spacing: CGFloat? = nil) {
        self.alignment = alignment
        self.spacing = spacing
    }

    public typealias AnimatableData = EmptyAnimatableData
    public typealias Body = Never
}

/// A layout that arranges its children in a vertical line.
@frozen
public struct _VStackLayout {
    /// The horizontal alignment of children.
    public var alignment: HorizontalAlignment
    
    /// The distance between adjacent children, or `nil` if the stack should
    /// choose a default distance for each pair of children.
    public var spacing: CGFloat?
 
    /// Creates an instance with the given spacing and horizontal alignment.
    ///
    /// - Parameters:
    ///     - alignment: The guide for aligning the subviews in this stack. It
    ///     has the same horizontal screen coordinate for all children.
    ///     - spacing: The distance between adjacent subviews, or `nil` if you
    ///     want the stack to choose a default distance for each pair of
    ///     subviews.
    @inlinable
    public init(alignment: HorizontalAlignment = .center, spacing: CGFloat? = nil) {
        self.alignment = alignment
        self.spacing = spacing
    }

    public typealias AnimatableData = EmptyAnimatableData
    public typealias Body = Never
}

extension _HStackLayout: _VariadicView_ImplicitRoot {
    package static var implicitRoot: _HStackLayout { _HStackLayout() }
}
extension _VStackLayout: _VariadicView_ImplicitRoot {
    package static var implicitRoot: _VStackLayout { _VStackLayout() }
}
