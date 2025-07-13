//
//  UnitCurveTests.swift
//  OpenSwiftUICoreTests

@testable import OpenSwiftUICore
import Testing

// MARK: - UnitCurveTests [Implmeneted by Copilot]

struct UnitCurveTests {
    // MARK: - Static Curve Properties

    @Test
    func linearCurve() {
        let curve = UnitCurve.linear

        #expect(curve.value(at: 0.0).isApproximatelyEqual(to: 0.0))
        #expect(curve.value(at: 0.5).isApproximatelyEqual(to: 0.5))
        #expect(curve.value(at: 1.0).isApproximatelyEqual(to: 1.0))

        #expect(curve.velocity(at: 0.0).isApproximatelyEqual(to: 1.0))
        #expect(curve.velocity(at: 0.5).isApproximatelyEqual(to: 1.0))
        #expect(curve.velocity(at: 1.0).isApproximatelyEqual(to: 1.0))
    }

    @Test
    func easeInCurve() {
        let curve = UnitCurve.easeIn

        #expect(curve.value(at: 0.0).isApproximatelyEqual(to: 0.0))
        #expect(curve.value(at: 1.0).isApproximatelyEqual(to: 1.0))

        let midValue = curve.value(at: 0.5)
        #expect(midValue > 0.0)
        #expect(midValue < 0.5)
    }

    @Test
    func easeOutCurve() {
        let curve = UnitCurve.easeOut

        #expect(curve.value(at: 0.0).isApproximatelyEqual(to: 0.0))
        #expect(curve.value(at: 1.0).isApproximatelyEqual(to: 1.0))

        let midValue = curve.value(at: 0.5)
        #expect(midValue > 0.5)
        #expect(midValue < 1.0)
    }

    @Test
    func easeInOutCurve() {
        let curve = UnitCurve.easeInOut

        #expect(curve.value(at: 0.0).isApproximatelyEqual(to: 0.0))
        #expect(curve.value(at: 0.5).isApproximatelyEqual(to: 0.5))
        #expect(curve.value(at: 1.0).isApproximatelyEqual(to: 1.0))

        let quarterValue = curve.value(at: 0.25)
        #expect(quarterValue > 0.0)
        #expect(quarterValue < 0.25)

        let threeQuarterValue = curve.value(at: 0.75)
        #expect(threeQuarterValue > 0.75)
        #expect(threeQuarterValue < 1.0)
    }

    @Test
    func easeInEaseOutDeprecated() {
        let curve = UnitCurve.easeInEaseOut
        let easeInOut = UnitCurve.easeInOut

        #expect(curve.value(at: 0.0).isApproximatelyEqual(to: easeInOut.value(at: 0.0)))
        #expect(curve.value(at: 0.5).isApproximatelyEqual(to: easeInOut.value(at: 0.5)))
        #expect(curve.value(at: 1.0).isApproximatelyEqual(to: easeInOut.value(at: 1.0)))
    }

    @Test
    func circularEaseInCurve() {
        let curve = UnitCurve.circularEaseIn

        #expect(curve.value(at: 0.0).isApproximatelyEqual(to: 0.0))
        #expect(curve.value(at: 1.0).isApproximatelyEqual(to: 1.0))

        let midValue = curve.value(at: 0.5)
        #expect(midValue > 0.0)
        #expect(midValue < 0.5)
    }

    @Test
    func circularEaseOutCurve() {
        let curve = UnitCurve.circularEaseOut

        #expect(curve.value(at: 0.0).isApproximatelyEqual(to: 0.0))
        #expect(curve.value(at: 1.0).isApproximatelyEqual(to: 1.0))

        let midValue = curve.value(at: 0.5)
        #expect(midValue > 0.5)
        #expect(midValue < 1.0)
    }

    @Test
    func circularEaseInOutCurve() {
        let curve = UnitCurve.circularEaseInOut

        #expect(curve.value(at: 0.0).isApproximatelyEqual(to: 0.0))
        #expect(curve.value(at: 0.5).isApproximatelyEqual(to: 0.5))
        #expect(curve.value(at: 1.0).isApproximatelyEqual(to: 1.0))
    }

    // MARK: - Bezier Curve Creation

