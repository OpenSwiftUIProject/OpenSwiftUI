//
//  NSProjectionView.swift
//  OpenSwiftUI
//
//  Audited for macOS 15.0
//  Status: WIP

#if os(macOS)

import OpenSwiftUI_SPI
import AppKit

final class _NSProjectionView: NSView {

    override var wantsUpdateLayer: Bool { true }
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}

#endif
