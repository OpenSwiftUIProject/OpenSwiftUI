//
//  ShapeView.swift
//  OpenSwiftUICore
//
//  Audited for iOS 15.5
//  Status: WIP

// FIXME
extension Shape {
    public var body: _ShapeView<Self, ForegroundStyle> {
        _ShapeView(shape: self, style: ForegroundStyle())
    }
}

@frozen
public struct _ShapeView<Content, Style>: /*ShapeStyledLeafView, */UnaryView, PrimitiveView where Content: Shape, Style: ShapeStyle {
    public var shape: Content
    public var style: Style
    public var fillStyle: FillStyle
    
    @inlinable
    public init(shape: Content, style: Style, fillStyle: FillStyle = FillStyle()) {
        self.shape = shape
        self.style = style
        self.fillStyle = fillStyle
    }

    public static func _makeView(view: _GraphValue<_ShapeView<Content, Style>>, inputs: _ViewInputs) -> _ViewOutputs {
        preconditionFailure("TODO")
    }
}
