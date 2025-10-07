//
//  RendererEffect.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: 49800242E3DD04CB91F7CE115272DDC3 (SwiftUICore)

package import Foundation
package import OpenAttributeGraphShims

// MARK: - _RendererEffect

package protocol _RendererEffect: MultiViewModifier, PrimitiveViewModifier {
    func effectValue(size: CGSize) -> DisplayList.Effect

    static var isolatesChildPosition: Bool { get }

    static var disabledForFlattenedContent: Bool { get }

    static var preservesEmptyContent: Bool { get }

    static var isScrapeable: Bool { get }

    var scrapeableContent: ScrapeableContent.Content? { get }
}

// MARK: - _RendererEffect + Default Implementation

extension _RendererEffect {
    package static var isolatesChildPosition: Bool {
        false
    }

    package static var disabledForFlattenedContent: Bool {
        false
    }

    package static var preservesEmptyContent: Bool {
        false
    }

    package static var isScrapeable: Bool {
        false
    }

    package var scrapeableContent: ScrapeableContent.Content? {
        nil
    }

    package static func _makeRendererEffect(
        effect: _GraphValue<Self>,
        inputs: _ViewInputs,
        body: @escaping (_Graph, _ViewInputs) -> _ViewOutputs
    ) -> _ViewOutputs {
        var newInputs = inputs
        let scrapeableID: ScrapeableID
        if isScrapeable, inputs.isScrapeable {
            scrapeableID = .init()
            newInputs.scrapeableParentID = scrapeableID
        } else {
            scrapeableID = .none
        }
        if inputs.needsGeometry {
            if isolatesChildPosition {
                let resetTransform = Attribute(
                    ResetPositionTransform(
                        position: inputs.animatedPosition(),
                        transform: inputs.transform
                    )
                )
                newInputs.transform = resetTransform
                let origin = ViewGraph.current.$zeroPoint
                let roundedSize = Attribute(
                    RoundedSize(
                        position: inputs.containerPosition,
                        size: inputs.size,
                        pixelLength: inputs.pixelLength
                    )
                )
                newInputs.position = origin
                newInputs.containerPosition = origin
                newInputs.size = roundedSize
            } else {
                newInputs.containerPosition = inputs.animatedPosition()
            }
        }
        var outputs = body(_Graph(), newInputs)
        if inputs.preferences.requiresDisplayList {
            let identity = DisplayList.Identity()
            inputs.pushIdentity(identity)
            let displayList = Attribute(
                RendererEffectDisplayList(
                    identity: identity,
                    effect: effect.value,
                    position: inputs.animatedPosition(),
                    size: inputs.animatedSize(),
                    transform: inputs.transform,
                    containerPosition: inputs.containerPosition,
                    environment: inputs.environment,
                    safeAreaInsets: inputs.safeAreaInsets,
                    content: .init(outputs.displayList),
                    options: inputs.displayListOptions,
                    localID: scrapeableID,
                    parentID: inputs.scrapeableParentID
                )
            )
            if isScrapeable, inputs.isScrapeable {
                displayList.setFlags(.scrapeable, mask: .all)
            }
            outputs.displayList = displayList
        }
        return outputs
    }
}

// MARK: - RendererEffect

package protocol RendererEffect: Animatable, _RendererEffect {}

@available(OpenSwiftUI_v1_0, *)
extension RendererEffect {
    package static func makeRendererEffect(
        effect: _GraphValue<Self>,
        inputs: _ViewInputs,
        body: @escaping (_Graph, _ViewInputs) -> _ViewOutputs
    ) -> _ViewOutputs {
        guard inputs.needsGeometry || inputs.preferences.requiresDisplayList else {
            return body(_Graph(), inputs)
        }
        var effect = effect
        _makeAnimatable(value: &effect, inputs: inputs.base)
        return _makeRendererEffect(effect: effect, inputs: inputs, body: body)
    }

    nonisolated public static func _makeView(
        modifier: _GraphValue<Self>,
        inputs: _ViewInputs,
        body: @escaping (_Graph, _ViewInputs) -> _ViewOutputs
    ) -> _ViewOutputs {
        makeRendererEffect(effect: modifier, inputs: inputs, body: body)
    }

    @available(OpenSwiftUI_v2_0, *)
    nonisolated public static func _viewListCount(
        inputs: _ViewListCountInputs,
        body: (_ViewListCountInputs) -> Int?
    ) -> Int? {
        body(inputs)
    }
}

// MARK: - ResetPositionTransform

