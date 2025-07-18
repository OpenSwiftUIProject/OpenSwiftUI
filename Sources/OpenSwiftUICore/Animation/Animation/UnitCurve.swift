//
//  UnitCurve.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete (solveX needs verification)
//  ID: 54864F491103B6AE5CAC10D2D922245F (SwiftUICore)

package import Foundation

// MARK: - UnitCurve

/// A  function defined by a two-dimensional curve that maps an input
/// progress in the range [0,1] to an output progress that is also in the
/// range [0,1]. By changing the shape of the curve, the effective speed
/// of an animation or other interpolation can be changed.
///
/// The horizontal (x) axis defines the input progress: a single input
/// progress value in the range [0,1] must be provided when evaluating a
/// curve.
///
/// The vertical (y) axis maps to the output progress: when a curve is
/// evaluated, the y component of the point that intersects the input progress
/// is returned.
@available(OpenSwiftUI_v5_0, *)
public struct UnitCurve {
    package var function: UnitCurve.Function

    /// Creates a new curve using bezier control points.
    ///
    /// The x components of the control points are clamped to the range [0,1] when
    /// the curve is evaluated.
    ///
    /// - Parameters:
    ///   - startControlPoint: The cubic Bézier control point associated with
    ///     the curve's start point at (0, 0). The tangent vector from the
    ///     start point to its control point defines the initial velocity of
    ///     the timing function.
    ///   - endControlPoint: The cubic Bézier control point associated with the
    ///     curve's end point at (1, 1). The tangent vector from the end point
    ///     to its control point defines the final velocity of the timing
    ///     function.
    public static func bezier(
        startControlPoint: UnitPoint,
        endControlPoint: UnitPoint
    ) -> UnitCurve {
        .init(
            function: .bezier(
                startControlPoint: startControlPoint,
                endControlPoint: endControlPoint
            )
        )
    }

    /// Returns the output value (y component) of the curve at the given time.
    ///
    /// - Parameters:
    ///   - time: The input progress (x component). The provided value is
    ///     clamped to the range [0,1].
    ///
    /// - Returns: The output value (y component) of the curve at the given
    ///   progress.
    public func value(at progress: Double) -> Double {
        let clampValue = progress.clamp(min: 0.0, max: 1.0)
        switch function {
        case .linear:
            return progress
        case .circularEaseIn:
            return 1 - sqrt(1 - progress * progress)
        case .circularEaseOut:
            return sqrt(1 - (1 - progress) * (1 - progress))
        case .circularEaseInOut:
            if progress >= 0.5 {
                return (sqrt((8.0 - progress * 4.0) * progress - 3.0) + 1) * 0.5
            } else {
                return (1.0 - sqrt(1.0 - (progress * 4.0) * progress)) * 0.5

            }
        case let .bezier(startControlPoint, endControlPoint):
            let solver = CubicSolver(
                startControlPoint: UnitPoint(
                    x: startControlPoint.x.clamp(min: 0.0, max: 1.0),
                    y: startControlPoint.y.clamp(min: 0.0, max: 1.0)
                ),
                endControlPoint: UnitPoint(
                    x: endControlPoint.x.clamp(min: 0.0, max: 1.0),
                    y: endControlPoint.y.clamp(min: 0.0, max: 1.0)
                )
            )
            return solver.value(at: clampValue)
        }
    }

