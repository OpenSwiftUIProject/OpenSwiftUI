//
//  HoverEffectContentCore.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: 1288298EF939E9CD22B6B6765530C45C (SwiftUICore)

package import Foundation
package import OpenAttributeGraphShims
package import OpenCoreGraphicsShims

// MARK: - HoverEffectContent

/// A type that describes the effects of a view for a particular hover
/// effect phase.
///
///     Color.red
///         .hoverEffect { effect, isActive, proxy in
///             effect.opacity(isActive ? 1 : 0.5)
///         }
///
///
/// You don't conform to this protocol yourself. Instead, effects are described
/// by calling modifier functions on other effects, like the `opacity(_:)`
/// modifier used in the example above.
@available(OpenSwiftUI_v6_0, *)
@available(iOS, unavailable)
@available(macOS, unavailable)
@available(watchOS, unavailable)
@available(tvOS, unavailable)
public protocol HoverEffectContent {
    /// Makes a new ``HoverEffectContent`` using the given inputs.
    static func _makeHoverEffectContent(
        effect: _GraphValue<Self>,
        inputs: _HoverEffectContentInputs,
        body: @escaping (_HoverEffectContentInputs) -> _HoverEffectContentOutputs
    ) -> _HoverEffectContentOutputs
}

// MARK: - EmptyHoverEffectContent

/// An empty base effect that you use to build other effects.
@available(OpenSwiftUI_v6_0, *)
@available(iOS, unavailable)
@available(macOS, unavailable)
@available(watchOS, unavailable)
@available(tvOS, unavailable)
public struct EmptyHoverEffectContent: HoverEffectContent {
    public static func _makeHoverEffectContent(
        effect: _GraphValue<Self>,
        inputs: _HoverEffectContentInputs,
        body: @escaping (_HoverEffectContentInputs) -> _HoverEffectContentOutputs
    ) -> _HoverEffectContentOutputs {
        body(inputs)
    }

    package init() {
        _openSwiftUIEmptyStub()
    }
}

@available(*, unavailable)
extension EmptyHoverEffectContent: Sendable {}

// MARK: - _HoverEffectContentInputs

/// The inputs used for creating HoverEffectContent.
@available(OpenSwiftUI_v6_0, *)
@available(iOS, unavailable)
@available(macOS, unavailable)
@available(watchOS, unavailable)
@available(tvOS, unavailable)
public struct _HoverEffectContentInputs {
    package var base: _CustomHoverEffectInputs
    package var isActive: Bool

    package init(base: _CustomHoverEffectInputs, isActive: Bool) {
        self.base = base
        self.isActive = isActive
    }
}

@available(*, unavailable)
extension _HoverEffectContentInputs: Sendable {}

// MARK: - _HoverEffectContentOutputs

/// Outputs used for creating HoverEffectContent.
@available(OpenSwiftUI_v6_0, *)
@available(iOS, unavailable)
@available(macOS, unavailable)
@available(watchOS, unavailable)
@available(tvOS, unavailable)
public struct _HoverEffectContentOutputs {
    package var content: Attribute<HoverEffectContentList>

    package init(content: Attribute<HoverEffectContentList>) {
        self.content = content
    }
}

@available(*, unavailable)
extension _HoverEffectContentOutputs: Sendable {}

// MARK: - HoverEffectContent + Composition

@available(OpenSwiftUI_v6_0, *)
@available(iOS, unavailable)
@available(macOS, unavailable)
@available(watchOS, unavailable)
@available(tvOS, unavailable)
extension HoverEffectContent {
    package func rendererEffect(_ effect: some RendererEffect) -> some HoverEffectContent {
        concat(RendererHoverEffectContent(base: effect))
    }

    package func geometryEffect(_ effect: some GeometryEffect) -> some HoverEffectContent {
        concat(GeometryHoverEffectContent(base: effect))
    }
}

@_spi(CustomHoverEffects)
@available(OpenSwiftUI_v6_0, *)
@available(iOS, unavailable)
@available(macOS, unavailable)
@available(watchOS, unavailable)
@available(tvOS, unavailable)
extension HoverEffectContent {
    package func concat<T>(_ effect: T) -> ModifiedContent<Self, T> {
        ModifiedContent(content: self, modifier: effect)
    }
}

