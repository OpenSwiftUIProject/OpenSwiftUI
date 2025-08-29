//
//  IdentifiedModifier.swift
//  OpenSwiftUI
//
//  Status: Complete
//  ID: 972049776785601E5EF56C4D9DFD84DB (SwiftUI)

import OpenAttributeGraphShims
@_spi(ForOpenSwiftUIOnly)
import OpenSwiftUICore

// MARK: - _IdentifiedModifier [6.4.41]

@available(OpenSwiftUI_v1_0, *)
@frozen
public struct _IdentifiedModifier<Identifier>: ViewModifier, MultiViewModifier, PrimitiveViewModifier, Equatable where Identifier: Hashable {
    public var identifier: Identifier

    @inlinable
    public init(identifier: Identifier) {
        self.identifier = identifier
    }

    nonisolated public static func _makeView(
        modifier: _GraphValue<Self>,
        inputs: _ViewInputs,
        body: @escaping (_Graph, _ViewInputs) -> _ViewOutputs
    ) -> _ViewOutputs {
        var outputs = body(_Graph(), inputs)
        let transform = IdentifiedViewTransform(
            modifier: modifier.value,
            size: inputs.animatedSize(),
            position: inputs.animatedPosition(),
            transform: inputs.transform,
            environment: inputs.environment,
            nodeList: OptionalAttribute(outputs.accessibilityNodes),
            platform: IdentifiedViewPlatformInputs(inputs: inputs, outputs: outputs)
        )
        outputs.preferences.makePreferenceTransformer(
            inputs: inputs.preferences,
            key: _IdentifiedViewsKey.self,
            transform: Attribute(transform)
        )
        return outputs
    }
}

@available(*, unavailable)
extension _IdentifiedModifier: Sendable {}

@available(OpenSwiftUI_v1_0, *)
extension View {
    @inlinable
    @MainActor
    @preconcurrency public func _identified<I>(by identifier: I) -> some View where I: Hashable {
        return modifier(_IdentifiedModifier(identifier: identifier))
    }
}

private struct IdentifiedViewTransform<Identifier>: Rule, AsyncAttribute where Identifier: Hashable {
    @Attribute var modifier: _IdentifiedModifier<Identifier>
    @Attribute var size: ViewSize
    @Attribute var position: ViewOrigin
    @Attribute var transform: ViewTransform
    @Attribute var environment: EnvironmentValues
    @OptionalAttribute var nodeList: AccessibilityNodeList?
    var platform: IdentifiedViewPlatformInputs

    var value: (inout _IdentifiedViewTree) -> Void {
        let proxy = _IdentifiedViewProxy(
            identifier: modifier.identifier,
            size: size.value,
            position: position,
            transform: transform,
            accessibilityNode: AccessibilityNodeProxy.makeProxyForIdentifiedView(with: nodeList, environment: environment),
            platform: _IdentifiedViewProxy.Platform(platform)
        )
        return { (tree: inout _IdentifiedViewTree) in
            tree = .array([
                .proxy(proxy),
                tree,
            ])
        }
    }
}
