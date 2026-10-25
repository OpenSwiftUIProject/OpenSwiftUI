//
//  ShapeStylePackTests.swift
//  OpenSwiftUICoreTests

import Foundation
@testable import OpenSwiftUICore
import OpenSwiftUITestsSupport
import Testing

// MARK: - _ShapeStyle_Pack.Fill + Animatable

@MainActor
@Suite(.tags(.aigc))
struct ShapeStylePackFillAnimationTests {
    @Test(arguments: GradientKind.allCases)
    func gradientDataReadsAndUpdatesTheConcretePaint(kind: GradientKind) {
        Semantics.v5.test {
            let original = ResolvedGradient(stops: [
                .init(color: .init(linearRed: 1, linearGreen: 0, linearBlue: 0), location: 0.25),
            ], colorSpace: .linear)
            let replacement = ResolvedGradient(stops: [
                .init(color: .init(linearRed: 0, linearGreen: 1, linearBlue: 0), location: 0.75),
            ], colorSpace: .linear)
            var fill = _ShapeStyle_Pack.Fill.paint(kind.paint(component: 1, gradient: original))
            #expect(fill.animatableData == kind.data(component: 1, gradient: ResolvedGradientVector(original)))
            #expect(fill.animatableData.magnitudeSquared == 6)

            fill.animatableData = kind.data(component: 2, gradient: ResolvedGradientVector(replacement))
            #expect(fill == .paint(kind.paint(component: 2, gradient: replacement)))
            #expect(fill.animatableData.magnitudeSquared == 18)
        }
    }

    @Test(arguments: GradientKind.allCases)
    func gradientArithmeticPreservesTheCase(kind: GradientKind) {
        let one = kind.data(component: 1)
        let two = kind.data(component: 2)
        #expect(one + two == kind.data(component: 3))
        #expect(one - two == kind.data(component: -1))
        #expect(.zero + one == one)
        #expect(.zero - one == kind.data(component: -1))
        #expect(one + .zero == one)
        #expect(one - .zero == one)
        #expect(one.magnitudeSquared == 4)

        var scaled = one
        scaled.scale(by: 2)
        #expect(scaled == two)
        #expect(scaled.magnitudeSquared == 16)
        scaled.scale(by: 0)
        #expect(scaled == kind.data(component: 0))
        #expect(scaled != .zero)
    }

    @Test(arguments: GradientKind.allCases, GradientKind.allCases)
    func differentGradientCasesKeepTheLeftOperand(lhsKind: GradientKind, rhsKind: GradientKind) {
        guard lhsKind != rhsKind else { return }
        let lhs = lhsKind.data(component: 1)
        let rhs = rhsKind.data(component: 2)
        #expect(lhs != rhsKind.data(component: 1))
        #expect(lhs + rhs == lhs)
        #expect(lhs - rhs == lhs)

        var fill = _ShapeStyle_Pack.Fill.paint(lhsKind.paint(component: 1))
        fill.animatableData = rhs
        #expect(fill == .color(.clear))
    }

    @Test(arguments: GradientKind.allCases)
    func subtractionFromZeroUsesGradientVectorSubtraction(kind: GradientKind) {
        let gradient = ResolvedGradient(stops: [
            .init(
                color: .init(linearRed: 1, linearGreen: 0, linearBlue: 0),
                location: 0.25,
                interpolation: .linear
            ),
        ], colorSpace: .linear)
        let expected = ResolvedGradient(stops: [
            .init(color: .init(linearRed: 1, linearGreen: 0, linearBlue: 0, opacity: -1), location: 0.25),
        ], colorSpace: .linear)
        let data = kind.data(component: 1, gradient: ResolvedGradientVector(gradient))
        #expect(.zero - data == kind.data(component: -1, gradient: ResolvedGradientVector(expected)))
    }

    @Test(arguments: GradientKind.allCases)
    func zeroAndColorDataDoNotReplaceGradientPaint(kind: GradientKind) {
        let original = _ShapeStyle_Pack.Fill.paint(kind.paint(component: 1))
        var fill = original
        fill.animatableData = .zero
        #expect(fill == original)
        fill.animatableData = .color(.zero)
        #expect(fill == original)

        let gradient = kind.data(component: 1)
        let color = _ShapeStyle_Pack.Fill.AnimatableData.color(.init(1, .zero))
        #expect(gradient + color == gradient)
        #expect(gradient - color == gradient)
        #expect(color + gradient == color)
        #expect(color - gradient == color)
        #expect(.zero - color == color)
    }

    @Test
    func unknownPaintDoesNotExposeGradientData() {
        let paint = LinearGradient._Paint(gradient: .init(), startPoint: .zero, endPoint: .center)
        let anchored = AnchoredResolvedPaint(paint, bounds: CGRect(x: 1, y: 2, width: 3, height: 4))
        var fill = _ShapeStyle_Pack.Fill.paint(_AnyResolvedPaint(anchored))
        #expect(fill.animatableData == .zero)
        fill.animatableData = GradientKind.linear.data(component: 1)
        #expect(fill == .color(.clear))
    }

    enum GradientKind: CaseIterable {
        case linear, radial, elliptical, angular

        func paint(component: CGFloat, gradient: ResolvedGradient = .init()) -> AnyResolvedPaint {
            let point = UnitPoint(x: component / 128, y: component / 128)
            switch self {
            case .linear:
                return _AnyResolvedPaint(LinearGradient._Paint(
                    gradient: gradient, startPoint: point, endPoint: point
                ))
            case .radial:
                return _AnyResolvedPaint(RadialGradient._Paint(
                    gradient: gradient, center: point, startRadius: component, endRadius: component
                ))
            case .elliptical:
                return _AnyResolvedPaint(EllipticalGradient._Paint(
                    gradient: gradient, center: point, startRadiusFraction: component, endRadiusFraction: component
                ))
            case .angular:
                let angle = Angle(radians: Double(component) / 128)
                return _AnyResolvedPaint(AngularGradient._Paint(
                    gradient: gradient, center: point, startAngle: angle, endAngle: angle
                ))
            }
        }

        func data(component: CGFloat, gradient: ResolvedGradientVector = .zero) -> _ShapeStyle_Pack.Fill.AnimatableData {
            let point = AnimatablePair(component, component)
            switch self {
            case .linear:
                return .linearGradient(.init(.init(point, point), gradient))
            case .radial:
                return .radialGradient(.init(.init(point, gradient), point))
            case .elliptical:
                return .ellipticalGradient(.init(.init(point, gradient), point))
            case .angular:
                let angle = Double(component)
                return .angularGradient(.init(.init(point, gradient), .init(angle, angle)))
            }
        }
    }
}
