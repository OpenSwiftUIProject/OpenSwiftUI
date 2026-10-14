//
//  AllowsHitTestingModifier.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: 9EE920A99C667C354EEDF67A755D6AA8 (SwiftUI)

import OpenAttributeGraphShims
@_spi(ForOpenSwiftUIOnly)
public import OpenSwiftUICore

// MARK: - _AllowsHitTestingModifier

/// A modifier that controls whether a view participates in hit test
/// operations.
@available(OpenSwiftUI_v1_0, *)
@frozen
public struct _AllowsHitTestingModifier: _RendererEffect, Equatable {
    public var allowsHitTesting: Bool

    @inlinable
    nonisolated public init(allowsHitTesting: Bool) {
        self.allowsHitTesting = allowsHitTesting
    }

    nonisolated public static func _makeView(
        modifier: _GraphValue<Self>,
        inputs: _ViewInputs,
        body: @escaping (_Graph, _ViewInputs) -> _ViewOutputs
    ) -> _ViewOutputs {
        var outputs = _makeRendererEffect(effect: modifier, inputs: inputs, body: body)
        if inputs.preferences.requiresViewResponders {
            let filter = AllowsHitTestingFilter(
                modifier: modifier.value,
                children: outputs.viewResponders(),
                responder: AllowsHitTestingResponder(inputs: inputs)
            )
            outputs[ViewRespondersKey.self] = Attribute(filter)
        }
        _makeAccessibilityHitTestingModifier(
            modifier: modifier,
            inputs: inputs,
            outputs: &outputs
        )
        return outputs
    }

    package func effectValue(size: CGSize) -> DisplayList.Effect {
        allowsHitTesting ? .identity : .properties(.ignoresEvents)
    }
}

// MARK: - View + allowsHitTesting

@available(OpenSwiftUI_v1_0, *)
extension View {

    /// Configures whether this view participates in hit test operations.
    ///
    /// - Parameter enabled: A Boolean value that indicates whether this view
    ///   participates in hit test operations.
    ///
    /// - Returns: A view that participates in hit test operations only when
    ///   `enabled` is `true`.
    @inlinable
    nonisolated public func allowsHitTesting(_ enabled: Bool) -> some View {
        modifier(_AllowsHitTestingModifier(allowsHitTesting: enabled))
    }
}

// MARK: - AllowsHitTestingResponder

private final class AllowsHitTestingResponder: DefaultLayoutViewResponder {
    var _allowsHitTesting: Bool = true

    override var allowsHitTesting: Bool { _allowsHitTesting }

    override func containsGlobalPoints(
        _ points: [PlatformPoint],
        cacheKey: UInt32?,
        options: ContainsPointsOptions
    ) -> ContainsPointsResult {
        guard _allowsHitTesting else {
            return .passthrough(to: children)
        }
        return super.containsGlobalPoints(points, cacheKey: cacheKey, options: options)
    }

    override func extendPrintTree(string: inout String) {
        string.append("allowed = \(_allowsHitTesting)")
    }
}

// MARK: - AllowsHitTestingFilter

private struct AllowsHitTestingFilter: StatefulRule {
    @Attribute var modifier: _AllowsHitTestingModifier
    @Attribute var children: [ViewResponder]
    let responder: AllowsHitTestingResponder

    typealias Value = [ViewResponder]

    mutating func updateValue() {
        responder._allowsHitTesting = modifier.allowsHitTesting
        responder.updateChildren($children.changedValue())
        if !hasValue {
            value = [responder]
        }
    }
}
