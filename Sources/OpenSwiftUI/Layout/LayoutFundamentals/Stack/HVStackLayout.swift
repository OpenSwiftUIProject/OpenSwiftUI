import Foundation

@frozen
public struct _HStackLayout {
    public var alignment: VerticalAlignment
    public var spacing: CGFloat?
 
    @inlinable
    public init(alignment: VerticalAlignment = .center, spacing: CGFloat? = nil) {
        self.alignment = alignment
        self.spacing = spacing
    }

    public typealias AnimatableData = EmptyAnimatableData
    public typealias Body = Swift.Never
}

@frozen
public struct _VStackLayout {
    public var alignment: HorizontalAlignment
    public var spacing: CGFloat?
 
    @inlinable
    public init(alignment: HorizontalAlignment = .center, spacing: CGFloat? = nil) {
        self.alignment = alignment
        self.spacing = spacing
    }

    public typealias AnimatableData = EmptyAnimatableData
    public typealias Body = Swift.Never
}

extension _HStackLayout: _VariadicView_ImplicitRoot {
    static var implicitRoot: _HStackLayout { _HStackLayout() }
}
extension _VStackLayout: _VariadicView_ImplicitRoot {
    static var implicitRoot: _VStackLayout { _VStackLayout() }
}
