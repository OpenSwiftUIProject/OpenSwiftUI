//
//  UIViewPlatformViewDefinition.swift
//  OpenSwiftUI
//
//  Audited for iOS 18.0
//  Status: WIP

@_spi(DisplayList_ViewSystem) import OpenSwiftUICore

final class UIViewPlatformViewDefinition: PlatformViewDefinition, @unchecked Sendable {
    override final class var system: PlatformViewDefinition.System { .uiView }
    // TODO
}
