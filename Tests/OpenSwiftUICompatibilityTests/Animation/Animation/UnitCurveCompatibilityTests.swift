//
//  UnitCurveCompatibilityTests.swift
//  OpenSwiftUICompatibilityTests

import Testing
import Numerics

// MARK: - UnitCurveTests

struct UnitCurveCompatibilityTests {
    @Test
    func linearCurve() {
        let curve = UnitCurve.linear

        #expect(curve.value(at: 0.0).isApproximatelyEqual(to: 0.0))
        #expect(curve.value(at: 0.25).isApproximatelyEqual(to: 0.25))
        #expect(curve.value(at: 0.5).isApproximatelyEqual(to: 0.5))
        #expect(curve.value(at: 0.75).isApproximatelyEqual(to: 0.75))
        #expect(curve.value(at: 1.0).isApproximatelyEqual(to: 1.0))

        #expect(curve.velocity(at: 0.0).isApproximatelyEqual(to: 1.0))
        #expect(curve.velocity(at: 0.25).isApproximatelyEqual(to: 1.0))
        #expect(curve.velocity(at: 0.5).isApproximatelyEqual(to: 1.0))
        #expect(curve.velocity(at: 0.75).isApproximatelyEqual(to: 1.0))
        #expect(curve.velocity(at: 1.0).isApproximatelyEqual(to: 1.0))
    }

    @Test
    func easeInCurve() {
        let curve = UnitCurve.easeIn

        #expect(curve.value(at: 0.0).isApproximatelyEqual(to: 0.0))
        #expect(curve.value(at: 0.25).isApproximatelyEqual(to: 0.09, absoluteTolerance: 0.01))
        #expect(curve.value(at: 0.5).isApproximatelyEqual(to: 0.32, absoluteTolerance: 0.01))
        #expect(curve.value(at: 0.75).isApproximatelyEqual(to: 0.62, absoluteTolerance: 0.01))
        #expect(curve.value(at: 1.0).isApproximatelyEqual(to: 1.0))

        #expect(curve.velocity(at: 0.0).isApproximatelyEqual(to: 0.0))
        #expect(curve.velocity(at: 0.25).isApproximatelyEqual(to: 0.67, absoluteTolerance: 0.01))
        #expect(curve.velocity(at: 0.5).isApproximatelyEqual(to: 1.07, absoluteTolerance: 0.01))
        #expect(curve.velocity(at: 0.75).isApproximatelyEqual(to: 1.37, absoluteTolerance: 0.01))
        #expect(curve.velocity(at: 1.0).isApproximatelyEqual(to: 0.0))
    }

    @Test
    func easeOutCurve() {
        let curve = UnitCurve.easeOut

        #expect(curve.value(at: 0.0).isApproximatelyEqual(to: 0.0))
        #expect(curve.value(at: 0.25).isApproximatelyEqual(to: 0.38, absoluteTolerance: 0.01))
        #expect(curve.value(at: 0.5).isApproximatelyEqual(to: 0.68, absoluteTolerance: 0.01))
        #expect(curve.value(at: 0.75).isApproximatelyEqual(to: 0.91, absoluteTolerance: 0.01))
        #expect(curve.value(at: 1.0).isApproximatelyEqual(to: 1.0))

        #expect(curve.velocity(at: 0.0).isApproximatelyEqual(to: 1.0, absoluteTolerance: 0.01))
        #expect(curve.velocity(at: 0.25).isApproximatelyEqual(to: 1.37, absoluteTolerance: 0.01))
        #expect(curve.velocity(at: 0.5).isApproximatelyEqual(to: 1.07, absoluteTolerance: 0.01))
        #expect(curve.velocity(at: 0.75).isApproximatelyEqual(to: 0.67, absoluteTolerance: 0.01))
        #expect(curve.velocity(at: 1.0).isApproximatelyEqual(to: 0.0))
    }

