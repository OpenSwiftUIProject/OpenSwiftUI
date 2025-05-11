//
//  NSViewPlatformViewDefinition.swift
//  OpenSwiftUI
//
//  Audited for macOS 15.0
//  Status: WIP

#if os(macOS)
@_spi(DisplayList_ViewSystem) import OpenSwiftUICore
import AppKit

// TODO
final class NSViewPlatformViewDefinition: PlatformViewDefinition, @unchecked Sendable {
    override final class var system: PlatformViewDefinition.System { .nsView }

    override static func makeView(kind: PlatformViewDefinition.ViewKind) -> AnyObject {
        // TODO
        return NSView()
    }

    override static func makeLayerView(type: CALayer.Type, kind: PlatformViewDefinition.ViewKind) -> AnyObject {
        preconditionFailure("TODO")
    }
}
#endif
