//
//  LinearGradient.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: WIP

package import Foundation

// MARK: - _AnyLinearGradient

package struct _AnyLinearGradient: Paint {
    var gradient: AnyGradient
    var startPoint: UnitPoint
    var endPoint: UnitPoint

    package init(gradient: AnyGradient, startPoint: UnitPoint, endPoint: UnitPoint) {
        self.gradient = gradient
        self.startPoint = startPoint
        self.endPoint = endPoint
    }

    @inline(__always)
    func resolvePaint(in env: EnvironmentValues) -> LinearGradient._Paint {
        LinearGradient._Paint(
            gradient: gradient.resolve(in: env),
            startPoint: startPoint,
            endPoint: endPoint
        )
    }

    @inline(__always)
    func fallbackColor(in env: EnvironmentValues) -> Color? {
        gradient.fallbackColor(in: env)
    }
}

// MARK: - LinearGradient

@frozen
public struct LinearGradient: Paint, View {
    var gradient: Gradient
    var startPoint: UnitPoint
    var endPoint: UnitPoint

    public init(gradient: Gradient, startPoint: UnitPoint, endPoint: UnitPoint) {
        self.gradient = gradient
        self.startPoint = startPoint
        self.endPoint = endPoint
    }

    package struct _Paint: ResolvedPaint {
        var gradient: ResolvedGradient
        var startPoint: UnitPoint
        var endPoint: UnitPoint

        package static let leafProtobufTag: CodableResolvedPaint.Tag? = .linearGradient

        package func draw(path: Path, style: PathDrawingStyle, in context: GraphicsContext, bounds: CGRect?) {
            let rect = bounds ?? path.boundingRect
            context.draw(
                path,
                with: .gradient(gradient, .axial(startPoint.in(rect), endPoint.in(rect)), []),
                style: style
            )
        }

        package var isClear: Bool {
            gradient.isClear
        }

        package var isOpaque: Bool {
            gradient.isOpaque
        }
    }

    package func resolvePaint(in env: EnvironmentValues) -> _Paint {
        _Paint(
            gradient: gradient.resolve(in: env),
            startPoint: startPoint,
            endPoint: endPoint
        )
    }

    package func fallbackColor(in environment: EnvironmentValues) -> Color? {
        guard !gradient.stops.isEmpty else {
            return nil
        }
        return gradient.stops[0].color
    }

    nonisolated public static func _makeView<S>(
        view: _GraphValue<_ShapeView<S, Self>>,
        inputs: _ViewInputs
    ) -> _ViewOutputs where S: Shape {
        _ShapeView.makeView(view: view, inputs: inputs)
    }
}

extension LinearGradient._Paint: Animatable {
    package var animatableData: AnimatablePair<AnimatablePair<AnimatablePair<CGFloat, CGFloat>, AnimatablePair<CGFloat, CGFloat>>, ResolvedGradientVector> {
        get {
            AnimatablePair(
                AnimatablePair(startPoint.animatableData, endPoint.animatableData),
                gradient.animatableData
            )
        }
        set {
            startPoint.animatableData = newValue.first.first
            endPoint.animatableData = newValue.first.second
            gradient.animatableData = newValue.second
        }
    }
}

extension LinearGradient._Paint: ProtobufMessage {
    package init(from decoder: inout ProtobufDecoder) throws {
        _openSwiftUIUnimplementedFailure()
    }

    package func encode(to encoder: inout ProtobufEncoder) throws {
        _openSwiftUIUnimplementedFailure()
    }
}
