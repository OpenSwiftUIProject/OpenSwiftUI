//
//  AnyGradient.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: WIP
//  ID: 50251084C79137239112ABA67F1FABAC (SwiftUICore)

import Foundation

/// A color gradient.
///
/// When used as a ``ShapeStyle``, this type draws a linear gradient
/// with start-point [0.5, 0] and end-point [0.5, 1].
@available(OpenSwiftUI_v4_0, *)
@frozen
public struct AnyGradient: Hashable, ShapeStyle, Sendable {
    package var provider: AnyGradientBox

    package init(box: AnyGradientBox) {
        provider = box
    }

    package init<P>(provider: P) where P: GradientProvider {
        self.provider = GradientBox(base: provider)
    }

    /// Creates a new instance from the specified gradient.
    public init(_ gradient: Gradient) {
        self.init(provider: gradient)
    }

    package func resolve(in environment: EnvironmentValues) -> ResolvedGradient {
        provider.resolve(in: environment)
    }

    package func fallbackColor(in environment: EnvironmentValues) -> Color? {
        provider.fallbackColor(in: environment)
    }

    public func _apply(to shape: inout _ShapeStyle_Shape) {
        _AnyLinearGradient(
            gradient: self,
            startPoint: .top,
            endPoint: .bottom
        )._apply(to: &shape)
    }

    public func hash(into hasher: inout Hasher) {
        provider.hash(into: &hasher)
    }

    public static func == (lhs: AnyGradient, rhs: AnyGradient) -> Bool {
        lhs.provider === rhs.provider || lhs.provider.isEqual(to: rhs.provider)
    }
}

package protocol GradientProvider: Hashable {
    func resolve(in environment: EnvironmentValues) -> ResolvedGradient
    func fallbackColor(in environment: EnvironmentValues) -> Color?
}

extension GradientProvider {
    package func fallbackColor(in environment: EnvironmentValues) -> Color? {
        nil
    }
}

extension Gradient: GradientProvider {}

@usableFromInline
package class AnyGradientBox: AnyShapeStyleBox, @unchecked Sendable {
    override package final func apply(to shape: inout _ShapeStyle_Shape) {
        AnyGradient(box: self)._apply(to: &shape)
    }

    package func resolve(in environment: EnvironmentValues) -> ResolvedGradient {
        _openSwiftUIBaseClassAbstractMethod()
    }

    package func fallbackColor(in environment: EnvironmentValues) -> Color? {
        _openSwiftUIBaseClassAbstractMethod()
    }

    package func hash(into hasher: inout Hasher) {
        _openSwiftUIBaseClassAbstractMethod()
    }
}

private final class GradientBox<P>: AnyGradientBox, @unchecked Sendable where P: GradientProvider {
    let base: P

    init(base: P) {
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

// TODO: Any*Gradient

package enum EitherGradient: Hashable {
    case gradient(Gradient)
    case anyGradient(AnyGradient)

    package func resolve(in environment: EnvironmentValues) -> ResolvedGradient {
        switch self {
        case let .gradient(gradient):
            gradient.resolve(in: environment)
        case let .anyGradient(gradient):
            gradient.resolve(in: environment)
        }
    }

    package func fallbackColor(in environment: EnvironmentValues) -> Color? {
        switch self {
        case let .gradient(gradient):
            gradient.fallbackColor(in: environment)
        case let .anyGradient(gradient):
            gradient.fallbackColor(in: environment)
        }
    }

    package var constantColor: Color? {
        switch self {
        case let .gradient(gradient):
            gradient.constantColor
        case .anyGradient:
            nil
        }
    }
}
