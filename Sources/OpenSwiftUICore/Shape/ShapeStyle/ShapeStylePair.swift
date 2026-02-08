//
//  ShapeStylePair.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: BEFE9363F68E039B4AB6422B8AA4535A (SwiftUICore)

// MARK: - ShapeStylePair

/// A pair of shape styles for hierarchical rendering at two levels.
///
/// Level 0 is dispatched to `first`, level 1 to `second`.
package struct ShapeStylePair<S1, S2>: ShapeStyle where S1: ShapeStyle, S2: ShapeStyle {
    package var first: S1
    package var second: S2

    package init(_ first: S1, _ second: S2) {
        self.first = first
        self.second = second
    }

    public func _apply(to shape: inout _ShapeStyle_Shape) {
        switch shape.operation {
        case let .prepareText(level):
            if level <= 0 {
                first._apply(to: &shape)
            } else {
                shape.operation = .prepareText(level: 0)
                second._apply(to: &shape)
            }
        case let .resolveStyle(name, levels):
            guard !levels.isEmpty else { return }
            if levels.upperBound > 1 {
                shape.operation = .resolveStyle(name: name, levels: 0 ..< 1)
                second._apply(to: &shape)
                shape.stylePack.adjustLevelIndices(of: name, by: max(1, levels.lowerBound))
            }
            if levels.lowerBound < 1, levels.upperBound >= 1 {
                shape.operation = .resolveStyle(name: name, levels: 0 ..< 1)
                first._apply(to: &shape)
            }
        case .multiLevel:
            shape.result = .bool(true)
        case let .fallbackColor(level):
            shape.operation = .fallbackColor(level: 0)
            if level <= 0 {
                first._apply(to: &shape)
            } else {
                second._apply(to: &shape)
            }
        case let .modifyBackground(level):
            shape.operation = .modifyBackground(level: 0)
            if level <= 0 {
                first._apply(to: &shape)
            } else {
                second._apply(to: &shape)
            }
        case .copyStyle, .primaryStyle:
            break
        }
    }

    public static func _apply(to type: inout _ShapeStyle_ShapeType) {
        S1._apply(to: &type)
    }
}

// MARK: - ShapeStyleTriple

/// A triple of shape styles for hierarchical rendering at three levels.
///
/// Level 0 is dispatched to `first`, level 1 to `second`, level 2 to `third`.
package struct ShapeStyleTriple<S1, S2, S3>: ShapeStyle where S1: ShapeStyle, S2: ShapeStyle, S3: ShapeStyle {
    package var first: S1
    package var second: S2
    package var third: S3

    package init(_ first: S1, _ second: S2, _ third: S3) {
        self.first = first
        self.second = second
        self.third = third
    }

    public func _apply(to shape: inout _ShapeStyle_Shape) {
        switch shape.operation {
        case let .prepareText(level):
            if level == 1 {
                shape.operation = .prepareText(level: 0)
                second._apply(to: &shape)
            } else if level > 1 {
                shape.operation = .prepareText(level: 0)
                third._apply(to: &shape)
            } else {
                first._apply(to: &shape)
            }
        case let .resolveStyle(name, levels):
            guard !levels.isEmpty else { return }
            if levels.upperBound > 2 {
                shape.operation = .resolveStyle(name: name, levels: 0 ..< 1)
                third._apply(to: &shape)
                shape.stylePack.adjustLevelIndices(of: name, by: max(2, levels.lowerBound))
            }
            if levels.lowerBound < 2, levels.upperBound > 1 {
                shape.operation = .resolveStyle(name: name, levels: 0 ..< 1)
                second._apply(to: &shape)
                shape.stylePack.adjustLevelIndices(of: name, by: max(1, levels.lowerBound))
            }
            if levels.lowerBound < 1, levels.upperBound >= 1 {
                shape.operation = .resolveStyle(name: name, levels: 0 ..< 1)
                first._apply(to: &shape)
            }
        case .multiLevel:
            shape.result = .bool(true)
        case let .fallbackColor(level):
            shape.operation = .fallbackColor(level: 0)
            if level <= 0 {
                first._apply(to: &shape)
            } else if level == 1 {
                second._apply(to: &shape)
            } else {
                third._apply(to: &shape)
            }
        case let .modifyBackground(level):
            shape.operation = .modifyBackground(level: 0)
            if level <= 0 {
                first._apply(to: &shape)
            } else if level == 1 {
                second._apply(to: &shape)
            } else {
                third._apply(to: &shape)
            }
        case .copyStyle, .primaryStyle:
            break
        }
    }

    public static func _apply(to type: inout _ShapeStyle_ShapeType) {
        S1._apply(to: &type)
    }
}
