//
//  UIViewPlatformViewDefinition.swift
//  OpenSwiftUI
//
//  Audited for iOS 18.0
//  Status: WIP

#if os(iOS)
@_spi(DisplayList_ViewSystem) import OpenSwiftUICore
import UIKit

// TODO
final class UIViewPlatformViewDefinition: PlatformViewDefinition, @unchecked Sendable {
    override final class var system: PlatformViewDefinition.System { .uiView }
    
    override class func makeView(kind: PlatformViewDefinition.ViewKind) -> AnyObject {
        preconditionFailure("TODO")
    }
    
    override class func makeLayerView(type: CALayer.Type, kind: PlatformViewDefinition.ViewKind) -> AnyObject {
        preconditionFailure("TODO")
    }
}
#endif
