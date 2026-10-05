//
//  PlatformFocusViewProvider.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete

// MARK: - PlatformFocusViewProvider

protocol PlatformFocusViewProvider: PlatformView {
    var focusView: PlatformView { get }
}

// MARK: - PlatformFocusResponderProvider

protocol PlatformFocusResponderProvider: PlatformView {
    var focusViewResponder: PlatformViewResponder? { get }
}
