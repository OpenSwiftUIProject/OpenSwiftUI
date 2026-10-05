//
//  FocusEffectDelegate.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: 8C909BE7747C720C6B9D560863FD7609 (SwiftUI)

#if os(macOS)
import AppKit
import OpenAttributeGraphShims
@_spi(ForOpenSwiftUIOnly)
import OpenSwiftUICore

// MARK: - FocusEffectDelegateResponder

class FocusEffectDelegateResponder: DefaultLayoutViewResponder, FocusResponder {
    var focusAccessibilityNode: AccessibilityNode?
    var keyPressHandlers: [KeyPress.Handler] = []
    weak var focusRingView: (NSView & FocusRingDelegate)?

    var platformItem: NSView? { _openSwiftUIUnreachableCode() }
    var isEnabled: Bool { _openSwiftUIUnreachableCode() }

    var viewItem: FocusItem.ViewItem? { nil }
    var frame: CGRect? { nil }
    var isInVisibleRect: Bool { false }
    var effectiveLayoutDirection: LayoutDirection? { nil }

    var firstKeyViewInSubtree: NSView? {
        get { nil }
        set { _openSwiftUIEmptyStub() }
    }

    var lastKeyViewInSubtree: NSView? {
        get { nil }
        set { _openSwiftUIEmptyStub() }
    }

    var prefersDefaultFocus: Bool { false }
    var defaultFocusNamespace: Namespace.ID? { nil }
    var focusItem: FocusItem? { nil }
    var evaluateDefaultFocus: EvaluateDefaultFocusAction? { nil }
    var delegatesFocusEffect: Bool { false }

    func setFocusRingView(_ view: (NSView & FocusRingDelegate)?) {
        focusRingView = view
    }
}

// MARK: - EnvironmentValues + Focus Effect Delegation

private struct DelegatesFocusEffectKey: EnvironmentKey {
    static var defaultValue: Bool { false }
}

extension EnvironmentValues {
    var delegatesFocusEffect: Bool {
        get { self[DelegatesFocusEffectKey.self] }
        set { self[DelegatesFocusEffectKey.self] = newValue }
    }
}

extension CachedEnvironment.ID {
    fileprivate static let delegatesFocusEffect: CachedEnvironment.ID = .init()
}

extension _GraphInputs {
    var delegatesFocusEffect: Attribute<Bool> {
        mapEnvironment(id: .delegatesFocusEffect) { $0.delegatesFocusEffect }
    }
}

// MARK: - FocusEffectDelegateModifier

private struct FocusEffectDelegateModifier: MultiViewModifier, PrimitiveViewModifier {
    static func _makeView(
        modifier: _GraphValue<Self>,
        inputs: _ViewInputs,
        body: @escaping (_Graph, _ViewInputs) -> _ViewOutputs
    ) -> _ViewOutputs {
        guard inputs.preferences.requiresViewResponders else {
            return body(_Graph(), inputs)
        }
        var newInputs = inputs
        newInputs.transform = Attribute(FocusCoordinateSpaceTransform(
            transform: inputs.transform,
            position: inputs.animatedPosition()
        ))
        let responder = FocusEffectDelegateResponder(inputs: newInputs)
        let isEnabled = Attribute(value: !newInputs.archivedView.isArchived && !newInputs[UsingGraphicsRenderer.self])
        let focusEffect = Attribute(UpdateFocusEffectView(
            isEnabled: isEnabled,
            responder: responder
        ))
        var outputs = makeSecondaryLayerView(
            secondaryLayer: focusEffect,
            alignment: Attribute(value: Alignment.center),
            inputs: newInputs,
            body: body,
            flipOrder: false
        )
        outputs.preferences.viewResponders = Attribute(ResponderFilter(
            children: outputs.viewResponders(),
            responder: responder
        ))
        return outputs
    }

    struct ResponderFilter: StatefulRule {
        @Attribute var children: [ViewResponder]
        let responder: FocusEffectDelegateResponder

        typealias Value = [ViewResponder]

        mutating func updateValue() {
            responder.updateChildren($children.changedValue())
            if !hasValue {
                value = [responder]
            }
        }
    }
}
#endif
