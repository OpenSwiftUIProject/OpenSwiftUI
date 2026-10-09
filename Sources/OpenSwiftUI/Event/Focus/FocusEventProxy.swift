//
//  FocusEventProxy.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: 220887A402CE7023D01D5BCC1E080716 (SwiftUI)

import OpenAttributeGraphShims
@_spi(ForOpenSwiftUIOnly)
import OpenSwiftUICore

// MARK: - FocusEventProxyResponder

private class FocusEventProxyResponder: DefaultLayoutViewResponder {}

@inline(__always)
func asFocusEventProxyResponder(_ responder: ResponderNode) -> ViewResponder? {
    responder as? FocusEventProxyResponder
}

#if os(iOS) || os(visionOS)
// MARK: - FocusEventProxyModifier

struct FocusEventProxyModifier: MultiViewModifier, PrimitiveViewModifier {
    static func _makeView(
        modifier: _GraphValue<Self>,
        inputs: _ViewInputs,
        body: @escaping (_Graph, _ViewInputs) -> _ViewOutputs
    ) -> _ViewOutputs {
        var outputs = body(_Graph(), inputs)
        guard IOSFocusEnabledFlag.evaluate(inputs: inputs.base),
              inputs.preferences.requiresViewResponders else {
            return outputs
        }
        outputs.preferences.viewResponders = Attribute(FocusEventProxyResponderFilter(
            children: outputs.viewResponders(),
            responder: FocusEventProxyResponder(inputs: inputs)
        ))
        return outputs
    }
}

// MARK: - FocusEventProxyResponderFilter

private struct FocusEventProxyResponderFilter: StatefulRule {
    @Attribute var children: [ViewResponder]

    let responder: FocusEventProxyResponder

    typealias Value = [ViewResponder]

    mutating func updateValue() {
        responder.updateChildren($children.changedValue())
        if !hasValue {
            value = [responder]
        }
    }
}
#endif