    @Test
    func bezierCurveCreation() {
        let startPoint = UnitPoint(x: 0.25, y: 0.1)
        let endPoint = UnitPoint(x: 0.75, y: 0.9)
        let curve = UnitCurve.bezier(startControlPoint: startPoint, endControlPoint: endPoint)

        #expect(curve.value(at: 0.0).isApproximatelyEqual(to: 0.0))
        #expect(curve.value(at: 1.0).isApproximatelyEqual(to: 1.0))
    }

    @Test
    func bezierCurveWithExtremeControlPoints() {
        let startPoint = UnitPoint(x: -0.5, y: 2.0)
        let endPoint = UnitPoint(x: 1.5, y: -1.0)
        let curve = UnitCurve.bezier(startControlPoint: startPoint, endControlPoint: endPoint)

        #expect(curve.value(at: 0.0).isApproximatelyEqual(to: 0.0))
        #expect(curve.value(at: 1.0).isApproximatelyEqual(to: 1.0))
    }

    // MARK: - Value Function

    @Test
    func valueAtBoundaryConditions() {
        let curve = UnitCurve.easeInOut

        #expect(curve.value(at: -0.5).isApproximatelyEqual(to: 0.0))
        #expect(curve.value(at: 0.0).isApproximatelyEqual(to: 0.0))
        #expect(curve.value(at: 1.0).isApproximatelyEqual(to: 1.0))
        #expect(curve.value(at: 1.5).isApproximatelyEqual(to: 1.0))
    }

    @Test
    func valueAtVariousProgressPoints() {
        let curve = UnitCurve.linear

        for progress in stride(from: 0.0, through: 1.0, by: 0.1) {
            let value = curve.value(at: progress)
            #expect(value >= 0.0)
            #expect(value <= 1.0)
        }
    }

    // MARK: - Velocity Function

    @Test
    func velocityAtBoundaryConditions() {
        let curve = UnitCurve.linear

        #expect(curve.velocity(at: -0.5).isApproximatelyEqual(to: 1.0))
        #expect(curve.velocity(at: 0.0).isApproximatelyEqual(to: 1.0))
        #expect(curve.velocity(at: 1.0).isApproximatelyEqual(to: 1.0))
        #expect(curve.velocity(at: 1.5).isApproximatelyEqual(to: 1.0))
    }

    @Test
    func velocityForCircularCurves() {
        let easeIn = UnitCurve.circularEaseIn
        let easeOut = UnitCurve.circularEaseOut
        let easeInOut = UnitCurve.circularEaseInOut

        #expect(easeIn.velocity(at: 0.5) > 0.0)
        #expect(easeOut.velocity(at: 0.5) > 0.0)
        #expect(easeInOut.velocity(at: 0.5) > 0.0)
    }

    // MARK: - Inverse Property

    @Test
    func linearCurveInverse() {
        let curve = UnitCurve.linear
        let inverse = curve.inverse

        #expect(inverse.value(at: 0.0).isApproximatelyEqual(to: 0.0))
        #expect(inverse.value(at: 0.5).isApproximatelyEqual(to: 0.5))
        #expect(inverse.value(at: 1.0).isApproximatelyEqual(to: 1.0))
    }

    @Test
    func circularCurveInverse() {
        let easeIn = UnitCurve.circularEaseIn
        let easeOut = UnitCurve.circularEaseOut
        let easeInOut = UnitCurve.circularEaseInOut

        #expect(easeIn.inverse.value(at: 0.0).isApproximatelyEqual(to: 0.0))
        #expect(easeIn.inverse.value(at: 1.0).isApproximatelyEqual(to: 1.0))
        #expect(easeOut.inverse.value(at: 0.0).isApproximatelyEqual(to: 0.0))
        #expect(easeOut.inverse.value(at: 1.0).isApproximatelyEqual(to: 1.0))
        #expect(easeInOut.inverse.value(at: 0.0).isApproximatelyEqual(to: 0.0))
        #expect(easeInOut.inverse.value(at: 1.0).isApproximatelyEqual(to: 1.0))
    }

