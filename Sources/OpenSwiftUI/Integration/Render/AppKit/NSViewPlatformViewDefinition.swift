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

    #if _OPENSWIFTUI_SWIFTUI_RENDER
    override static func makeView(kind: UnsafePointer<PlatformViewDefinition.ViewKind>) -> AnyObject {
        _makeView(kind: kind.pointee)
    }

    override static func makeLayerView(type: CALayer.Type, kind: UnsafePointer<PlatformViewDefinition.ViewKind>) -> AnyObject {
        preconditionFailure("TODO")
    }
    #else
    override static func makeView(kind: PlatformViewDefinition.ViewKind) -> AnyObject {
        _makeView(kind: kind)
    }

    override static func makeLayerView(type: CALayer.Type, kind: UnsafePointer<PlatformViewDefinition.ViewKind>) -> AnyObject {
        preconditionFailure("TODO")
    }
    #endif

    // FIXME: A shim for _OPENSWIFTUI_SWIFTUI_RENDER
    private static func _makeView(kind: PlatformViewDefinition.ViewKind) -> AnyObject {
        // TODO
        return NSView()
    }
}
#endif
