//
//  NSGraphicsView.swift
//  OpenSwiftUI
//
//  Audited for 6.0.87
//  Status: WIP

#if os(macOS)

import OpenSwiftUI_SPI
import AppKit

final class _NSGraphicsView: NSView {
    var recursiveIgnoreHitTest: Bool = false

    var customAcceptsFirstMouse: Bool?

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}

#endif
