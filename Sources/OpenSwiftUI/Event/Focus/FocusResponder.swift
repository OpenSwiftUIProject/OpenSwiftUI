//
//  FocusResponder.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete

import Foundation
@_spi(ForOpenSwiftUIOnly)
import OpenSwiftUICore

#if os(iOS) || os(visionOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

#if os(iOS) || os(visionOS)
typealias PlatformFocusItem = any UIFocusItem
#else
typealias PlatformFocusItem = PlatformView
#endif

// MARK: - BaseFocusResponder

protocol BaseFocusResponder: ResponderNode {
    var platformItem: PlatformFocusItem? { get }
    var viewItem: FocusItem.ViewItem? { get }
    var frame: CGRect? { get }
    var isInVisibleRect: Bool { get }
    var isEnabled: Bool { get }
    #if os(macOS)
    var effectiveLayoutDirection: LayoutDirection? { get }
    var firstKeyViewInSubtree: NSView? { get set }
    var lastKeyViewInSubtree: NSView? { get set }
    #endif
    var prefersDefaultFocus: Bool { get }
    var defaultFocusNamespace: Namespace.ID? { get }
    #if os(iOS) || os(visionOS)
    var focusGroupID: FocusGroupIdentifier? { get }
    #endif
}

extension BaseFocusResponder {
    var isInVisibleRect: Bool {
        #if os(macOS)
        frame != nil
        #elseif os(iOS) || os(visionOS)
        // Deleted in the target image.
        _openSwiftUIUnreachableCode()
        #else
        _openSwiftUIUnimplementedFailure()
        #endif
    }

    var prefersDefaultFocus: Bool { false }

    var defaultFocusNamespace: Namespace.ID? { nil }
}

// MARK: - FocusResponder

protocol FocusResponder: BaseFocusResponder {
    var focusItem: FocusItem? { get }
    var focusAccessibilityNode: AccessibilityNode? { get set }
    var keyPressHandlers: [KeyPress.Handler] { get set }
    #if os(macOS)
    var evaluateDefaultFocus: EvaluateDefaultFocusAction? { get }
    var focusRingView: (NSView & FocusRingDelegate)? { get }
    var delegatesFocusEffect: Bool { get }
    func setFocusRingView(_ view: (NSView & FocusRingDelegate)?)
    #endif
}

extension FocusResponder {
    var platformItem: PlatformFocusItem? {
        guard let focusItem, case let .platformItem(item) = focusItem.base else { return nil }
        return item.base
    }

    var viewItem: FocusItem.ViewItem? {
        #if os(macOS)
        guard let focusItem, case let .view(item) = focusItem.base else { return nil }
        return item
        #elseif os(iOS) || os(visionOS)
        // Deleted in the target image.
        _openSwiftUIUnreachableCode()
        #else
        _openSwiftUIUnimplementedFailure()
        #endif
    }
}

// MARK: - ResponderNode + Focus

extension ResponderNode {
    func visitFocusResponders(applying visitor: (any FocusResponder) -> ResponderVisitorResult) {
        visit { responder in
            guard let responder = responder as? any FocusResponder else { return .next }
            return visitor(responder)
        }
    }

    func visitBaseFocusResponders(applying visitor: (any BaseFocusResponder) -> ResponderVisitorResult) {
        visit { responder in
            guard let responder = responder as? any BaseFocusResponder else { return .next }
            return visitor(responder)
        }
    }
}

#if os(iOS) || os(visionOS)
extension UIViewResponder {
    // These witnesses are deleted in the target image.
    var frame: CGRect? { _openSwiftUIUnreachableCode() }
    var focusGroupID: FocusGroupIdentifier? { _openSwiftUIUnreachableCode() }

    var isEnabled: Bool { true }
}
#endif
