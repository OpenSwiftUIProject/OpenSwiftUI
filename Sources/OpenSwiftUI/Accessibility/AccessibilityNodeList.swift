//
//  AccessibilityNodeList.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete

import OpenAttributeGraphShims
@_spi(ForOpenSwiftUIOnly)
import OpenSwiftUICore

// MARK: - AccessibilityNodeList

struct AccessibilityNodeList: Equatable {
    var nodes: [AccessibilityNode]
    var version: DisplayList.Version
}

// MARK: - AccessibilityNodesKey

struct AccessibilityNodesKey: PreferenceKey {
    static let defaultValue = AccessibilityNodeList(nodes: [], version: .init())

    static func reduce(value: inout AccessibilityNodeList, nextValue: () -> AccessibilityNodeList) {
        let next = nextValue()
        value.version.combine(with: next.version)
        value.nodes.append(contentsOf: next.nodes)
    }
}

extension PreferencesInputs {
    @inline(__always)
    var requiresAccessibilityNodes: Bool {
        get { contains(AccessibilityNodesKey.self) }
        set {
            if newValue {
                add(AccessibilityNodesKey.self)
            } else {
                remove(AccessibilityNodesKey.self)
            }
        }
    }
}

extension _ViewOutputs {
    @inline(__always)
    var accessibilityNodes: Attribute<AccessibilityNodeList>? {
        get { self[AccessibilityNodesKey.self] }
        set { self[AccessibilityNodesKey.self] = newValue }
    }
}
