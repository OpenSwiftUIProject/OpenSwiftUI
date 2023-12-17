#if canImport(Darwin)
import CoreGraphics
#elseif os(Linux)
import Foundation
#endif

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
