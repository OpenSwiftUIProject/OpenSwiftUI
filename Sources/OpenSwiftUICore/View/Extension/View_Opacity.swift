//
//  View_Opacity.swift
//  OpenSwiftUI
//
//  Audited for iOS 15.5
//  Status: WIP

extension View {
    @inlinable
    public func opacity(_ opacity: Double) -> some View {
        modifier(_OpacityEffect(opacity: opacity))
    }
}

@frozen
public struct _OpacityEffect: Equatable {
    public var opacity: Double
    @inlinable public init(opacity: Double) {
        self.opacity = opacity
    }
}

extension _OpacityEffect: Animatable {
    public var animatableData: Double {
        get { opacity }
        set { opacity = newValue }
    }
}

extension _OpacityEffect: PrimitiveViewModifier, ViewModifier /* , MultiViewModifier */ {
    //  public static func _makeView(modifier: _GraphValue<_OpacityEffect>, inputs: _ViewInputs, body: @escaping (_Graph, _ViewInputs) -> _ViewOutputs) -> _ViewOutputs
}

// TODO: RendererEffect _RendererEffect

// TODO: CodableByProxy

extension _OpacityEffect: Sendable {}

// extension AnyTransition {
//  public static let opacity: AnyTransition
// }
