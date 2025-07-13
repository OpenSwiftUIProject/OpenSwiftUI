//
//  BezierAnimation.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete

package import Foundation

// MARK: - BezierAnimation

package struct BezierAnimation: InternalCustomAnimation {
    package var duration: TimeInterval
    package var curve: UnitCurve.CubicSolver

    package init(curve: UnitCurve.CubicSolver, duration: TimeInterval) {
        self.duration = duration
        self.curve = curve
    }

    package init(
        _ c0x: Double,
        _ c0y: Double,
        _ c1x: Double,
        _ c1y: Double,
        duration: TimeInterval
    ) {
        self.duration = duration
        self.curve = UnitCurve.CubicSolver(
            startControlPoint: UnitPoint(x: c0x, y: c0y),
            endControlPoint: UnitPoint(x: c1x, y: c1y)
        )
    }

    @_specialize(exported: false, kind: partial, where V == Double)
    @_specialize(exported: false, kind: partial, where V == AnimatablePair<AnimatablePair<CGFloat, CGFloat>, AnimatablePair<CGFloat, CGFloat>>)
    package func animate<V>(
        value: V,
        time: TimeInterval,
        context: inout AnimationContext<V>
    ) -> V? where V: VectorArithmetic {
        fraction(for: time).map { fraction in
            var result = value
            result.scale(by: fraction)
            return result
        }
    }

    package func fraction(for elapsed: TimeInterval) -> Double? {
        guard duration > 0, duration >= elapsed else {
            return nil
        }
        return curve.value(at: elapsed.clamp(min: 0.0, max: 1.0))
    }

    package var function: Animation.Function {
        .bezier(
            duration: duration,
            cp1: CGPoint(x: curve.startControlPoint.x, y: curve.startControlPoint.y),
            cp2: CGPoint(x: curve.endControlPoint.x, y: curve.endControlPoint.y)
        )
    }
}

// MARK: - BezierTimingFunction

package struct BezierTimingFunction<T>: Equatable where T: BinaryFloatingPoint {
    package var p1x: T, p1y: T, p2x: T, p2y: T

    package init<U>(p1: (U, U), p2: (U, U)) where U: BinaryFloatingPoint {
        self.p1x = T(p1.0)
        self.p1y = T(p1.1)
        self.p2x = T(p2.0)
        self.p2y = T(p2.1)
    }

    package static var linear: BezierTimingFunction<T> {
        BezierTimingFunction(p1: (T(0), T(0)), p2: (T(1), T(1)))
    }

    package var p1: (T, T) {
        get { (p1x, p1y) }
        set { 
            p1x = newValue.0
            p1y = newValue.1
        }
    }

    package var p2: (T, T) {
        get { (p2x, p2y) }
        set { 
            p2x = newValue.0
            p2y = newValue.1
        }
    }
}

// MARK: - BezierAnimation + ProtobufMessage

extension BezierAnimation: ProtobufMessage {
    package func encode(to encoder: inout ProtobufEncoder) throws {
        encoder.doubleField(1, duration)
        if curve != .init(
            startControlPoint: UnitPoint(x: 0.0, y: 0.0),
            endControlPoint: UnitPoint(x: 1.0, y: 1.0)
        ) {
            encoder.packedField(2) { encoder in
                curve.encode(to: &encoder)
            }
        }
    }

    package init(from decoder: inout ProtobufDecoder) throws {
        var duration: TimeInterval = .zero
        var curve = UnitCurve.CubicSolver(
            startControlPoint: .init(x: 0.0, y: 0.0),
            endControlPoint: .init(x: 1.0, y: 1.0)
        )
        while let field = try decoder.nextField() {
            switch field.tag {
            case 1: duration = try decoder.doubleField(field)
            case 2: curve = try decoder.messageField(field) { decoder in
                try UnitCurve.CubicSolver.init(from: &decoder)
            }
            default: try decoder.skipField(field)
            }
        }
        self.init(
            curve: curve,
            duration: duration
        )
    }
}
