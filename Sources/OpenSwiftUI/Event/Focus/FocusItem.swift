//
//  FocusItem.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: 25A477FB55B8969CF1C407C6BC07980E (SwiftUI)

import COpenSwiftUI
import OpenAttributeGraphShims
@_spi(ForOpenSwiftUIOnly)
import OpenSwiftUICore
#if os(iOS) || os(visionOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

// MARK: - FocusItem

struct FocusItem: Equatable {
    var base: Base
    var prefersFocusSystem: Bool
    #if os(iOS) || os(visionOS) || os(macOS)
    weak var responder: (any FocusResponder)?
    #else
    weak var responder: (any BaseFocusResponder)?
    #endif
    var seed: VersionSeed = .empty

    enum Base {
        case view(ViewItem)
        #if os(iOS) || os(visionOS)
        case platformItem(WeakBox<any UIFocusItem>)
        #else
        case platformItem(WeakBox<PlatformView>)
        #endif
        case platformResponder(WeakBox<PlatformView>)
    }

    struct ViewItem {
        var id: ViewIdentity
        var isFocusable: Bool
        var options: FocusableOptions
        var onFocusChange: (Bool) -> Void
        #if os(macOS)
        var delegatesFocusEffect: Bool
        #endif
    }

    var isFocusable: Bool {
        switch base {
        case let .view(item):
            return item.isFocusable
        case let .platformItem(item):
            #if os(iOS) || os(visionOS)
            return item.base?.canBecomeFocused ?? false
            #elseif os(macOS)
            return false
            #else
            _openSwiftUIUnimplementedFailure()
            #endif
        case let .platformResponder(item):
            #if os(iOS) || os(visionOS)
            if let responder = responder as? UIViewResponder {
                return responder.wantsOpenSwiftUIFocusItem
            }
            guard let view = item.base else { return false }
            if _SemanticFeature_v5.isEnabled {
                return view.firstFocusableDescendant != nil
            } else {
                return view.canBecomeFirstResponder
            }
            #elseif os(macOS)
            return item.base?.firstFocusableDescendant != nil
            #else
            _openSwiftUIUnimplementedFailure()
            #endif
        }
    }

    var isExpired: Bool {
        switch base {
        case .view:
            false
        case let .platformItem(item):
            item.base == nil
        case let .platformResponder(item):
            item.base == nil
        }
    }

    #if os(iOS) || os(visionOS)
    var platformResponder: PlatformView? {
        if case let .platformResponder(item) = base {
            return item.base
        }
        guard case let .platformItem(item) = base, let item = item.base else {
            return nil
        }
        if prefersFocusSystem, UIFocusSystem.focusSystem(for: item) != nil {
            return nil
        }
        return item as? UIView
    }
    #endif

    #if os(macOS)
    var isNavigable: Bool {
        switch base {
        case let .view(item):
            item.isFocusable && receivesFocusFromKeyboard
        case .platformItem:
            false
        case let .platformResponder(item):
            item.base?.firstFocusableDescendant != nil && receivesFocusFromKeyboard
        }
    }

    func focusDidChange(isFocused: Bool) {
        if case let .view(item) = base {
            item.onFocusChange(isFocused)
        }
        guard isFocused, let node = responder?.focusAccessibilityNode else { return }
        let element: PlatformAccessibilityElement?
        if node.impliedVisibility(consideringParent: true, with: nil) == .hidden {
            element = NSAccessibility.unignoredAncestor(of: node) as? PlatformAccessibilityElement
        } else {
            element = node
        }
        if let element {
            NSAccessibility.post(
                element: element.knownRepresentedElement,
                notification: .focusedUIElementChanged
            )
        }
    }

    var receivesFocusFromMouse: Bool {
        switch base {
        case let .view(item):
            item.options.contains(.fromMouse)
        case .platformItem:
            false
        case let .platformResponder(item):
            item.base?.needsPanelToBecomeKey ?? false
        }
    }

