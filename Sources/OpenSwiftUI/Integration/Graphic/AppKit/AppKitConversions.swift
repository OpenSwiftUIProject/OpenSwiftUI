//
//  AppKitConversions.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: WIP

#if canImport(AppKit)
import AppKit
import OpenSwiftUICore

// MARK: - ControlSize Conversions

extension NSControl.ControlSize {
    init(_ controlSize: ControlSize) {
        switch controlSize {
        case .mini:
            self = .mini
        case .small:
            self = .small
        case .regular:
            self = .regular
        case .large:
            self = .large
        case .extraLarge:
            if #available(macOS 26.0, *) {
                self = .extraLarge
            } else {
                self = .large
            }
        }
    }
}
#endif
