//
//  FocusViewGraph.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: A452B616B2FA920F078225192036641B (SwiftUI)

import OpenAttributeGraphShims
@_spi(ForOpenSwiftUIOnly)
import OpenSwiftUICore
#if os(iOS) || os(visionOS)
import UIKit
#endif

// MARK: - Focus System Inputs

extension _GraphInputs {
    var isFocusSystemEnabled: Attribute<Bool>? {
        get { self[IsFocusSystemEnabledKey.self].attribute }
        set { self[IsFocusSystemEnabledKey.self] = .init(newValue) }
    }

    private struct IsFocusSystemEnabledKey: GraphInput {
        static let defaultValue: OptionalAttribute<Bool> = .init()
    }
}

// MARK: - FocusViewGraph

struct FocusViewGraph: ViewGraphFeature {
    @OptionalAttribute var focusedItem: FocusItem??
    @OptionalAttribute var focusedValues: FocusedValues?
    @OptionalAttribute var focusStore: FocusStore?
    @OptionalAttribute var isFocusSystemEnabled: Bool?
    @Attribute var accessibilityFocusStore: AccessibilityFocusStore
    @Attribute var accessibilityFocus: AccessibilityFocus
    var needsFocusUpdate: Bool
    var wasFocusSystemEnabled: Bool
    var needsFocusSystemEnabledUpdate: Bool

    init(graph: ViewGraph) {
        let oldSubgraph = Subgraph.current
        Subgraph.current = graph.globalSubgraph
        defer { Subgraph.current = oldSubgraph }

        if graph.requestedOutputs.contains(.focus) {
            _focusedItem = .init(Attribute(value: nil))
            _focusedValues = .init(Attribute(value: .init()))
            _focusStore = .init(Attribute(value: .init()))
            #if os(macOS)
            if CoreTesting.isRunning {
                _isFocusSystemEnabled = .init(Attribute(value: true))
            } else {
                _isFocusSystemEnabled = .init()
            }
            #else
            _ = CoreTesting.isRunning
            _isFocusSystemEnabled = .init(Attribute(value: false))
            #endif
        } else {
            _focusedItem = .init()
            _focusedValues = .init()
            _focusStore = .init()
            _isFocusSystemEnabled = .init()
        }
        _accessibilityFocusStore = Attribute(value: .init())
        _accessibilityFocus = Attribute(value: .init())
        needsFocusUpdate = false
        wasFocusSystemEnabled = false
        needsFocusSystemEnabledUpdate = false
    }

    mutating func modifyViewInputs(inputs: inout _ViewInputs, graph: ViewGraph) {
        inputs.focusedItem = $focusedItem
        inputs.focusedValues = $focusedValues
        inputs.focusStore = $focusStore
        inputs.base.isFocusSystemEnabled = $isFocusSystemEnabled
        inputs.accessibilityFocusStore = $accessibilityFocusStore
        inputs.accessibilityFocus = $accessibilityFocus
    }

    mutating func needsUpdate(graph: ViewGraph) -> Bool {
        #if os(macOS)
        needsFocusUpdate
        #elseif os(iOS) || os(visionOS)
        let needsFocusUpdate = self.needsFocusUpdate
        if let view = graph.delegate?.as(UIView.self) {
            let isEnabled = UIFocusSystem.focusSystem(for: view) != nil
            needsFocusSystemEnabledUpdate = isEnabled != wasFocusSystemEnabled
            wasFocusSystemEnabled = isEnabled
        }
        return needsFocusUpdate || needsFocusSystemEnabledUpdate
        #else
        _openSwiftUIPlatformUnimplementedWarning()
        return false
        #endif
    }

    mutating func update(graph: ViewGraph) {
        if needsFocusUpdate {
            needsFocusUpdate = false
            graph.delegate?.as((any FocusHost).self)?.focusDidChange()
        }
        if needsFocusSystemEnabledUpdate, let attribute = $isFocusSystemEnabled {
            needsFocusSystemEnabledUpdate = false
            graph.asyncTransaction(
                mutation: IsFocusSystemEnabledMutation(
                    attr: WeakAttribute(attribute),
                    value: wasFocusSystemEnabled
                ),
                style: .deferred
            )
        }
    }

    private struct IsFocusSystemEnabledMutation: GraphMutation {
        var attr: WeakAttribute<Bool>
        var value: Bool

        func apply() {
            attr.attribute?.value = value
        }

        mutating func combine<T: GraphMutation>(with other: T) -> Bool {
            guard let other = other as? IsFocusSystemEnabledMutation,
                  other.attr == attr else {
                return false
            }
            value = other.value
            return true
        }
    }
}
