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