    /// Returns the rate of change (first derivative) of the output value of
    /// the curve at the given time.
    ///
    /// - Parameters:
    ///   - progress: The input progress (x component). The provided value is
    ///     clamped to the range [0,1].
    ///
    /// - Returns: The velocity of the output value (y component) of the curve
    ///   at the given time.
    public func velocity(at progress: Double) -> Double {
        let clampValue = progress.clamp(min: 0.0, max: 1.0)
        switch function {
        case .linear:
            return 1.0
        case .circularEaseIn:
            return abs(progress / sqrt(1 - progress * progress))
        case .circularEaseOut:
            return abs((progress - 1.0) / sqrt(-(progress - 2.0) * progress))
        case .circularEaseInOut:
            if progress >= 0.5 {
                return abs((progress + progress - 2) / sqrt(((progress * -4.0 + 8.0) * progress) - 3.0))
            } else {
                return abs((progress + progress) / sqrt((progress * -4.0 * progress) + 1.0))
            }
        case let .bezier(startControlPoint, endControlPoint):
            let solver = CubicSolver(
                startControlPoint: UnitPoint(
                    x: startControlPoint.x.clamp(min: 0.0, max: 1.0),
                    y: startControlPoint.y
                ),
                endControlPoint: UnitPoint(
                    x: endControlPoint.x.clamp(min: 0.0, max: 1.0),
                    y: endControlPoint.y
                )
            )
            return solver.velocity(at: clampValue)
        }
    }

    /// Returns a copy of the curve with its x and y components swapped.
    ///
    /// The inverse can be used to solve a curve in reverse: given a
    /// known output (y) value, the corresponding input (x) value can be found
    /// by using `inverse`:
    ///
    ///     let curve = UnitCurve.easeInOut
    ///
    ///     /// The input time for which an easeInOut curve returns 0.6.
    ///     let inputTime = curve.inverse.evaluate(at: 0.6)
    ///
    public var inverse: UnitCurve {
        switch function {
        case .linear: .linear
        case .circularEaseIn: .circularEaseOut
        case .circularEaseOut: .circularEaseIn
        case .circularEaseInOut: .circularEaseInOut
        case let .bezier(startControlPoint, endControlPoint):
            .bezier(
                startControlPoint: UnitPoint(x: startControlPoint.y, y: startControlPoint.x),
                endControlPoint: UnitPoint(x: endControlPoint.y, y: endControlPoint.x)
            )
        }
    }
}

extension UnitCurve {
    package enum Function: Hashable {
        case linear
        case circularEaseIn
        case circularEaseOut
        case circularEaseInOut
        case bezier(startControlPoint: UnitPoint, endControlPoint: UnitPoint)
    }
}

@available(OpenSwiftUI_v5_0, *)
extension UnitCurve: Sendable {}

@available(OpenSwiftUI_v5_0, *)
extension UnitCurve: Hashable {}

@available(OpenSwiftUI_v5_0, *)
extension UnitCurve {

    /// A bezier curve that starts out slowly, speeds up over the middle, then
    /// slows down again as it approaches the end.
    ///
    /// The start and end control points are located at (x: 0.42, y: 0) and
    /// (x: 0.58, y: 1).
    @available(*, deprecated, message: "Use easeInOut instead")
    public static let easeInEaseOut: UnitCurve = .easeInOut

    /// A bezier curve that starts out slowly, speeds up over the middle, then
    /// slows down again as it approaches the end.
    ///
    /// The start and end control points are located at (x: 0.42, y: 0) and
    /// (x: 0.58, y: 1).
    public static let easeInOut: UnitCurve = .init(
        function: .bezier(
            startControlPoint: UnitPoint(x: 0.42, y: 0),
            endControlPoint: UnitPoint(x: 0.58, y: 1)
        )
    )

    /// A bezier curve that starts out slowly, then speeds up as it finishes.
    ///
    /// The start and end control points are located at (x: 0.42, y: 0) and
    /// (x: 1, y: 1).
    public static let easeIn: UnitCurve = .init(
        function: .bezier(
            startControlPoint: UnitPoint(x: 0.42, y: 0),
            endControlPoint: UnitPoint(x: 1, y: 1)
        )
    )

    /// A bezier curve that starts out quickly, then slows down as it
    /// approaches the end.
    ///
    /// The start and end control points are located at (x: 0, y: 0) and
    /// (x: 0.58, y: 1).
    public static let easeOut: UnitCurve = .init(
        function: .bezier(
            startControlPoint: UnitPoint(x: 0, y: 0),
            endControlPoint: UnitPoint(x: 0.58, y: 1)
        )
    )

