//
//  GeometryEffect.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: 9ED0B9F1F6CE74691B78276C750FEDD3 (SwiftUICore)

public import Foundation
package import OpenAttributeGraphShims

// MARK: - GeometryEffect

/// An effect that changes the visual appearance of a view, largely without
/// changing its ancestors or descendants.
///
/// The only change the effect makes to the view's ancestors and descendants is
/// to change the coordinate transform to and from them.
@available(OpenSwiftUI_v1_0, *)
public protocol GeometryEffect: Animatable, ViewModifier, _RemoveGlobalActorIsolation where Body == Never {
    /// Returns the current value of the effect.
    func effectValue(size: CGSize) -> ProjectionTransform

    /// If false the effect's transform is not applied to coordinate
    /// space conversions crossing the view, only to the renderered
    /// representation of the child view.
    static var _affectsLayout: Bool { get }
}

@available(OpenSwiftUI_v1_0, *)
extension GeometryEffect {
    public static var _affectsLayout: Bool {
        true
    }
}

@available(OpenSwiftUI_v1_0, *)
extension GeometryEffect {
    nonisolated public static func _makeView(
        modifier: _GraphValue<Self>,
        inputs: _ViewInputs,
        body: @escaping (_Graph, _ViewInputs) -> _ViewOutputs
    ) -> _ViewOutputs {
        makeGeometryEffect(modifier: modifier, inputs: inputs, body: body)
    }

    nonisolated package static func makeGeometryEffect(
        modifier: _GraphValue<Self>,
        inputs: _ViewInputs,
        body: @escaping (_Graph, _ViewInputs) -> _ViewOutputs
    ) -> _ViewOutputs {
        if let modifier = modifier as? _GraphValue<_RotationEffect> {
            _RotationEffect
                ._makeGeometryEffect(
                    modifier: modifier,
                    inputs: inputs,
                    body: body
                )
        } else if let modifier = modifier as? _GraphValue<_Rotation3DEffect> {
            _Rotation3DEffect
                ._makeGeometryEffect(
                    modifier: modifier,
                    inputs: inputs,
                    body: body
                )
        } else {
            DefaultGeometryEffectProvider
                ._makeGeometryEffect(
                    modifier: modifier,
                    inputs: inputs,
                    body: body
                )
        }
    }

    nonisolated public static func _makeViewList(
        modifier: _GraphValue<Self>,
        inputs: _ViewListInputs,
        body: @escaping (_Graph, _ViewListInputs) -> _ViewListOutputs
    ) -> _ViewListOutputs {
        makeMultiViewList(modifier: modifier, inputs: inputs, body: body)
    }

    @available(OpenSwiftUI_v2_0, *)
    nonisolated public static func _viewListCount(
        inputs: _ViewListCountInputs,
        body: (_ViewListCountInputs) -> Int?
    ) -> Int? {
        body(inputs)
    }
}

// MARK: - GeometryEffectProvider

protocol GeometryEffectProvider {
    associatedtype Effect: GeometryEffect

    static func resolve(
        effect: Effect,
        origin: inout CGPoint,
        size: CGSize,
        layoutDirection: LayoutDirection
    ) -> DisplayList.Effect
}

extension GeometryEffectProvider {
    static func _makeGeometryEffect(
        modifier: _GraphValue<Effect>,
        inputs: _ViewInputs,
        body: @escaping (_Graph, _ViewInputs) -> _ViewOutputs
    ) -> _ViewOutputs {
        guard inputs.needsGeometry else {
            return body(_Graph(), inputs)
        }
        let animatableEffect = Effect.makeAnimatable(value: modifier, inputs: inputs.base)
        let transform = Attribute(
            GeometryEffectTransform(
                effect: animatableEffect,
                size: inputs.animatedCGSize(),
                position: inputs.animatedPosition(),
                transform: inputs.transform,
                layoutDirection: inputs.layoutDirection
            )
        )
        let size = Attribute(
            RoundedSize(
                position: inputs.position,
                size: inputs.size,
                pixelLength: inputs.pixelLength
            )
        )
        var newInputs = inputs
        let zeroPoint = ViewGraph.current.$zeroPoint
        newInputs.transform = transform
        newInputs.position = zeroPoint
        newInputs.containerPosition = zeroPoint
        newInputs.size = size
        var outputs = body(_Graph(), newInputs)
        if inputs.preferences.requiresDisplayList {
            let identity = DisplayList.Identity()
            inputs.pushIdentity(identity)
            let displayList = Attribute(
                GeometryEffectDisplayList<Self>(
                    identity: .init(),
                    effect: animatableEffect,
                    position: inputs.animatedPosition(),
                    size: inputs.animatedCGSize(), // Verify: Still get a new size here
                    layoutDirection: inputs.layoutDirection,
                    containerPosition: inputs.containerPosition,
                    content: .init(outputs.preferences.displayList),
                    options: .init()
                )
            )
            outputs.displayList = displayList
        }
        return outputs
    }
}

