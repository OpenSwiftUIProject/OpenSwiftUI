//
//  FillStyle.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete

/// A style for rasterizing vector shapes.
@available(OpenSwiftUI_v1_0, *)
@frozen
public struct FillStyle: Equatable {

    /// A Boolean value that indicates whether to use the even-odd rule when
    /// rendering a shape.
    ///
    /// When `isOEFilled` is `false`, the style uses the non-zero winding number
    /// rule.
    public var isEOFilled: Bool

    /// A Boolean value that indicates whether to apply antialiasing to the
    /// edges of a shape.
    public var isAntialiased: Bool

    /// Creates a new fill style with the specified settings.
    ///
    /// - Parameters:
    ///   - eoFill: A Boolean value that indicates whether to use the even-odd
    ///     rule for rendering a shape. Pass `false` to use the non-zero winding
    ///     number rule instead.
    ///   - antialiased: A Boolean value that indicates whether to use
    ///     antialiasing when rendering the edges of a shape.
    @inlinable
    public init(eoFill: Bool = false, antialiased: Bool = true) {
        self.isEOFilled = eoFill
        self.isAntialiased = antialiased
    }
}

extension FillStyle: ProtobufMessage {
    package func encode(to encoder: inout ProtobufEncoder) {
        encoder.boolField(1, isEOFilled, defaultValue: false)
        encoder.boolField(2, isAntialiased, defaultValue: true)
    }

    package init(from decoder: inout ProtobufDecoder) throws {
        var style = FillStyle()
        while let field = try decoder.nextField() {
            switch field.tag {
            case 1: style.isEOFilled = try decoder.boolField(field)
            case 2: style.isAntialiased = try decoder.boolField(field)
            default: try decoder.skipField(field)
            }
        }
        self = style
    }
}
