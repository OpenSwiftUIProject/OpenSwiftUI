//
//  FocusRingNSButton.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete

#if os(macOS)
import AppKit
import COpenSwiftUI

// MARK: - FocusRingNSButton

class FocusRingNSButton: NSButton, FocusRingDelegate {
    var focused: Bool = false
    var canShowFocusRing: Bool = false

    override var acceptsFirstResponder: Bool {
        false
    }

    override func _shouldShowFirstResponder(for cell: NSCell) -> Bool {
        focused && canShowFocusRing
    }

    override func hitTest(_ point: NSPoint) -> NSView? {
        nil
    }
}
#endif
