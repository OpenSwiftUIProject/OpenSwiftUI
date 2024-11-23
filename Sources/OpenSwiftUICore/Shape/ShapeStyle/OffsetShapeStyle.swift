//
//  OffsetShapeStyle.swift
//  OpenSwiftUICore
//
//  Audited for iOS 18.0
//  Status: Blocked by _ShapeStyle_Pack

package struct OffsetShapeStyle<Base>: ShapeStyle where Base: ShapeStyle {
    package var base: Base
    package var offset: Int
    
    package func _apply(to shape: inout _ShapeStyle_Shape) {
        switch shape.operation {
            case .prepareText(let level):
                shape.operation = .prepareText(level: offset + level)
                base._apply(to: &shape)
            case .resolveStyle(let name, let levels):
                let _ = levels.lowerBound + offset ..< levels.upperBound + offset
                // Blocked by _ShapeStyle_Pack
            case .multiLevel:
                shape.result = .bool(false)
            case .fallbackColor(let level):
                shape.operation = .fallbackColor(level: offset + level)
                base._apply(to: &shape)
            case .copyStyle(let name):
                base.mapCopiedStyle(in: &shape) { style in
                    style.offset(by: offset)
                }
            case .primaryStyle:
                shape.result = .style(AnyShapeStyle(base))
            case .modifyBackground(let level):
                shape.operation = .modifyBackground(level: offset + level)
                base._apply(to: &shape)
        }
    }
    
    package static func _apply(to type: inout _ShapeStyle_ShapeType) {
        Base._apply(to: &type)
    }
    
    package typealias Resolved = Never
}

extension ShapeStyle {
    package func offset(by levels: Int) -> OffsetShapeStyle<Self> {
        OffsetShapeStyle(base: self, offset: levels)
    }
}
