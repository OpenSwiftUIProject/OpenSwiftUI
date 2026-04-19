//
//  AnyGradient.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  ID: 50251084C79137239112ABA67F1FABAC
//  Status: Compelete

// MARK: - AnyGradient

public struct AnyGradient: ShapeStyle, Hashable {
    package var provider: AnyGradientBox

    package init(box: AnyGradientBox) {
        self.provider = box
    }

    package init<P>(provider: P) where P: GradientProvider {
        self.provider = GradientBox(provider)
    }

    public init(_ gradient: Gradient) {
        self.provider = GradientBox(gradient)
    }

    package func fallbackColor(in environment: EnvironmentValues) -> Color? {
        provider.fallbackColor(in: environment)
    }

    public func hash(into hasher: inout Hasher) {
        provider.hash(into: &hasher)
    }

    public func _apply(to shape: inout _ShapeStyle_Shape) {
        provider.apply(to: &shape)
    }

    package func resolve(in environment: EnvironmentValues) -> ResolvedGradient {
        provider.resolve(in: environment)
    }

    public static func == (lhs: AnyGradient, rhs: AnyGradient) -> Bool {
        lhs.provider === rhs.provider ? true : lhs.provider.isEqual(to: rhs.provider)
    }
}

// MARK: - AnyGradientBox

package class AnyGradientBox: AnyShapeStyleBox {
    func resolve(in environment: EnvironmentValues) -> ResolvedGradient {
        _openSwiftUIBaseClassAbstractMethod()
    }

    func fallbackColor(in environment: EnvironmentValues) -> Color? {
        _openSwiftUIBaseClassAbstractMethod()
    }

    func hash(into: inout Hasher) {
        _openSwiftUIBaseClassAbstractMethod()
    }

    override package func apply(to shape: inout _ShapeStyle_Shape) {
        _AnyLinearGradient(
            gradient: AnyGradient(box: self),
            startPoint: .top,
            endPoint: .bottom
        )._apply(to: &shape)
    }
}

// MARK: - GradientBox

private class GradientBox<P>: AnyGradientBox where P: GradientProvider {
    let base: P

    init(_ base: P) {
        self.base = base
    }

    override func resolve(in environment: EnvironmentValues) -> ResolvedGradient {
        base.resolve(in: environment)
    }

    override func fallbackColor(in environment: EnvironmentValues) -> Color? {
        base.fallbackColor(in: environment)
    }

    override func isEqual(to other: AnyShapeStyleBox) -> Bool {
        guard let other = other as? GradientBox<P> else { return false }
        return base == other.base
    }

    override func hash(into hasher: inout Hasher) {
        base.hash(into: &hasher)
    }
}

// MARK: - EitherGradient

package enum EitherGradient: Hashable {
    case gradient(Gradient)
    case anyGradient(AnyGradient)

    package func fallbackColor(in environment: EnvironmentValues) -> Color? {
        switch self {
        case .gradient: nil
        case .anyGradient(let anyGradient):
            anyGradient.fallbackColor(in: environment)
        }
    }

    package func resolve(in environment: EnvironmentValues) -> ResolvedGradient {
        switch self {
        case .gradient(let gradient):
            gradient.resolve(in: environment)
        case .anyGradient(let anyGradient):
            anyGradient.resolve(in: environment)
        }
    }

    package var constantColor: Color? {
        switch self {
        case .gradient(let gradient):
            if gradient.stops.count == 0 {
                Color.clear
            } else if gradient.stops.count == 1 {
                gradient.stops[0].color
            } else {
                nil
            }
        case .anyGradient:
            nil
        }
    }
}
