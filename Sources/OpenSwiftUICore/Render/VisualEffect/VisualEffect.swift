//
//  VisualEffect.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: A1DA12B420751F87F32B6BD40CB1B226 (SwiftUICore)

import Foundation
import OpenAttributeGraphShims

// MARK: - VisualEffect

/// Visual Effects change the visual appearance of a view without changing its
/// ancestors or descendents.
///
/// Because effects do not impact layout, they are safe to use in situations
/// where layout modification is not allowed. For example, effects may be
/// applied as a function of position, accessed through a geometry proxy:
///
///     var body: some View {
///         ContentRow()
///             .visualEffect { content, geometryProxy in
///                 content.offset(x: geometryProxy.frame(in: .global).origin.y)
///             }
///     }
///
/// You don't conform to this protocol yourself. Instead, visual effects are
/// created by calling modifier functions (such as `.offset(x:y:)` on other
/// effects, as seen in the example above.
@available(OpenSwiftUI_v5_0, *)
public protocol VisualEffect: Sendable, Animatable {
    static func _makeVisualEffect(
        effect: _GraphValue<Self>,
        inputs: _ViewInputs,
        body: @escaping (_Graph, _ViewInputs) -> _ViewOutputs
    ) -> _ViewOutputs
}

// MARK: - View + VisualEffect

@available(OpenSwiftUI_v5_0, *)
extension View {
    @_spi(_)
    @available(*, deprecated, message: "Use visualEffect(_:) instead")
    nonisolated public func geometryEffect(
        _ effect: @escaping @Sendable (EmptyVisualEffect, GeometryProxy) -> some VisualEffect
    ) -> some View {
        modifier(VisualEffectModifier(effect: effect))
    }

    /// Applies effects to this view, while providing access to layout
    /// information through a geometry proxy.
    ///
    /// You return new effects by calling functions on the first argument
    /// provided to the `effect` closure. In this example, `ContentView` is
    /// offset by its own size, causing its top left corner to appear where the
    /// bottom right corner was originally located:
    ///
    ///     ContentView()
    ///         .visualEffect { content, geometryProxy in
    ///             content.offset(geometryProxy.size)
    ///         }
    ///
    /// - Parameters:
    ///   - effect: A closure that returns the effect to be applied. The first
    ///     argument provided to the closure is a placeholder representing
    ///     this view. The second argument is a `GeometryProxy`.
    /// - Returns: A view with the effect applied.
    nonisolated public func visualEffect(
        _ effect: @escaping @Sendable (EmptyVisualEffect, GeometryProxy) -> some VisualEffect
    ) -> some View {
        modifier(VisualEffectModifier(effect: effect))
    }
}

// MARK: - EmptyVisualEffect

/// The base visual effect that you apply additional effect to.
///
/// `EmptyVisualEffect` does not change the appearance of the view
/// that it is applied to.
@available(OpenSwiftUI_v5_0, *)
public struct EmptyVisualEffect: VisualEffect {
    /// Creates a new empty visual effect.
    public init() {
        _openSwiftUIEmptyStub()
    }

    public static func _makeVisualEffect(
        effect: _GraphValue<EmptyVisualEffect>,
        inputs: _ViewInputs,
        body: @escaping (_Graph, _ViewInputs) -> _ViewOutputs
    ) -> _ViewOutputs {
        body(_Graph(), inputs)
    }

    public typealias AnimatableData = EmptyAnimatableData
}

// MARK: - VisualEffectModifier

struct VisualEffectModifier<Effect>: PrimitiveViewModifier where Effect: VisualEffect {
    var effect: (EmptyVisualEffect, GeometryProxy) -> Effect

    nonisolated static func _makeView(
        modifier: _GraphValue<Self>,
        inputs: _ViewInputs,
        body: @escaping (_Graph, _ViewInputs) -> _ViewOutputs
    ) -> _ViewOutputs {
        let child = Attribute(Child(
            modifier: modifier.value,
            position: inputs.position,
            size: inputs.size,
            transform: inputs.transform,
            environment: inputs.environment,
            safeAreaInsets: .init(),
            seed: .zero
        ))
        return Effect._makeVisualEffect(effect: .init(child), inputs: inputs, body: body)
    }

    nonisolated static func _makeViewList(
        modifier: _GraphValue<Self>,
        inputs: _ViewListInputs,
        body: @escaping (_Graph, _ViewListInputs) -> _ViewListOutputs
    ) -> _ViewListOutputs {
        makeMultiViewList(modifier: modifier, inputs: inputs, body: body)
    }

    nonisolated static func _viewListCount(
        inputs: _ViewListCountInputs,
        body: (_ViewListCountInputs) -> Int?
    ) -> Int? {
        body(inputs)
    }

    private struct Child: StatefulRule, AsyncAttribute {
        @Attribute var modifier: VisualEffectModifier
        @Attribute var position: CGPoint
        @Attribute var size: ViewSize
        @Attribute var transform: ViewTransform
        @Attribute var environment: EnvironmentValues
        @OptionalAttribute var safeAreaInsets: SafeAreaInsets?
        var seed: UInt32

        typealias Value = Effect

        mutating func updateValue() {
            seed.unsafeIncrement()
            let proxy = GeometryProxy(
                owner: attribute.identifier,
                size: $size,
                environment: $environment,
                transform: $transform,
                position: $position,
                safeAreaInsets: $safeAreaInsets,
                seed: seed
            )
            value = modifier.effect(EmptyVisualEffect(), proxy)
        }
    }
}