    var receivesFocusFromKeyboard: Bool {
        switch base {
        case let .view(item):
            return item.options.contains(.fromKeyboard)
        case .platformItem:
            return false
        case let .platformResponder(item):
            guard let view = item.base else { return false }
            return view.canBecomeKeyView || view.firstFocusableDescendant != nil
        }
    }

    var platformItemDrawsFocusRingMask: Bool {
        switch base {
        case let .view(item):
            return item.options.contains(.platformItemDrawsFocusRingMask)
        case .platformItem:
            return false
        case let .platformResponder(item):
            guard let view = item.base else { return false }
            return view.focusRingType != .none
        }
    }
    #endif

    func hasEqualIdentity(to other: FocusItem) -> Bool {
        switch (base, other.base) {
        case let (.view(lhs), .view(rhs)):
            lhs.id == rhs.id
        case let (.platformItem(lhs), .platformItem(rhs)):
            lhs.base === rhs.base
        case let (.platformResponder(lhs), .platformResponder(rhs)):
            lhs.base === rhs.base
        default:
            false
        }
    }

    static func isFocusChange(from oldItem: FocusItem?, to newItem: FocusItem?) -> Bool {
        switch (oldItem, newItem) {
        case (nil, nil):
            false
        case let (oldItem?, newItem?):
            !oldItem.hasEqualIdentity(to: newItem)
        default:
            true
        }
    }

    static func == (lhs: FocusItem, rhs: FocusItem) -> Bool {
        false
    }
}

// MARK: - PlatformView + Focus

extension PlatformView {
    var firstFocusableDescendant: PlatformView? {
        #if os(iOS) || os(visionOS)
        PlatformSubtreeIterator(stack: [[self]]).first { $0.canBecomeFirstResponder }
        #elseif os(macOS)
        PlatformSubtreeIterator(stack: [[self]]).first { view in
            let customizing = view as? any RecursiveIgnoreHitTestCustomizing
            return view.acceptsFirstResponder && view.canBecomeKeyView
                && !view.ignoreHitTest && !(customizing?.recursiveIgnoreHitTest ?? false)
        }
        #else
        _openSwiftUIUnimplementedFailure()
        #endif
    }
}

// MARK: - PlatformSubtreeIterator

private struct PlatformSubtreeIterator: Sequence, IteratorProtocol {
    var stack: [[PlatformView]]
    var count: Int = 0

    mutating func next() -> PlatformView? {
        #if os(iOS) || os(visionOS) || os(macOS)
        #if os(iOS) || os(visionOS)
        guard count < 10 else { return nil }
        #else
        guard count < Int.max else { return nil }
        #endif
        guard var views = stack.popLast() else { return nil }
        let view = views.removeFirst()
        defer { count += 1 }
        #if os(iOS) || os(visionOS)
        if view is UIScrollView, !(view is UITextView) {
            stack = []
            return nil
        }
        #endif
        if !views.isEmpty {
            stack.append(views)
        }
        if !view.subviews.isEmpty {
            #if os(iOS) || os(visionOS)
            guard stack.count < 4 else { return view }
            let layoutDirection = view.effectiveUserInterfaceLayoutDirection
            #else
            let layoutDirection = view.userInterfaceLayoutDirection
            #endif
            let subviews = layoutDirection == .rightToLeft
                ? Array(view.subviews.reversed())
                : view.subviews
            stack.append(subviews)
        }
        return view
        #else
        _openSwiftUIUnimplementedFailure()
        #endif
    }
}

// MARK: - FocusedItemInputKey

private struct FocusedItemInputKey: ViewInput {
    static var defaultValue: OptionalAttribute<FocusItem?> { .init() }
}

extension _ViewInputs {
    var focusedItem: Attribute<FocusItem?>? {
        get { base.focusedItem }
        set { base.focusedItem = newValue }
    }
}

extension _GraphInputs {
    var focusedItem: Attribute<FocusItem?>? {
        get { self[FocusedItemInputKey.self].attribute }
        set { self[FocusedItemInputKey.self] = .init(newValue) }
    }
}