package struct ResetPositionTransform: Rule, AsyncAttribute {
    @Attribute var position: ViewOrigin
    @Attribute var transform: ViewTransform

    package init(position: Attribute<ViewOrigin>, transform: Attribute<ViewTransform>) {
        self._position = position
        self._transform = transform
    }

    package var value: ViewTransform {
        transform.withPosition(position)
    }
}

// MARK: - RendererEffectDisplayList

private struct RendererEffectDisplayList<Effect>: Rule, AsyncAttribute, ScrapeableAttribute where Effect: _RendererEffect {
    let identity: DisplayList.Identity
    @Attribute var effect: Effect
    @Attribute var position: ViewOrigin
    @Attribute var size: ViewSize
    @Attribute var transform: ViewTransform
    @Attribute var containerPosition: ViewOrigin
    @Attribute var environment: EnvironmentValues
    @OptionalAttribute var safeAreaInsets: SafeAreaInsets?
    @OptionalAttribute var content: DisplayList?
    let options: DisplayList.Options
    let localID: ScrapeableID
    let parentID: ScrapeableID

    var value: DisplayList {
        let content = content ?? .init()
        guard !content.isEmpty || Effect.preservesEmptyContent else {
            return .init()
        }
        let version = DisplayList.Version(forUpdate: ())
        let proxy = GeometryProxy(
            owner: .current!,
            size: $size,
            environment: $environment,
            transform: $transform,
            position: $position,
            safeAreaInsets: $safeAreaInsets,
            seed: .init(bitPattern: numericCast(version.value))
        )

        let e: DisplayList.Effect
        if Effect.disabledForFlattenedContent, content.features.contains(.flattened) {
            e = .identity
        } else {
            e = proxy.asCurrent {
                effect.effectValue(size: size.value)
            }
        }
        let frame = CGRect(
            origin: CGPoint(position - containerPosition),
            size: size.value
        )
        var item = DisplayList.Item(
            .effect(e, content),
            frame: frame,
            identity: identity,
            version: version
        )
        item.canonicalize(options: options)
        return DisplayList(item)
    }

    static func scrapeContent(from ident: AnyAttribute) -> ScrapeableContent.Item? {
        let pointer = ident.info.body.assumingMemoryBound(to: Self.self)
        guard let content = pointer[].effect.scrapeableContent else {
            return nil
        }
        return .init(
            content,
            ids: pointer[].localID,
            pointer[].parentID,
            position: pointer[].$position,
            size: pointer[].$size,
            transform: pointer[].$transform
        )
    }
}

// MARK: - GraphicsFilter + RendererEffect

extension GraphicsFilter: RendererEffect {
    package func effectValue(size: CGSize) -> DisplayList.Effect {
        .filter(self)
    }
}

// MARK: - GraphicsBlendMode + RendererEffect

extension GraphicsBlendMode: RendererEffect {
    package func effectValue(size: CGSize) -> DisplayList.Effect {
        .blendMode(self)
    }
}

// MARK: - GeometryGroupEffect

@available(OpenSwiftUI_v5_0, *)
@frozen
public struct _GeometryGroupEffect: RendererEffect, Equatable {
    package static let isolatesChildPosition: Bool = true

    package func effectValue(size: CGSize) -> DisplayList.Effect {
        .geometryGroup
    }

    @_alwaysEmitIntoClient
    nonisolated public init() {}
}

@available(OpenSwiftUI_v5_0, *)
extension View {
    /// Isolates the geometry (e.g. position and size) of the view
    /// from its parent view.
    ///
    /// By default OpenSwiftUI views push position and size changes down
    /// through the view hierarchy, so that only views that draw
    /// something (known as leaf views) apply the current animation to
    /// their frame rectangle. However in some cases this coalescing
    /// behavior can give undesirable results; inserting a geometry
    /// group can correct that. A group acts as a barrier between the
    /// parent view and its subviews, forcing the position and size
    /// values to be resolved and animated by the parent, before being
    /// passed down to each subview.
    ///
    /// The example below shows one use of this function: ensuring that
    /// the member views of each row in the stack apply (and animate
    /// as) a single geometric transform from their ancestor view,
    /// rather than letting the effects of the ancestor views be
    /// applied separately to each leaf view. If the members of
    /// `ItemView` may be added and removed at different times the
    /// group ensures that they stay locked together as animations are
    /// applied.
    ///
    ///     VStack {
    ///         ForEach(items) { item in
    ///             ItemView(item: item)
    ///                 .geometryGroup()
    ///         }
    ///     }
    ///
    /// Returns: a new view whose geometry is isolated from that of its
    /// parent view.
    @_alwaysEmitIntoClient
    nonisolated public func geometryGroup() -> some View {
        modifier(_GeometryGroupEffect())
    }
}