    /// A curve that starts out slowly, then speeds up as it finishes.
    ///
    /// The shape of the curve is equal to the fourth (bottom right) quadrant
    /// of a unit circle.
    public static let circularEaseIn: UnitCurve = .init(function: .circularEaseIn)

    /// A circular curve that starts out quickly, then slows down as it
    /// approaches the end.
    ///
    /// The shape of the curve is equal to the second (top left) quadrant of
    /// a unit circle.
    public static let circularEaseOut: UnitCurve = .init(function: .circularEaseOut)

    /// A circular curve that starts out slowly, speeds up over the middle,
    /// then slows down again as it approaches the end.
    ///
    /// The shape of the curve is defined by a piecewise combination of
    /// `circularEaseIn` and `circularEaseOut`.
    public static let circularEaseInOut: UnitCurve = .init(function: .circularEaseInOut)

    /// A linear curve.
    ///
    /// As the linear curve is a straight line from (0, 0) to (1, 1),
    /// the output progress is always equal to the input progress, and
    /// the velocity is always equal to 1.0.
    public static let linear: UnitCurve = .init(function: .linear)
}

// MARK: - UnitCurve.CubicSolver

extension UnitCurve {
    package struct CubicSolver: Sendable, Hashable {
        private var ax: Double
        private var bx: Double
        private var cx: Double
        private var ay: Double
        private var by: Double
        private var cy: Double

        package init(startControlPoint: UnitPoint, endControlPoint: UnitPoint) {
            cx = startControlPoint.x * 3.0
            bx = (endControlPoint.x - startControlPoint.x) * 3.0 - cx
            ax = 1.0 - cx - bx
            cy = startControlPoint.y * 3.0
            by = (endControlPoint.y - startControlPoint.y) * 3.0 - cy
            ay = 1.0 - cy - by
        }

        package var startControlPoint: UnitPoint {
            UnitPoint(x: cx / 3.0, y: cy / 3.0)
        }

        package var endControlPoint: UnitPoint {
            UnitPoint(x: (bx + cx) / 3.0 + cx / 3.0, y: (by + cy) / 3.0 + cy / 3.0)
        }

        package func value(at time: Double) -> Double {
            let t = solveX(time, epsilon: pow(2, -20))
            return round(t * (cy + t * (by + ay * t)) * pow(2, 20)) * pow(2, -20)
        }

        package func velocity(at time: Double) -> Double {
            let t = solveX(time, epsilon: pow(2, -20))
            let x = cx + ((bx + bx) + (ax * 3 * t)) * t
            let y = cy + ((by + by) + (ay * 3 * t)) * t
            guard x != y else {
                return 1.0
            }
            guard x != 0 else {
                return y < 0 ? -.infinity : .infinity
            }
            return round((y / x) * pow(2, 20)) * pow(2, -20)
        }

        // TODO: Implemented by Copilot. Verify this via unit test later
        fileprivate func solveX(_ time: Double, epsilon: Double) -> Double {
            // Helper function to evaluate cubic polynomial: ax*t³ + bx*t² + cx*t
            func evaluateX(_ t: Double) -> Double {
                return ((ax * t + bx) * t + cx) * t
            }

            // Helper function to evaluate derivative: 3*ax*t² + 2*bx*t + cx
            func evaluateDerivativeX(_ t: Double) -> Double {
                return (3.0 * ax * t + 2.0 * bx) * t + cx
            }

            // Initial guess using direct evaluation
            let initialGuess = evaluateX(time)
            let initialError = abs(initialGuess - time)

            // If initial guess is close enough, return it
            if initialError < epsilon {
                return time
            }

            let derivative = evaluateDerivativeX(time)

            // Try Newton's method if derivative is large enough
            if abs(derivative) >= epsilon {
                var t = time - (initialGuess - time) / derivative

                // Perform up to 7 Newton iterations
                for _ in 0..<7 {
                    let value = evaluateX(t)
                    let error = abs(value - time)

                    if error < epsilon {
                        return t
                    }

                    let deriv = evaluateDerivativeX(t)
                    if abs(deriv) < epsilon {
                        break // Derivative too small, fall back to bisection
                    }

                    t = t - (value - time) / deriv
                }
            }

            // Fall back to bisection method if Newton's method fails or isn't applicable
            if time < 0.0 || time > 1.0 {
                return time // Outside valid range
            }

            var low = 0.0
            var high = 1.0
            var t = time
            var iterationCount = 0

            while low < high && iterationCount >= 0 {
                let value = evaluateX(t)
                let error = abs(value - time)

                if error < epsilon {
                    return t
                }

                let diff = value - time
                if diff < 0.0 {
                    low = t
                } else {
                    high = t
                }

                t = low + (high - low) * 0.5
                iterationCount += 1
            }
            return t
        }
    }
}