    @Test
    func bezierCurveInverse() {
        let startPoint = UnitPoint(x: 0.25, y: 0.1)
        let endPoint = UnitPoint(x: 0.75, y: 0.9)
        let curve = UnitCurve.bezier(startControlPoint: startPoint, endControlPoint: endPoint)
        let inverse = curve.inverse

        #expect(inverse.value(at: 0.0).isApproximatelyEqual(to: 0.0))
        #expect(inverse.value(at: 1.0).isApproximatelyEqual(to: 1.0))
    }

    // MARK: - CubicSolver

    @Test
    func cubicSolverInitialization() {
        let startPoint = UnitPoint(x: 0.25, y: 0.1)
        let endPoint = UnitPoint(x: 0.75, y: 0.9)
        let solver = UnitCurve.CubicSolver(startControlPoint: startPoint, endControlPoint: endPoint)

        #expect(solver.startControlPoint.x.isApproximatelyEqual(to: 0.25))
        #expect(solver.startControlPoint.y.isApproximatelyEqual(to: 0.1))
        #expect(solver.endControlPoint.x.isApproximatelyEqual(to: 0.75))
        #expect(solver.endControlPoint.y.isApproximatelyEqual(to: 0.9))
    }

    @Test
    func cubicSolverValueCalculation() {
        let startPoint = UnitPoint(x: 0.25, y: 0.1)
        let endPoint = UnitPoint(x: 0.75, y: 0.9)
        let solver = UnitCurve.CubicSolver(startControlPoint: startPoint, endControlPoint: endPoint)

        #expect(solver.value(at: 0.0).isApproximatelyEqual(to: 0.0))
        #expect(solver.value(at: 1.0).isApproximatelyEqual(to: 1.0))

        let midValue = solver.value(at: 0.5)
        #expect(midValue >= 0.0)
        #expect(midValue <= 1.0)
    }

    @Test
    func cubicSolverVelocityCalculation() {
        let startPoint = UnitPoint(x: 0.25, y: 0.1)
        let endPoint = UnitPoint(x: 0.75, y: 0.9)
        let solver = UnitCurve.CubicSolver(startControlPoint: startPoint, endControlPoint: endPoint)

        let velocity = solver.velocity(at: 0.5)
        #expect(velocity.isFinite)
    }

    // MARK: - Hashable and Sendable

    @Test
    func hashableConformance() {
        let curve1 = UnitCurve.linear
        let curve2 = UnitCurve.linear
        let curve3 = UnitCurve.easeIn

        #expect(curve1.hashValue == curve2.hashValue)
        #expect(curve1.hashValue != curve3.hashValue)
    }

    @Test
    func equatableConformance() {
        let curve1 = UnitCurve.linear
        let curve2 = UnitCurve.linear
        let curve3 = UnitCurve.easeIn

        #expect(curve1 == curve2)
        #expect(curve1 != curve3)
    }

    // MARK: - Edge Cases

    @Test
    func extremeProgressValues() {
        let curve = UnitCurve.easeInOut

        #expect(curve.value(at: -1000.0).isApproximatelyEqual(to: 0.0))
        #expect(curve.value(at: 1000.0).isApproximatelyEqual(to: 1.0))
        #expect(curve.velocity(at: -1000.0) >= 0.0)
        #expect(curve.velocity(at: 1000.0) >= 0.0)
    }

    @Test
    func bezierWithIdenticalControlPoints() {
        let point = UnitPoint(x: 0.5, y: 0.5)
        let curve = UnitCurve.bezier(startControlPoint: point, endControlPoint: point)

        #expect(curve.value(at: 0.0).isApproximatelyEqual(to: 0.0))
        #expect(curve.value(at: 0.5).isApproximatelyEqual(to: 0.5))
        #expect(curve.value(at: 1.0).isApproximatelyEqual(to: 1.0))
    }

    @Test
    func circularEaseInOutTransition() {
        let curve = UnitCurve.circularEaseInOut

        let belowMid = curve.value(at: 0.49)
        let mid = curve.value(at: 0.5)
        let aboveMid = curve.value(at: 0.51)

        #expect(belowMid < mid)
        #expect(mid < aboveMid)
        #expect(mid.isApproximatelyEqual(to: 0.5))
    }
}
