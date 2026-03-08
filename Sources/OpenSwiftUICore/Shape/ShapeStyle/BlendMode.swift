//
//  BlendMode.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete

// MARK: - BlendMode

/// Modes for compositing a view with overlapping content.
@available(OpenSwiftUI_v1_0, *)
public enum BlendMode: Sendable {
    case normal
    case multiply
    case screen
    case overlay
    case darken
    case lighten
    case colorDodge
    case colorBurn
    case softLight
    case hardLight
    case difference
    case exclusion
    case hue
    case saturation
    case color
    case luminosity
    case sourceAtop
    case destinationOver
    case destinationOut
    case plusDarker
    case plusLighter
}

@available(OpenSwiftUI_v3_0, *)
extension ShapeStyle {

    /// Returns a new style based on `self` that applies the specified
    /// blend mode when drawing.
    @inlinable
    public func blendMode(_ mode: BlendMode) -> some ShapeStyle {
        _BlendModeShapeStyle(style: self, blendMode: mode)
    }
}

@available(OpenSwiftUI_v4_0, *)
extension ShapeStyle where Self == AnyShapeStyle {

    /// Returns a new style based on the current style that uses
    /// `mode` as its blend mode when drawing.
    ///
    /// In most contexts the current style is the foreground but e.g.
    /// when setting the value of the background style, that becomes
    /// the current implicit style.
    ///
    /// For example, a circle filled with the current foreground
    /// style and the overlay blend mode:
    ///
    ///     Circle().fill(.blendMode(.overlay))
    ///
    @_alwaysEmitIntoClient
    public static func blendMode(_ mode: BlendMode) -> some ShapeStyle {
        _BlendModeShapeStyle(
            style: _ImplicitShapeStyle(),
            blendMode: mode
        )
    }
}

@available(OpenSwiftUI_v3_0, *)
@frozen
public struct _BlendModeShapeStyle<Style>: ShapeStyle, PrimitiveShapeStyle where Style: ShapeStyle {
    public var style: Style

    public var blendMode: BlendMode

    @inlinable
    public init(style: Style, blendMode: BlendMode) {
        self.style = style
        self.blendMode = blendMode
    }
    
    public func _apply(to shape: inout _ShapeStyle_Shape) {
        switch shape.operation {
        case .prepareText:
            if blendMode == .normal {
                style._apply(to: &shape)
            } else {
                shape.result = .preparedText(.foregroundKeyColor)
            }
        case let .resolveStyle(name: name, levels: levels):
            style._apply(to: &shape)
            let blend = GraphicsBlendMode(blendMode)
            shape.stylePack.modify(
                name: name,
                levels: levels
            ) { style in
                style.applyBlend(blend)
            }
        case .fallbackColor, .modifyBackground, .multiLevel:
            style._apply(to: &shape)
        case let .copyStyle(name: name):
            style.mapCopiedStyle(in: &shape) { style in
                _BlendModeShapeStyle<AnyShapeStyle>(
                    style: style,
                    blendMode: blendMode
                )
            }
        case .primaryStyle:
            break
        }
    }
    
    public static func _apply(to type: inout _ShapeStyle_ShapeType) {
        Style._apply(to: &type)
    }
}
