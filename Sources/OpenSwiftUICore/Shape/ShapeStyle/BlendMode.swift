//
//  BlendMode.swift
//  OpenSwiftUICore
//
//  Audited for 6.0.87
//  Status: WIP

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

extension ShapeStyle {
    /// Returns a new style based on `self` that applies the specified
    /// blend mode when drawing.
    @inlinable
    public func blendMode(_ mode: BlendMode) -> some ShapeStyle {
        _BlendModeShapeStyle(style: self, blendMode: mode)
    }
}

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

@frozen
public struct _BlendModeShapeStyle<Style>: ShapeStyle, PrimitiveShapeStyle where Style: ShapeStyle {
    public var style: Style
    public var blendMode: BlendMode
    @inlinable public init(style: Style, blendMode: BlendMode) {
        self.style = style
        self.blendMode = blendMode
    }
    
    public func _apply(to shape: inout _ShapeStyle_Shape) {
        switch shape.operation {
            case .fallbackColor, .modifyBackground:
                style._apply(to: &shape)
            case .prepareText:
                if blendMode == .normal {
                    style._apply(to: &shape)
                } else {
                    shape.result = .preparedText(.foregroundKeyColor)
                }
            default:
                _openSwiftUIUnimplementedFailure()
//            case resolveStyle(name: _ShapeStyle_Name, levels: Range<Int>):
//                
//                
//            case .multiLevel:
//                <#code#>
//            case .copyStyle(let name):
//                <#code#>
//            case .primaryStyle:
//                <#code#>
        }
    }
    
    public static func _apply(to type: inout _ShapeStyle_ShapeType) {
        Style._apply(to: &type)
    }
    
    public typealias Resolved = Never
}