// MARK: - RoundedSize

package struct RoundedSize: Rule, AsyncAttribute {
    @Attribute var position: CGPoint
    @Attribute var size: ViewSize
    @Attribute var pixelLength: CGFloat

    package init(
        position: Attribute<CGPoint>,
        size: Attribute<ViewSize>,
        pixelLength: Attribute<CGFloat>
    ) {
        _position = position
        _size = size
        _pixelLength = pixelLength
    }

    package var value: ViewSize {
        var size = size
        var rect = CGRect(origin: position, size: size.value)
        rect.roundCoordinatesToNearestOrUp(toMultipleOf: pixelLength)
        size.value = rect.size
        return size
    }
}

// MARK: - DefaultGeometryEffectProvider

struct DefaultGeometryEffectProvider<Effect>: GeometryEffectProvider where Effect: GeometryEffect {
    static func resolve(
        effect: Effect,
        origin: inout CGPoint,
        size: CGSize,
        layoutDirection: LayoutDirection
    ) -> DisplayList.Effect {
        var effectValue = effect.effectValue(size: size)
        if layoutDirection == .rightToLeft {
            let t = ProjectionTransform(
                m11: -1, m12: 0, m13: 0,
                m21: 0, m22: 1, m23: 0,
                m31: size.width, m32: 0, m33: 1
            )
            effectValue = t
                .concatenating(effectValue)
                .concatenating(t)
        }
        guard effectValue.isInvertible else {
            Log.externalWarning("ignoring singular matrix: \(effectValue)")
            return .identity
        }
        if effectValue.isAffine {
            return .transform(.affine(.init(effectValue)))
        } else {
            return .transform(.projection(effectValue))
        }
    }
}

// MARK: - Rotation + GeometryEffectProvider

extension _RotationEffect: GeometryEffectProvider {
    typealias Effect = Self

    static func resolve(
        effect: _RotationEffect,
        origin: inout CGPoint,
        size: CGSize,
        layoutDirection: LayoutDirection
    ) -> DisplayList.Effect {
        let data = _RotationEffect.Data(effect, size: size, layoutDirection: layoutDirection)
        return .transform(.rotation(data))
    }
}

extension _Rotation3DEffect: GeometryEffectProvider {
    typealias Effect = Self

    static func resolve(
        effect: _Rotation3DEffect,
        origin: inout CGPoint,
        size: CGSize,
        layoutDirection: LayoutDirection
    ) -> DisplayList.Effect {
        let data = _Rotation3DEffect.Data(effect, size: size, layoutDirection: layoutDirection)
        return .transform(.rotation3D(data))
    }
}

// MARK: - GeometryEffectDisplayList

private struct GeometryEffectDisplayList<Provider>: Rule, AsyncAttribute, CustomStringConvertible
    where Provider: GeometryEffectProvider {
    let identity: DisplayList.Identity
    @Attribute var effect: Provider.Effect
    @Attribute var position: CGPoint
    @Attribute var size: CGSize
    @Attribute var layoutDirection: LayoutDirection
    @Attribute var containerPosition: CGPoint
    @OptionalAttribute var content: DisplayList?
    let options: DisplayList.Options

    var value: DisplayList {
        let content = content ?? DisplayList()
        guard !content.isEmpty else {
            return content
        }
        var origin = CGPoint(position - containerPosition)
        let displayListEffect = Provider.resolve(
            effect: effect,
            origin: &origin,
            size: size,
            layoutDirection: layoutDirection
        )
        var item = DisplayList.Item(
            .effect(displayListEffect, content),
            frame: CGRect(origin: origin, size: size),
            identity: identity,
            version: .init(forUpdate: ())
        )
        item.canonicalize(options: options)
        return DisplayList(item)
    }

    var description: String {
        "GeometryEffectDisplayList"
    }
}

// MARK: - GeometryEffectTransform

private struct GeometryEffectTransform<Effect>: Rule, AsyncAttribute where Effect: GeometryEffect {
    @Attribute var effect: Effect
    @Attribute var size: CGSize
    @Attribute var position: CGPoint
    @Attribute var transform: ViewTransform
    @Attribute var layoutDirection: LayoutDirection

    typealias Value = ViewTransform

    var value: Value {
        var transform = transform
        transform.resetPosition(position)
        if Effect._affectsLayout {
            var effectValue = effect.effectValue(size: size)
            if layoutDirection == .rightToLeft {
                let t = ProjectionTransform(
                    m11: -1, m12: 0, m13: 0,
                    m21: 0, m22: 1, m23: 0,
                    m31: size.width, m32: 0, m33: 1
                )
                effectValue = t
                    .concatenating(effectValue)
                    .concatenating(t)
            }
            if effectValue.isInvertible {
                transform.appendProjectionTransform(
                    effectValue,
                    inverse: true
                )
            } else {
                Log.externalWarning("ignoring singular matrix: \(effectValue)")
            }
        }
        return transform
    }
}