// MARK: - ModifiedContent + HoverEffectContent

@available(OpenSwiftUI_v6_0, *)
@available(iOS, unavailable)
@available(macOS, unavailable)
@available(watchOS, unavailable)
@available(tvOS, unavailable)
extension ModifiedContent: HoverEffectContent where Content: HoverEffectContent, Modifier: HoverEffectContent {
    public static func _makeHoverEffectContent(
        effect: _GraphValue<Self>,
        inputs: _HoverEffectContentInputs,
        body: @escaping (_HoverEffectContentInputs) -> _HoverEffectContentOutputs
    ) -> _HoverEffectContentOutputs {
        Modifier._makeHoverEffectContent(effect: effect[offset: { .of(&$0.modifier) }], inputs: inputs) { inputs in
            Content._makeHoverEffectContent(effect: effect[offset: { .of(&$0.content) }], inputs: inputs, body: body)
        }
    }
}

// MARK: - RendererHoverEffectContent

@available(iOS, unavailable)
@available(macOS, unavailable)
@available(watchOS, unavailable)
@available(tvOS, unavailable)
private struct RendererHoverEffectContent<Effect>: HoverContentListValueEffect where Effect: RendererEffect {
    var base: Effect

    func effectValue(proxy: GeometryProxy) -> HoverEffectContentList.Effect {
        base.effectValue(size: proxy.size).contentListEffect ?? .identity
    }
}

// MARK: - GeometryHoverEffectContent

@available(iOS, unavailable)
@available(macOS, unavailable)
@available(watchOS, unavailable)
@available(tvOS, unavailable)
private struct GeometryHoverEffectContent<Effect>: HoverContentListValueEffect where Effect: GeometryEffect {
    var base: Effect

    func effectValue(proxy: GeometryProxy) -> HoverEffectContentList.Effect {
        var origin = CGPoint.zero
        let effect: DisplayList.Effect
        if let base = base as? _RotationEffect {
            effect = _RotationEffect.resolve(
                effect: base,
                origin: &origin,
                size: proxy.size,
                layoutDirection: proxy.environment.layoutDirection
            )
        } else if let base = base as? _Rotation3DEffect {
            effect = _Rotation3DEffect.resolve(
                effect: base,
                origin: &origin,
                size: proxy.size,
                layoutDirection: proxy.environment.layoutDirection
            )
        } else {
            effect = DefaultGeometryEffectProvider<Effect>.resolve(
                effect: base,
                origin: &origin,
                size: proxy.size,
                layoutDirection: proxy.environment.layoutDirection
            )
            if case .identity = effect {
                return .transform(CGAffineTransform(translationX: origin.x, y: origin.y))
            }
        }
        return effect.contentListEffect ?? .identity
    }
}

// MARK: - DisplayList.Effect + HoverEffectContentList

extension DisplayList.Effect {
    fileprivate var contentListEffect: HoverEffectContentList.Effect? {
        switch self {
        case let .opacity(opacity):
            return .opacity(opacity)
        case let .clip(path, _, _):
            return .clip(path)
        case let .transform(transform):
            switch transform {
            case let .affine(transform):
                return .transform(transform)
            case let .rotation(data):
                return .transform(data.transform)
            default:
                Log.internalError("Unexpected transform effect: \(self)")
                return nil
            }
        default:
            Log.internalError("Unexpected effect: \(self)")
            return nil
        }
    }
}

// MARK: - HoverContentListValueEffect

@available(iOS, unavailable)
@available(macOS, unavailable)
@available(watchOS, unavailable)
@available(tvOS, unavailable)
protocol HoverContentListValueEffect: HoverEffectContent {
    func effectValue(proxy: GeometryProxy) -> HoverEffectContentList.Effect
}

