import Foundation

// MARK: - ClipEffect

@frozen
public struct _ClipEffect<ClipShape> where ClipShape: Shape {
    public var shape: ClipShape
    public var style: FillStyle
    
    @inlinable
    public init(shape: ClipShape, style: FillStyle = FillStyle()) {
        self.shape = shape
        self.style = style
    }
    
    public var animatableData: ClipShape.AnimatableData {
        get { shape.animatableData }
        set { shape.animatableData = newValue }
    }
    
    public typealias AnimatableData = ClipShape.AnimatableData
    public typealias Body = Swift.Never
}

// FIXME
extension _ClipEffect: PrimitiveViewModifier {}

// MARK: - View Extension

extension View {

    /// Sets a clipping shape for this view.
    ///
    /// Use `clipShape(_:style:)` to clip the view to the provided shape. By
    /// applying a clipping shape to a view, you preserve the parts of the view
    /// covered by the shape, while eliminating other parts of the view. The
    /// clipping shape itself isn't visible.
    ///
    /// For example, this code applies a circular clipping shape to a `Text`
    /// view:
    ///
    ///     Text("Clipped text in a circle")
    ///         .frame(width: 175, height: 100)
    ///         .foregroundColor(Color.white)
    ///         .background(Color.black)
    ///         .clipShape(Circle())
    ///
    /// The resulting view shows only the portion of the text that lies within
    /// the bounds of the circle.
    ///
    /// ![A screenshot of text clipped to the shape of a
    /// circle.](OpenSwiftUI-View-clipShape.png)
    ///
    /// - Parameters:
    ///   - shape: The clipping shape to use for this view. The `shape` fills
    ///     the view's frame, while maintaining its aspect ratio.
    ///   - style: The fill style to use when rasterizing `shape`.
    ///
    /// - Returns: A view that clips this view to `shape`, using `style` to
    ///   define the shape's rasterization.
    @inlinable
    public func clipShape<S>(_ shape: S, style: FillStyle = FillStyle()) -> some View where S: Shape {
        modifier(_ClipEffect(shape: shape, style: style))
    }


    /// Clips this view to its bounding rectangular frame.
    ///
    /// Use the `clipped(antialiased:)` modifier to hide any content that
    /// extends beyond the layout bounds of the shape.
    ///
    /// By default, a view's bounding frame is used only for layout, so any
    /// content that extends beyond the edges of the frame is still visible.
    ///
    ///     Text("This long text string is clipped")
    ///         .fixedSize()
    ///         .frame(width: 175, height: 100)
    ///         .clipped()
    ///         .border(Color.gray)
    ///
    /// ![Screenshot showing text clipped to its
    /// frame.](OpenSwiftUI-View-clipped.png)
    ///
    /// - Parameter antialiased: A Boolean value that indicates whether the
    ///   rendering system applies smoothing to the edges of the clipping
    ///   rectangle.
    ///
    /// - Returns: A view that clips this view to its bounding frame.
    @inlinable
    public func clipped(antialiased: Bool = false) -> some View {
        clipShape(
            Rectangle(),
            style: FillStyle(antialiased: antialiased)
        )
    }


    /// Clips this view to its bounding frame, with the specified corner radius.
    ///
    /// By default, a view's bounding frame only affects its layout, so any
    /// content that extends beyond the edges of the frame remains visible. Use
    /// `cornerRadius(_:antialiased:)` to hide any content that extends beyond
    /// these edges while applying a corner radius.
    ///
    /// The following code applies a corner radius of 25 to a text view:
    ///
    ///     Text("Rounded Corners")
    ///         .frame(width: 175, height: 75)
    ///         .foregroundColor(Color.white)
    ///         .background(Color.black)
    ///         .cornerRadius(25)
    ///
    /// ![A screenshot of a rectangle with rounded corners bounding a text
    /// view.](OpenSwiftUI-View-cornerRadius.png)
    ///
    /// - Parameter antialiased: A Boolean value that indicates whether the
    ///   rendering system applies smoothing to the edges of the clipping
    ///   rectangle.
    ///
    /// - Returns: A view that clips this view to its bounding frame with the
    ///   specified corner radius.
    @available(*, deprecated, message: "Use `clipShape` or `fill` instead.")
    @inlinable
    public func cornerRadius(_ radius: CGFloat, antialiased: Bool = true) -> some View {
        clipShape(
            RoundedRectangle(cornerRadius: radius),
            style: FillStyle(antialiased: antialiased)
        )
    }
}
