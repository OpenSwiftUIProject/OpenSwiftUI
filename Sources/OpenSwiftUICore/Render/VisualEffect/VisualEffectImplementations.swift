//
//  VisualEffectImplementations.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: 9FFF1526AA410727EB04F8ADBE7663C7 (SwiftUICore)

// MARK: - VisualEffect + Composition

extension VisualEffect {
    package func concat(_ effect: some VisualEffect) -> some VisualEffect {
        CombinedVisualEffect(first: self, second: effect)
    }

    package func rendererEffect(_ effect: some RendererEffect & Sendable) -> some VisualEffect {
        concat(RendererVisualEffect(base: effect))
    }

    package func geometryEffect(_ effect: some GeometryEffect & Sendable) -> some VisualEffect {
        concat(GeometryVisualEffect(base: effect))
    }
}

// MARK: - CombinedVisualEffect

private struct CombinedVisualEffect<First, Second>: VisualEffect where First: VisualEffect, Second: VisualEffect {
    var first: First
    var second: Second

    static func _makeVisualEffect(
        effect: _GraphValue<Self>,
        inputs: _ViewInputs,
        body: @escaping (_Graph, _ViewInputs) -> _ViewOutputs
    ) -> _ViewOutputs {
        Second._makeVisualEffect(effect: effect[offset: { .of(&$0.second) }], inputs: inputs) { _, inputs in
            First._makeVisualEffect(effect: effect[offset: { .of(&$0.first) }], inputs: inputs, body: body)
        }
    }

    var animatableData: AnimatablePair<First.AnimatableData, Second.AnimatableData> {
        get { .init(first.animatableData, second.animatableData) }
        set {
            first.animatableData = newValue.first
            second.animatableData = newValue.second
        }
    }
}

// MARK: - GeometryVisualEffect

private struct GeometryVisualEffect<Effect>: VisualEffect where Effect: GeometryEffect & Sendable {
    var base: Effect

    static func _makeVisualEffect(
        effect: _GraphValue<Self>,
        inputs: _ViewInputs,
        body: @escaping (_Graph, _ViewInputs) -> _ViewOutputs
    ) -> _ViewOutputs {
        Effect.makeGeometryEffect(modifier: effect[offset: { .of(&$0.base) }], inputs: inputs, body: body)
    }

    var animatableData: Effect.AnimatableData {
        get { base.animatableData }
        set { base.animatableData = newValue }
    }
}

// MARK: - RendererVisualEffect

private struct RendererVisualEffect<Effect>: VisualEffect where Effect: RendererEffect & Sendable {
    var base: Effect

    static func _makeVisualEffect(
        effect: _GraphValue<Self>,
        inputs: _ViewInputs,
        body: @escaping (_Graph, _ViewInputs) -> _ViewOutputs
    ) -> _ViewOutputs {
        Effect.makeRendererEffect(effect: effect[offset: { .of(&$0.base) }], inputs: inputs, body: body)
    }

    var animatableData: Effect.AnimatableData {
        get { base.animatableData }
        set { base.animatableData = newValue }
    }
}
