//
//  InterpolatedShapeStyle.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete

// MARK: - InterpolatedShapeStyle

package struct InterpolatedShapeStyle<From, To>: ShapeStyle where From: ShapeStyle, To: ShapeStyle {
    package var from: From
    package var to: To
    package var progress: Float

    package init(from: From, to: To, progress: Float) {
        self.from = from
        self.to = to
        self.progress = progress
    }

    package func _apply(to shape: inout _ShapeStyle_Shape) {
        if progress == 0.0 {
            from._apply(to: &shape)
            return
        }
        if progress == 1.0 {
            to._apply(to: &shape)
            return
        }
        switch shape.operation {
        case .prepareText:
            shape.result = .preparedText(.foregroundKeyColor)
        case .resolveStyle:
            var innerShape = shape
            from._apply(to: &innerShape)
            if case .pack = innerShape.result {
                let fromPack = innerShape.stylePack
                to._apply(to: &shape)
                if case .pack = shape.result {
                    let toPack = shape.stylePack
                    var fromData = fromPack.animatableData
                    let toData = toPack.animatableData
                    var diff = toData
                    diff -= fromData
                    diff.scale(by: Double(progress))
                    fromData += diff
                    var resultPack = fromPack
                    resultPack.animatableData = fromData
                    shape.result = .pack(resultPack)
                } else {
                    shape.result = .pack(fromPack)
                }
            } else {
                to._apply(to: &shape)
            }
        case .fallbackColor, .copyStyle:
            to._apply(to: &shape)
        case .modifyBackground, .primaryStyle:
            break
        case .multiLevel:
            from._apply(to: &shape)
            if case let .bool(value) = shape.result, value {
                return
            }
            to._apply(to: &shape)
        }
    }
}
