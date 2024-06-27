import Foundation

@frozen
public struct RoundedRectangle: Shape {
    public var cornerSize: CGSize
    public var style: RoundedCornerStyle
    
    @inlinable
    public init(cornerSize: CGSize, style: RoundedCornerStyle = .circular) {
        self.cornerSize = cornerSize
        self.style = style
    }
    
    @inlinable
    public init(cornerRadius: CGFloat, style: RoundedCornerStyle = .circular) {
        let cornerSize = CGSize(width: cornerRadius, height: cornerRadius)
        self.init(cornerSize: cornerSize, style: style)
    }
    
    public func path(in rect: CGRect) -> Path {
        fatalError("TODO")
    }
    public var animatableData: CGSize.AnimatableData {
        get { cornerSize.animatableData }
        set { cornerSize.animatableData = newValue }
    }

    public typealias Body = _ShapeView<RoundedRectangle, ForegroundStyle>
}

