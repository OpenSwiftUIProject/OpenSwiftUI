//
//  NSInheritedView.swift
//  OpenSwiftUI
//
//  Audited for macOS 15.0
//  Status: WIP

#if os(macOS)

import OpenSwiftUI_SPI
import AppKit

final class _NSInheritedView: NSView {
    var hitTestsAsOpaque: Bool = false

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}

#endif
