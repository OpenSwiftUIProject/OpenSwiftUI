//
//  ResponderViewModifier.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: CBE01018B6DA97C826725A0E8E913C80 (SwiftUI)

import OpenAttributeGraphShims
@_spi(ForOpenSwiftUIOnly)
import OpenSwiftUICore

// MARK: - ResponderViewModifier

struct ResponderViewModifier<Content>: MultiViewModifier, PrimitiveViewModifier where Content: ViewModifier {
    var content: (ResponderNode) -> Content

    static func _makeView(
        modifier: _GraphValue<Self>,
        inputs: _ViewInputs,
        body: @escaping (_Graph, _ViewInputs) -> _ViewOutputs
    ) -> _ViewOutputs {
        let responder = DefaultLayoutViewResponder(inputs: inputs)
        let child = _GraphValue(ResponderChild(modifier: modifier.value, responder: responder))
        var outputs = Content.makeDebuggableView(modifier: child, inputs: inputs, body: body)
        if inputs.preferences.requiresViewResponders {
            outputs.preferences.viewResponders = Attribute(DefaultLayoutResponderFilter(
                children: outputs.viewResponders(),
                responder: responder
            ))
        }
        return outputs
    }
}

// MARK: - ResponderChild

private struct ResponderChild<Content>: Rule where Content: ViewModifier {
    @Attribute var modifier: ResponderViewModifier<Content>
    let responder: DefaultLayoutViewResponder

    var value: Content {
        modifier.content(responder)
    }
}