@available(iOS, unavailable)
@available(macOS, unavailable)
@available(watchOS, unavailable)
@available(tvOS, unavailable)
extension HoverContentListValueEffect {
    static func _makeHoverEffectContent(
        effect: _GraphValue<Self>,
        inputs: _HoverEffectContentInputs,
        body: @escaping (_HoverEffectContentInputs) -> _HoverEffectContentOutputs
    ) -> _HoverEffectContentOutputs {
        let identity = DisplayList.Identity()
        let outputs = body(inputs)
        let base = inputs.base.base
        let content = Attribute(MakeValueContentList(
            identity: identity,
            effect: effect.value,
            position: base.animatedPosition(),
            size: base.animatedSize(),
            transform: base.transform,
            containerPosition: base.containerPosition,
            environment: base.environment,
            safeAreaInsets: base.safeAreaInsets,
            childList: outputs.content
        ))
        return _HoverEffectContentOutputs(content: content)
    }
}

// MARK: - MakeValueContentList

@available(iOS, unavailable)
@available(macOS, unavailable)
@available(watchOS, unavailable)
@available(tvOS, unavailable)
private struct MakeValueContentList<Effect>: Rule, AsyncAttribute where Effect: HoverContentListValueEffect {
    let identity: DisplayList.Identity
    @Attribute var effect: Effect
    @Attribute var position: ViewOrigin
    @Attribute var size: ViewSize
    @Attribute var transform: ViewTransform
    @Attribute var containerPosition: ViewOrigin
    @Attribute var environment: EnvironmentValues
    @OptionalAttribute var safeAreaInsets: SafeAreaInsets?
    @Attribute var childList: HoverEffectContentList

    var value: HoverEffectContentList {
        let version = DisplayList.Version(forUpdate: ())
        let proxy = GeometryProxy(
            owner: attribute.identifier,
            size: $size,
            environment: $environment,
            transform: $transform,
            position: $position,
            safeAreaInsets: $safeAreaInsets,
            seed: UInt32(truncatingIfNeeded: version.value)
        )
        let effect = proxy.asCurrent {
            self.effect.effectValue(proxy: proxy)
        }
        return HoverEffectContentList(item: .init(
            identity: identity,
            version: version,
            value: .effect(effect, childList)
        ))
    }
}

// MARK: - HoverEffectContentList

package struct HoverEffectContentList: Equatable {
    package typealias Identity = DisplayList.Identity
    package typealias Version = DisplayList.Version

    package struct Item: Equatable {
        package var identity: Identity
        package var version: Version
        package var value: Value

        package init(identity: Identity, version: Version, value: Value) {
            self.identity = identity
            self.version = version
            self.value = value
        }

        package enum Value {
            indirect case effect(Effect, HoverEffectContentList)
        }

        package static func == (lhs: Item, rhs: Item) -> Bool {
            lhs.identity == rhs.identity && lhs.version == rhs.version
        }

        package var affectsBoundsForHitTesting: Bool {
            switch value {
            case let .effect(effect, content):
                switch effect {
                case .transform, .resize, .clip:
                    return true
                case let .scopedAnimation(_, scopedContent):
                    if scopedContent.item?.affectsBoundsForHitTesting == true {
                        return true
                    }
                case .identity, .opacity:
                    break
                }
                return content.item?.affectsBoundsForHitTesting ?? false
            }
        }

        package var transform: CGAffineTransform? {
            switch value {
            case let .effect(effect, content):
                let transform: CGAffineTransform?
                switch effect {
                case let .transform(value):
                    transform = value
                case let .scopedAnimation(_, scopedContent):
                    transform = scopedContent.transform
                default:
                    transform = nil
                }
                guard let transform else {
                    return content.transform
                }
                return content.transform.map { $0.concatenating(transform) } ?? transform
            }
        }
    }

    package enum Effect {
        case identity
        case opacity(Float)
        case transform(CGAffineTransform)
        case resize(Path)
        case clip(Path)
        case scopedAnimation(Animation, HoverEffectContentList)
    }

    package var item: Item?

    package init(item: Item? = nil) {
        self.item = item
    }

    package var transform: CGAffineTransform? {
        item?.transform
    }
}
