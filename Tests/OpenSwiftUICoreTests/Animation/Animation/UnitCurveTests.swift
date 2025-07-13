//
//  UnitCurveTests.swift
//  OpenSwiftUICoreTests

@testable import OpenSwiftUICore
import Testing

// MARK: - UnitCurveTests

struct UnitCurveTests {
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
        #expect(solver.value(at: 0.5).isApproximatelyEqual(to: 0.5))
    }

    @Test
    func cubicSolverVelocityCalculation() {
        let startPoint = UnitPoint(x: 0.25, y: 0.1)
        let endPoint = UnitPoint(x: 0.75, y: 0.9)
        let solver = UnitCurve.CubicSolver(startControlPoint: startPoint, endControlPoint: endPoint)
        #expect(solver.velocity(at: 0.5).isApproximatelyEqual(to: 1.199, absoluteTolerance: 0.001))
    }

    // MARK: - Edge Cases

    @Test
    func extremeProgressValues() {
        let curve = UnitCurve.easeInOut

        #expect(curve.value(at: -1000.0).isApproximatelyEqual(to: 0.0))
        #expect(curve.value(at: 1000.0).isApproximatelyEqual(to: 1.0))
        #expect(curve.velocity(at: -1000.0).isApproximatelyEqual(to: 0.0))
        #expect(curve.velocity(at: 1000.0).isApproximatelyEqual(to: 0.0))
    }

    @Test
    func bezierWithIdenticalControlPoints() {
        let point = UnitPoint(x: 0.5, y: 0.5)
        let curve = UnitCurve.bezier(startControlPoint: point, endControlPoint: point)

        #expect(curve.value(at: 0.0).isApproximatelyEqual(to: 0.0))
        #expect(curve.value(at: 1.0).isApproximatelyEqual(to: 1.0))
        #expect(curve.value(at: 0.5).isApproximatelyEqual(to: 0.5))
        #expect(curve.velocity(at: 0.5).isApproximatelyEqual(to: 1.0))
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
