public import Foundation

/// A rectangular shape aligned inside the frame of the view containing it.
@frozen
public struct Rectangle: Shape {
    public func path(in rect: CGRect) -> Path {
        fatalError("TODO")
    }

    /// Creates a new rectangle shape.
    @inlinable
    public init() {}

    public typealias AnimatableData = EmptyAnimatableData

    public typealias Body = _ShapeView<Rectangle, ForegroundStyle>
}


extension Shape where Self == Rectangle {
    /// A rectangular shape aligned inside the frame of the view containing it.
    public static var rect: Rectangle {
        Rectangle()
    }
}

public struct RectangleCornerRadii {}
