//
//  NSTextField+Environment.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: WIP

#if os(macOS)
import AppKit
import OpenSwiftUICore

// MARK: - NSTextField + Environment

extension NSTextField {
    func update(in environment: EnvironmentValues, axis: Axis) -> Bool {
        _openSwiftUIUnimplementedWarning()
        return false
    }
}
#endif
