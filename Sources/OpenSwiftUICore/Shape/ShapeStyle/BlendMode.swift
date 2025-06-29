//
//  BlendMode.swift
//  OpenSwiftUICore
//
//  Audited for iOS 18.0
//  Status: WIP

// MARK: - BlendMode

/// Modes for compositing a view with overlapping content.
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

#if canImport(CoreGraphics)
package import CoreGraphics

extension BlendMode {
    package init(_ blendMode: CGBlendMode) {
        self = switch blendMode {
            case .normal: .normal
            case .multiply: .multiply
            case .screen: .screen
            case .overlay: .overlay
            case .darken: .darken
            case .lighten: .lighten
            case .colorDodge: .colorDodge
            case .colorBurn: .colorBurn
            case .softLight: .softLight
            case .hardLight: .hardLight
            case .difference: .difference
            case .exclusion: .exclusion
            case .hue: .hue
            case .saturation: .saturation
            case .color: .color
            case .luminosity: .luminosity
            case .sourceAtop: .sourceAtop
            case .destinationOver: .destinationOver
            case .destinationOut: .destinationOut
            case .plusDarker: .plusDarker
            case .plusLighter: .plusLighter
            default: .normal
        }
    }
}
#endif

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
                openSwiftUIUnimplementedFailure()
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