    @Test
    func easeInOutCurve() {
        let curve = UnitCurve.easeInOut

        #expect(curve.value(at: 0.0).isApproximatelyEqual(to: 0.0))
        #expect(curve.value(at: 0.25).isApproximatelyEqual(to: 0.13, absoluteTolerance: 0.01))
        #expect(curve.value(at: 0.5).isApproximatelyEqual(to: 0.5))
        #expect(curve.value(at: 0.75).isApproximatelyEqual(to: 0.87, absoluteTolerance: 0.01))
        #expect(curve.value(at: 1.0).isApproximatelyEqual(to: 1.0))

        #expect(curve.velocity(at: 0.0).isApproximatelyEqual(to: 0.0))
        #expect(curve.velocity(at: 0.25).isApproximatelyEqual(to: 1.06, absoluteTolerance: 0.01))
        #expect(curve.velocity(at: 0.5).isApproximatelyEqual(to: 1.72, absoluteTolerance: 0.01))
        #expect(curve.velocity(at: 0.75).isApproximatelyEqual(to: 1.06, absoluteTolerance: 0.01))
        #expect(curve.velocity(at: 1.0).isApproximatelyEqual(to: 0.0))
    }

    @Test
    func circularEaseInCurve() {
        let curve = UnitCurve.circularEaseIn

        #expect(curve.value(at: 0.0).isApproximatelyEqual(to: 0.0))
        #expect(curve.value(at: 0.25).isApproximatelyEqual(to: 0.032, absoluteTolerance: 0.001))
        #expect(curve.value(at: 0.5).isApproximatelyEqual(to: 0.134, absoluteTolerance: 0.001))
        #expect(curve.value(at: 0.75).isApproximatelyEqual(to: 0.339, absoluteTolerance: 0.001))
        #expect(curve.value(at: 1.0).isApproximatelyEqual(to: 1.0))

        #expect(curve.velocity(at: 0.0).isApproximatelyEqual(to: 0.0))
        #expect(curve.velocity(at: 0.25).isApproximatelyEqual(to: 0.258, absoluteTolerance: 0.001))
        #expect(curve.velocity(at: 0.5).isApproximatelyEqual(to: 0.577, absoluteTolerance: 0.001))
        #expect(curve.velocity(at: 0.75).isApproximatelyEqual(to: 1.134, absoluteTolerance: 0.001))
        #expect(curve.velocity(at: 1.0).isApproximatelyEqual(to: .infinity))
    }

    @Test
    func circularEaseOutCurve() {
        let curve = UnitCurve.circularEaseOut

        #expect(curve.value(at: 0.0).isApproximatelyEqual(to: 0.0))
        #expect(curve.value(at: 0.25).isApproximatelyEqual(to: 0.661, absoluteTolerance: 0.001))
        #expect(curve.value(at: 0.5).isApproximatelyEqual(to: 0.866, absoluteTolerance: 0.001))
        #expect(curve.value(at: 0.75).isApproximatelyEqual(to: 0.968, absoluteTolerance: 0.001))
        #expect(curve.value(at: 1.0).isApproximatelyEqual(to: 1.0))

        #expect(curve.velocity(at: 0.0).isApproximatelyEqual(to: .infinity))
        #expect(curve.velocity(at: 0.25).isApproximatelyEqual(to: 1.134, absoluteTolerance: 0.001))
        #expect(curve.velocity(at: 0.5).isApproximatelyEqual(to: 0.577, absoluteTolerance: 0.001))
        #expect(curve.velocity(at: 0.75).isApproximatelyEqual(to: 0.258, absoluteTolerance: 0.001))
        #expect(curve.velocity(at: 1.0).isApproximatelyEqual(to: 0.0))
    }

    @Test
    func circularEaseInOutCurve() {
        let curve = UnitCurve.circularEaseInOut

        #expect(curve.value(at: 0.0).isApproximatelyEqual(to: 0.0))
        #expect(curve.value(at: 0.25).isApproximatelyEqual(to: 0.067, absoluteTolerance: 0.001))
        #expect(curve.value(at: 0.5).isApproximatelyEqual(to: 0.5))
        #expect(curve.value(at: 0.75).isApproximatelyEqual(to: 0.933, absoluteTolerance: 0.001))
        #expect(curve.value(at: 1.0).isApproximatelyEqual(to: 1.0))

        #expect(curve.velocity(at: 0.0).isApproximatelyEqual(to: 0.0))
        #expect(curve.velocity(at: 0.25).isApproximatelyEqual(to: 0.577, absoluteTolerance: 0.001))
        #expect(curve.velocity(at: 0.5).isApproximatelyEqual(to: .infinity, absoluteTolerance: 0.001))
        #expect(curve.velocity(at: 0.75).isApproximatelyEqual(to: 0.577, absoluteTolerance: 0.001))
        #expect(curve.velocity(at: 1.0).isApproximatelyEqual(to: 0.0))
    }

