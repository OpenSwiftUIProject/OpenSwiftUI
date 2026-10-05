//
//  FocusBridge.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: WIP

@_spi(ForOpenSwiftUIOnly)
import OpenSwiftUICore

// MARK: - FocusHost

protocol FocusHost: ViewRendererHost {
    var focusedItem: FocusItem? { get }
    var focusedValues: FocusedValues { get set }
    var currentAccessibilityFocusStore: AccessibilityFocusStore { get set }

    func focus(item: FocusItem)
    func focusDidChange()
}

// MARK: - FocusBridge [TBA]

class FocusBridge {
    var flags: Flags

    #if os(macOS)
    lazy var navigator: FocusNavigator = .init(bridge: self)
    #endif

    // MARK: - Initialization [TBA]

    init() {
        _openSwiftUIUnimplementedFailure()
    }

    // MARK: - Platform focus [TBA]

    var host: (PlatformView & FocusBridgeProvider & FocusHost)? {
        _openSwiftUIUnimplementedFailure()
    }

    func moveFocus(to item: FocusItem, designatedPlatformResponder: PlatformView?) {
        _openSwiftUIUnimplementedFailure()
    }

    var canAcceptFocus: Bool {
        #if os(macOS)
        flags.contains(.canAcceptFocus)
        #else
        _openSwiftUIUnimplementedFailure()
        #endif
    }

    // MARK: - Flags

    struct Flags: OptionSet {
        var rawValue: Int

        static let canAcceptFocus: Flags = .init(rawValue: 1 << 1)
    }
}

// MARK: - FocusBridgeProvider

protocol FocusBridgeProvider: AnyObject {
    var focusBridge: FocusBridge { get }
}
