public protocol ShapeStyle {
  @available(*, deprecated, message: "obsolete")
  static func _makeView<S>(view: _GraphValue<_ShapeView<S, Self>>, inputs: _ViewInputs) -> _ViewOutputs where S : Shape
    
    #if OPENSWIFTUI_SUPPORT_2021_API
    func _apply(to shape: inout _ShapeStyle_Shape)
    
    static func _apply(to type: inout _ShapeStyle_ShapeType)
    #endif
}


#if OPENSWIFTUI_SUPPORT_2021_API

public struct _ShapeStyle_Shape {
    // TODO
}

public struct _ShapeStyle_ShapeType {
    // TODO
}

extension ShapeStyle {
    public static func _makeView<S>(view: _GraphValue<_ShapeView<S, Self>>, inputs: _ViewInputs) -> _ViewOutputs where S: Shape {
        fatalError("TODO")
    }
    
    public func _apply(to shape: inout _ShapeStyle_Shape) {
        fatalError("TODO")
    }
    
    public static func _apply(to type: inout _ShapeStyle_ShapeType) {
        fatalError("TODO")
    }
}


#endif