    // MARK: - Bezier Curve Creation

    @Test
    func bezierCurveCreation() {
        let startPoint = UnitPoint(x: 0.25, y: 0.1)
        let endPoint = UnitPoint(x: 0.75, y: 0.9)
        let curve = UnitCurve.bezier(startControlPoint: startPoint, endControlPoint: endPoint)

        #expect(curve.value(at: 0.0).isApproximatelyEqual(to: 0.0))
        #expect(curve.value(at: 1.0).isApproximatelyEqual(to: 1.0))
        #expect(curve.value(at: 0.5).isApproximatelyEqual(to: 0.5, absoluteTolerance: 0.01))
        #expect(curve.velocity(at: 0.5).isApproximatelyEqual(to: 1.20, absoluteTolerance: 0.01))
    }

    @Test
    func bezierCurveWithExtremeControlPoints() {
        let startPoint = UnitPoint(x: -0.5, y: 2.0)
        let endPoint = UnitPoint(x: 1.5, y: -1.0)
        let curve = UnitCurve.bezier(startControlPoint: startPoint, endControlPoint: endPoint)

        #expect(curve.value(at: 0.0).isApproximatelyEqual(to: 0.0))
        #expect(curve.value(at: 1.0).isApproximatelyEqual(to: 1.0))
        #expect(curve.value(at: 0.5).isApproximatelyEqual(to: 0.5))
        #expect(curve.velocity(at: 0.5).isApproximatelyEqual(to: -1.0))
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

        #expect(easeIn.inverse.value(at: 0.3).isApproximatelyEqual(to: easeOut.value(at: 0.3)))
        #expect(easeIn.inverse.value(at: 0.7).isApproximatelyEqual(to: easeOut.value(at: 0.7)))

        #expect(easeIn.inverse.velocity(at: 0.3).isApproximatelyEqual(to: easeOut.velocity(at: 0.3)))
        #expect(easeIn.inverse.velocity(at: 0.7).isApproximatelyEqual(to: easeOut.velocity(at: 0.7)))
    }

    @Test
    func curveInverse() {
        let easeIn = UnitCurve.easeIn
        let easeOut = UnitCurve.easeOut

        #expect(!easeIn.inverse.value(at: 0.3).isApproximatelyEqual(to: easeOut.value(at: 0.3)))
        #expect(!easeIn.inverse.value(at: 0.7).isApproximatelyEqual(to: easeOut.value(at: 0.7)))

        #expect(!easeIn.inverse.velocity(at: 0.3).isApproximatelyEqual(to: easeOut.velocity(at: 0.3)))
        #expect(!easeIn.inverse.velocity(at: 0.7).isApproximatelyEqual(to: easeOut.velocity(at: 0.7)))
    }

    @Test
    func bezierCurveInverse() {
        let startPoint = UnitPoint(x: 0.25, y: 0.1)
        let endPoint = UnitPoint(x: 0.75, y: 0.9)
        let curve = UnitCurve.bezier(startControlPoint: startPoint, endControlPoint: endPoint)

        let inverseStartPoint = UnitPoint(x: 0.1, y: 0.25)
        let inverseEndPoint = UnitPoint(x: 0.9, y: 0.75)
        let inverse = UnitCurve.bezier(startControlPoint: inverseStartPoint, endControlPoint: inverseEndPoint)

        #expect(inverse.value(at: 0.3).isApproximatelyEqual(to: curve.inverse.value(at: 0.3)))
        #expect(inverse.value(at: 0.7).isApproximatelyEqual(to: curve.inverse.value(at: 0.7)))
    }
}
