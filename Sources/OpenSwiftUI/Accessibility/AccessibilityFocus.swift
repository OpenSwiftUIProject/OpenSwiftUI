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
            #if os(iOS) || os(visionOS) || os(macOS)
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
            #else
            _openSwiftUIPlatformUnimplementedFailure()
            #endif
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
            #if os(iOS) || os(visionOS) || os(macOS)
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
            #else
            if ancestorAccessibilityNode != nil {
                _openSwiftUIPlatformUnimplementedFailure()
            }
            #endif
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

        func takesPriority(over other: Match) -> Bool {
            // The platform implementation returns false for every valid match.
            false
        }
    }

    static func move(to element: PlatformAccessibilityElement, for technologies: AccessibilityTechnologies) {
        guard technologies.contains(.voiceOver) else {
            return
        }
        #if os(iOS) || os(visionOS)
        if let node = (element as? AccessibilityNode) ?? element.accessibilityNodeForPlatformElement,
           node.parent == nil,
           !node.visibility[.host, default: false],
           let host = node.viewRendererHost {
            host.updateAccessibilityEnvironment()
            AccessibilityCore.Notification.ScreenChanged(
                nextElement: element,
                updateImmediately: true
            ).post()
        } else {
            AccessibilityCore.Notification.LayoutChanged(nextElement: element).post()
        }
        #elseif os(macOS)
        let sourceElement: PlatformAccessibilityElement
        if NSAccessibilityRemoteUIElement.isRemoteUIApp(),
           let node = (element as? AccessibilityNode) ?? element.accessibilityNodeForPlatformElement,
           let host = node.viewRendererHost as? NSView {
            sourceElement = host
        } else if let window = element.valueForAttribute(.window, asType: NSObject.self) {
            sourceElement = window
        } else {
            return
        }
        var nextElement = element.knownRepresentedElement
        if let node = (element as? AccessibilityNode) ?? element.accessibilityNodeForPlatformElement,
           node.parent == nil,
           !node.visibility[.host, default: false],
           let host = node.viewRendererHost {
            host.updateAccessibilityEnvironment()
        }
        if let children = NSAccessibility.unignoredChildrenForOnlyChild(from: nextElement) as? [PlatformAccessibilityElement],
           let first = children.first {
            nextElement = first
        }
        AccessibilityCore.Notification.LayoutChanged(
            sourceElement: sourceElement,
            nextElement: nextElement
        ).post()
        #else
        _openSwiftUIPlatformUnimplementedFailure()
        #endif
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
