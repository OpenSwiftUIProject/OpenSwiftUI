//
//  Color+ShapeStyle.swift
//  OpenSwiftUICore
//
//  Audited for iOS 18.0
//  Status: Complete

package import Foundation

extension Color: ShapeStyle {
    package func fallbackColor(in env: EnvironmentValues) -> Color? { self }
    package func resolvePaint(in environment: EnvironmentValues) -> Color.Resolved { resolve(in: environment) }
    
    @available(*, deprecated, message: "obsolete")
    @_alwaysEmitIntoClient
    nonisolated public static func _makeView<S>(view: _GraphValue<_ShapeView<S, Self>>, inputs: _ViewInputs) -> _ViewOutputs where S: Shape {
        _ShapeView<S, Self>._makeView(view: view, inputs: inputs)
    }
}

extension ColorProvider {
    package func apply(color: Color, to shape: inout _ShapeStyle_Shape) {
        _apply(color: color, to: &shape)
    }
    
    package func _apply(color: Color, to shape: inout _ShapeStyle_Shape) {
        switch shape.operation {
            case let .prepareText(level):
                if level >= 1 {
                    let opacity = color.provider.opacity(at: level, environment: shape.environment)
                    shape.result = .preparedText(.foregroundColor(color.opacity(Double(opacity))))
                } else {
                    shape.result = .preparedText(.foregroundColor(color))
                }
            case let .resolveStyle(name, levels):
                guard levels.lowerBound != levels.upperBound else {
                    return
                }
                let resolved = resolve(in: shape.environment)
                let opacity = color.provider.opacity(at: levels.lowerBound, environment: shape.environment)
                
                var newPack: _ShapeStyle_Pack
                switch shape.result {
                    case let .pack(pack): newPack = pack
                    default: newPack = .init()
                }
                newPack[name, levels.lowerBound] = .init(.color(resolved.multiplyingOpacity(by: opacity)))
                shape.result = .pack(newPack)
            case let .fallbackColor(level):
                if level >= 1 {
                    let opacity = color.provider.opacity(at: level, environment: shape.environment)
                    shape.result = .color(color.opacity(Double(opacity)))
                } else {
                    shape.result = .color(color)
                }
            default:
                break
        }
    }
}

// MARK: - Color.Resolved + ResolvedPaint

extension Color.Resolved: ResolvedPaint {
    package func draw(path: Path, style: PathDrawingStyle, in context: GraphicsContext, bounds: CGRect?) {
        context.draw(path, with: .color(self), style: style)
    }
    
    package var isClear: Bool { opacity == 0 }
    package var isOpaque: Bool { opacity == 1 }
    package static var leafProtobufTag: CodableResolvedPaint.Tag? { .color }
}