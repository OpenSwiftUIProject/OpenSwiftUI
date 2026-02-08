//
//  OffsetShapeStyle.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete

package struct OffsetShapeStyle<Base>: ShapeStyle where Base: ShapeStyle {
    package var base: Base

    package var offset: Int
    
    package func _apply(to shape: inout _ShapeStyle_Shape) {
        switch shape.operation {
        case let .prepareText(level):
            shape.operation = .prepareText(level: offset + level)
            base._apply(to: &shape)
        case let .resolveStyle(name, levels):
            let offsetLevels = levels.lowerBound + offset ..< levels.upperBound + offset
            shape.stylePack.adjustLevelIndices(of: name, by: offset)
            shape.operation = .resolveStyle(name: name, levels: offsetLevels)
            base._apply(to: &shape)
            if case var .pack(resultPack) = shape.result {
                resultPack.adjustLevelIndices(of: name, by: -offset)
                shape.result = .pack(resultPack)
            }
        case .multiLevel:
            shape.result = .bool(false)
        case let .fallbackColor(level):
            shape.operation = .fallbackColor(level: offset + level)
            base._apply(to: &shape)
        case .copyStyle:
            base.mapCopiedStyle(in: &shape) { style in
                style.offset(by: offset)
            }
        case .primaryStyle:
            shape.result = .style(AnyShapeStyle(base))
        case let .modifyBackground(level):
            shape.operation = .modifyBackground(level: offset + level)
            base._apply(to: &shape)
        }
    }
    
    package static func _apply(to type: inout _ShapeStyle_ShapeType) {
        Base._apply(to: &type)
    }
}

extension ShapeStyle {
    package func offset(by levels: Int) -> OffsetShapeStyle<Self> {
        OffsetShapeStyle(base: self, offset: levels)
    }
}
