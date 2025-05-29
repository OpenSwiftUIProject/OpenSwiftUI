//
//  BackgroundModifier.swift
//  OpenSwiftUICore

@frozen
public struct _BackgroundModifier<Background>: ViewModifier, MultiViewModifier, PrimitiveViewModifier where Background: View {
    public var background: Background

    public var alignment: Alignment

    @inlinable
    public init(background: Background, alignment: Alignment = .center) {
        self.background = background
        self.alignment = alignment
    }

    nonisolated public static func _makeView(
        modifier: _GraphValue<Self>,
        inputs: _ViewInputs,
        body: @escaping (_Graph, _ViewInputs) -> _ViewOutputs
    ) -> _ViewOutputs {
        preconditionFailure("TODO")
    }
}

@available(*, unavailable)
extension _BackgroundModifier : Sendable {}
