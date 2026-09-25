//
//  AccessibilityFocus.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: D40E4D2B9502265C452AA4AA6D326657 (SwiftUI)

import Foundation
import OpenAttributeGraphShims
@_spi(ForOpenSwiftUIOnly)
import OpenSwiftUICore
#if os(macOS)
import AppKit
import COpenSwiftUI
#endif

// MARK: - AccessibilityFocus

struct AccessibilityFocus {
    var byTechnology: [AccessibilityTechnology: Target] = [:]

    struct Target {
        weak var platformAccessibilityElement: PlatformAccessibilityElement?

        var ancestorAccessibilityNode: AccessibilityNode? {
            if let node = platformAccessibilityElement as? AccessibilityNode {
                return node
            }
            if let node = platformAccessibilityElement?.accessibilityNodeForPlatformElement {
                return node
            }
            guard let platformAccessibilityElement else {
                return nil
            }
            if let node = platformAccessibilityElement.accessibilityNodeForPlatformElement {
                return node
            }
            var node: AccessibilityNode?
            platformAccessibilityElement.traverseAncestors { element in
                if let ancestor = element as? AccessibilityNode {
                    node = ancestor
                    return false
                }
                if let ancestor = element.accessibilityNodeForPlatformElement {
                    node = ancestor
                    return false
                }
                return true
            }
            return node
        }

        func match(focusStoreNode: AccessibilityNode) -> Match? {
            if let node = (platformAccessibilityElement as? AccessibilityNode)
                ?? platformAccessibilityElement?.accessibilityNodeForPlatformElement,
               node == focusStoreNode {
                return .directlyFocused
            }
            if let element = focusStoreNode.platformElement,
               let target = platformAccessibilityElement,
               element === target {
                return .directlyFocused
            }
            if let ancestor = ancestorAccessibilityNode,
               ancestor == focusStoreNode {
                return .platformChildFocused
            }
            if let ancestor = ancestorAccessibilityNode {
                var isContainerChildFocused = false
                ancestor.traverseAncestors { element in
                    if element === (focusStoreNode.platformElement ?? focusStoreNode) {
                        isContainerChildFocused = true
                        return false
                    }
                    return true
                }
                if isContainerChildFocused {
                    return .containerChildFocused
                }
            }
            #if os(macOS)
            if let element = platformAccessibilityElement,
               let tableCellClass = AXNSTableViewCellMockElementClass(),
               element.isKind(of: tableCellClass),
               let children = element.valueForAttribute(.children, asType: [PlatformAccessibilityElement].self),
               children.count == 1,
               children[0] === (focusStoreNode.platformElement ?? focusStoreNode) {
                return .implicitlyFocused
            }
            #endif
            return nil
        }
    }

    enum Match: CaseIterable, Hashable {
        case directlyFocused
        case implicitlyFocused
        case platformChildFocused
        case containerChildFocused
    }
}

// MARK: - AccessibilityFocusInputKey

private struct AccessibilityFocusInputKey: ViewInput {
    static var defaultValue: OptionalAttribute<AccessibilityFocus> { .init() }
}

extension _ViewInputs {
    var accessibilityFocus: Attribute<AccessibilityFocus>? {
        get { base.accessibilityFocus }
        set { base.accessibilityFocus = newValue }
    }
}

extension _GraphInputs {
    var accessibilityFocus: Attribute<AccessibilityFocus>? {
        get { self[AccessibilityFocusInputKey.self].attribute }
        set { self[AccessibilityFocusInputKey.self] = .init(newValue) }
    }
}
