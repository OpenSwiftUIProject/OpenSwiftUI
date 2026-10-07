//
//  OpacityEffectTests.swift
//  OpenSwiftUICoreTests

@_spi(Private) @testable import OpenSwiftUICore
import Testing
import OpenSwiftUITestsSupport

@Suite(.tags(.aigc))
struct OpacityEffectTests {
    @Test
    func opacityScalesOnlyRequestedStylesAndTheirEffects() {
        var shape = _ShapeStyle_Shape(operation: .resolveStyle(name: .foreground, levels: 1..<3))
        _OpacityShapeStyle(style: TestStyle(), opacity: 0.5)._apply(to: &shape)

        #expect(shape.stylePack[.foreground, 0].opacity == 0.5)
        #expect(shape.stylePack[.foreground, 1].opacity == 0.25)
        #expect(shape.stylePack[.foreground, 2].opacity == 0.25)
        #expect(shape.stylePack[.foreground, 3].opacity == 0.5)
        #expect(shape.stylePack[.background, 0].opacity == 0.5)
        #expect(shape.stylePack[.foreground, 1].effects[0].opacity == 0.125)
        #expect(shape.stylePack[.foreground, 0].effects[0].opacity == 0.25)
    }

    @Test(arguments: [Float(0), 0.5, -1, 2])
    func textRequiresKeyColorForNonidentityOpacity(opacity: Float) {
        var shape = _ShapeStyle_Shape(operation: .prepareText(level: 0))
        _OpacityShapeStyle(style: TestStyle(), opacity: opacity)._apply(to: &shape)

        guard case .preparedText(.foregroundKeyColor) = shape.result else {
            Issue.record("Expected foreground key color")
            return
        }
    }

    @Test
    func identityOpacityPreservesTextPreparation() {
        var shape = _ShapeStyle_Shape(operation: .prepareText(level: 0))
        _OpacityShapeStyle(style: TestStyle(), opacity: 1)._apply(to: &shape)

        guard case .preparedText(.foregroundColor(.red)) = shape.result else {
            Issue.record("Expected the base style's text color")
            return
        }
    }

    @Test(arguments: [
        ([Double](), [Float(0.5), 0.5, 0.5, 0.5]),
        ([Double(0.25)], [Float(0.125), 0.125, 0.125, 0.125]),
        ([Double(0.25), 0.5], [Float(0.125), 0.25, 0.25, 0.25]),
        ([Double(-1), 2], [Float(-0.5), 1, 1, 1]),
    ])
    func opacitiesUseLevelZeroAndRepeatTheLastValue(opacities: [Double], expected: [Float]) {
        var shape = _ShapeStyle_Shape(operation: .resolveStyle(name: .foreground, levels: 0..<4))
        _OpacitiesShapeStyle(style: TestStyle(), opacities: opacities)._apply(to: &shape)

        #expect((0..<4).map { shape.stylePack[.foreground, $0].opacity } == expected)
        #expect((0..<4).map { shape.stylePack[.foreground, $0].effects[0].opacity } == expected.map { $0 / 2 })
        guard case .resolveStyle(name: .foreground, levels: 0..<1) = shape.operation else {
            Issue.record("Expected the base style to resolve level zero")
            return
        }
    }

    @Test
    func opacitiesPreserveUnrequestedLevels() {
        var shape = _ShapeStyle_Shape(operation: .resolveStyle(name: .foreground, levels: 2..<4))
        _OpacitiesShapeStyle(style: TestStyle(), opacities: [0.25, 0.5])._apply(to: &shape)

        #expect(shape.stylePack[.foreground, 0].opacity == 0.5)
        #expect(shape.stylePack[.foreground, 1].opacity == 0.5)
        #expect(shape.stylePack[.foreground, 2].opacity == 0.25)
        #expect(shape.stylePack[.foreground, 3].opacity == 0.25)
        #expect(shape.stylePack[.background, 0].opacity == 0.5)
    }

    @Test(arguments: [
        ([Double](), -1, 1.0),
        ([Double(0.25), 0.5], -1, 1.0),
        ([Double(0.25), 0.5], 0, 0.25),
        ([Double(0.25), 0.5], 1, 0.5),
        ([Double(0.25), 0.5], 5, 0.5),
    ])
    func fallbackColorUsesLevelZero(opacities: [Double], level: Int, expected: Double) {
        var shape = _ShapeStyle_Shape(operation: .fallbackColor(level: level))
        _OpacitiesShapeStyle(style: TestStyle(), opacities: opacities)._apply(to: &shape)

        guard case let .color(color) = shape.result else {
            Issue.record("Expected a fallback color")
            return
        }
        #expect(color == Color.red.opacity(expected))
        guard case .fallbackColor(level: 0) = shape.operation else {
            Issue.record("Expected fallback color resolution at level zero")
            return
        }
    }

    @Test
    func copiedStyleRetainsOpacity() {
        var shape = _ShapeStyle_Shape(operation: .copyStyle(name: .foreground))
        _OpacityShapeStyle(style: TestStyle(), opacity: 0.5)._apply(to: &shape)
        guard case let .style(copied) = shape.result else {
            Issue.record("Expected a copied style")
            return
        }
        shape.operation = .fallbackColor(level: 0)
        copied._apply(to: &shape)
        guard case let .color(color) = shape.result else {
            Issue.record("Expected the copied style's fallback color")
            return
        }
        #expect(color == Color.red.opacity(0.5))
    }

    @Test
    func opacitiesDeclareMultipleLevels() {
        var shape = _ShapeStyle_Shape(operation: .multiLevel)
        _OpacitiesShapeStyle(style: TestStyle(), opacities: [])._apply(to: &shape)
        guard case .bool(true) = shape.result else {
            Issue.record("Expected a multilevel style even with no opacity values")
            return
        }
    }

    private struct TestStyle: ShapeStyle {
        func _apply(to shape: inout _ShapeStyle_Shape) {
            switch shape.operation {
            case .prepareText:
                shape.result = .preparedText(.foregroundColor(.red))
            case .resolveStyle:
                var style = _ShapeStyle_Pack.Style(.color(.white))
                style.opacity = 0.5
                style.effects = [.init(kind: .none, opacity: 0.25, _blend: nil)]
                var pack = _ShapeStyle_Pack.style(style, name: .foreground)
                for level in 1..<4 {
                    pack[.foreground, level] = style
                }
                pack[.background, 0] = style
                shape.result = .pack(pack)
            case let .fallbackColor(level):
                shape.result = .color(level == 0 ? .red : .blue)
            case .copyStyle:
                shape.result = .style(AnyShapeStyle(self))
            case .multiLevel:
                shape.result = .bool(false)
            case .modifyBackground, .primaryStyle:
                break
            }
        }
    }
}
