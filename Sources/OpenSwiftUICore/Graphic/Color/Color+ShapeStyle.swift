//
//  Color+ShapeStyle.swift
//  OpenSwiftUICore
//
//  Audited for iOS 18.0
//  Status: WIP

package import Foundation

extension Color: ShapeStyle {
    package func fallbackColor(in env: EnvironmentValues) -> Color? {
        preconditionFailure("TODO")
    }
    
    package func resolvePaint(in environment: EnvironmentValues) -> Color.Resolved {
        preconditionFailure("TODO")
    }
    
    @available(*, deprecated, message: "obsolete")
    @_alwaysEmitIntoClient
    nonisolated public static func _makeView<S>(view: _GraphValue<_ShapeView<S, Self>>, inputs: _ViewInputs) -> _ViewOutputs where S: Shape {
        _ShapeView<S, Self>._makeView(view: view, inputs: inputs)
    }
}

extension ColorProvider {
    package func apply(color: Color, to shape: inout _ShapeStyle_Shape) {
        preconditionFailure("TODO")
    }
    
    package func _apply(color: Color, to shape: inout _ShapeStyle_Shape) {
        preconditionFailure("TODO")
    }
}

// MARK: - Color.Resolved + ResolvedPaint

extension Color.Resolved: ResolvedPaint {
    package func draw(path: Path, style: PathDrawingStyle, in context: GraphicsContext, bounds: CGRect?) {
        preconditionFailure("TODO")
    }
    
    package var isClear: Bool { opacity == 0 }
    package var isOpaque: Bool { opacity == 1 }
    package static var leafProtobufTag: CodableResolvedPaint.Tag? { .color }
}
