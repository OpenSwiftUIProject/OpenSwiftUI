@frozen
public struct ForegroundStyle: ShapeStyle {
    @inlinable
    public init() {}
    
    public static func _makeView<S>(view: _GraphValue<_ShapeView<S, ForegroundStyle>>, inputs: _ViewInputs) -> _ViewOutputs where S: Shape {
        fatalError("TODO")
    }
}

#if OPENSWIFTUI_SUPPORT_2021_API

extension ForegroundStyle {
    public func _apply(to shape: inout _ShapeStyle_Shape) {
        fatalError("TODO")
    }
    
    public static func _apply(to type: inout _ShapeStyle_ShapeType) {
        fatalError("TODO")
    }
}

extension ShapeStyle where Self == ForegroundStyle {
    @_alwaysEmitIntoClient
    public static var foreground: ForegroundStyle {
        .init()
    }
}
#endif