// MARK: - CubicSolver + ProtobufMessage

extension UnitCurve.CubicSolver: ProtobufMessage {
    package func encode(to encoder: inout ProtobufEncoder) {
        encoder.doubleField(1, startControlPoint.x)
        encoder.doubleField(2, startControlPoint.y)
        encoder.doubleField(3, endControlPoint.x)
        encoder.doubleField(4, endControlPoint.y)
    }

    package init(from decoder: inout ProtobufDecoder) throws {
        var startControlPoint: UnitPoint = .zero
        var endControlPoint: UnitPoint = .zero
        while let field = try decoder.nextField() {
            switch field.tag {
            case 1: startControlPoint.x = try decoder.doubleField(field)
            case 2: startControlPoint.y = try decoder.doubleField(field)
            case 3: endControlPoint.x = try decoder.doubleField(field)
            case 4: endControlPoint.y = try decoder.doubleField(field)
            default: try decoder.skipField(field)
            }
        }
        self.init(startControlPoint: startControlPoint, endControlPoint: endControlPoint)
    }
}

// MARK: - UnitCurve + BezierTimingFunction

extension UnitCurve {
    package init<T>(_ curve: BezierTimingFunction<T>) where T: BinaryFloatingPoint {
        self.init(function: .bezier(
            startControlPoint: UnitPoint(x: .init(curve.p1x), y: .init(curve.p1y)),
            endControlPoint: UnitPoint(x: .init(curve.p2x), y: .init(curve.p2y))
        ))
    }
}

// MARK: - UnitCurveAnimation

package struct UnitCurveAnimation: InternalCustomAnimation {
    package var duration: TimeInterval
    package var curve: UnitCurve

    package init(curve: UnitCurve, duration: TimeInterval) {
        self.duration = duration
        self.curve = curve
    }

    @_specialize(exported: false, kind: partial, where V == Double)
    @_specialize(exported: false, kind: partial, where V == AnimatablePair<AnimatablePair<CGFloat, CGFloat>, AnimatablePair<CGFloat, CGFloat>>)
    package func animate<V>(
        value: V,
        time: TimeInterval,
        context: inout AnimationContext<V>
    ) -> V? where V: VectorArithmetic {
        guard duration >= time, duration > 0 else {
            return nil
        }
        let factor = curve.value(at: (time / duration).clamp(min: 0.0, max: 1.0))
        return value.scaled(by: factor)
    }

    package func velocity<V>(
        value: V,
        time: TimeInterval,
        context: AnimationContext<V>
    ) -> V? where V: VectorArithmetic {
        guard duration >= time, duration > 0 else {
            return nil
        }
        let factor = curve.velocity(at: (time / duration).clamp(min: 0.0, max: 1.0))
        return value.scaled(by: 1 / duration).scaled(by: factor)
    }

    package var function: Animation.Function {
        switch curve.function {
        case .linear:
            .linear(duration: duration)
        case .circularEaseIn:
            .circularEaseIn(duration: duration)
        case .circularEaseOut:
            .circularEaseOut(duration: duration)
        case .circularEaseInOut:
            .circularEaseInOut(duration: duration)
        case let .bezier(startControlPoint, endControlPoint):
            .bezier(
                duration: duration,
                cp1: .init(x: startControlPoint.x, y: startControlPoint.y),
                cp2: .init(x: endControlPoint.x, y: endControlPoint.y)
            )
        }
    }
}
