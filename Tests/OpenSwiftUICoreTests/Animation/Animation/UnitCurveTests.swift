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

    @Test(arguments: [
        (0.0, 1.0, -0.0001, 0.0),
        (1.0, 0.0, 1.0001, 1.0),
    ])
    func cubicSolverClampsFallbackEndpoints(x: Double, y: Double, progress: Double, expected: Double) {
        let point = UnitPoint(x: x, y: y)
        let solver = UnitCurve.CubicSolver(startControlPoint: point, endControlPoint: point)

        #expect(solver.value(at: progress) == expected)
    }

    @Test
    func cubicSolverDoesNotClampAcceptedInput() {
        let solver = UnitCurve.CubicSolver(
            startControlPoint: UnitPoint(x: 1.0 / 3.0, y: 1.0 / 3.0),
            endControlPoint: UnitPoint(x: 2.0 / 3.0, y: 2.0 / 3.0)
        )

        #expect(solver.value(at: -1.0) == -1.0)
        #expect(solver.value(at: 2.0) == 2.0)
    }

    @Test
    func cubicSolverBoundsUnorderedBisection() {
        // NaN x controls prevent convergence. A large finite y scale keeps
        // the final midpoint visible after output rounding.
        let point = UnitPoint(x: .nan, y: 0x1p1022)
        let solver = UnitCurve.CubicSolver(startControlPoint: point, endControlPoint: point)

        #expect(solver.value(at: 0.5) == 0.375)
    }

    @Test
    func cubicSolverPreservesNaNInput() {
        let solver = UnitCurve.CubicSolver(
            startControlPoint: UnitPoint(x: 0.25, y: 0.1),
            endControlPoint: UnitPoint(x: 0.75, y: 0.9)
        )

        #expect(solver.value(at: .nan).isNaN)
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
