//
//  PlatformAccessibilityElement.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: WIP

import Foundation
@_spi(ForOpenSwiftUIOnly)
import OpenSwiftUICore
#if os(macOS)
import AppKit
import COpenSwiftUI
#elseif canImport(UIKit)
import UIKit
#endif

// MARK: - PlatformAccessibilityElementProtocol

extension PlatformAccessibilityElementProtocol where Self: NSObject {
    func traverseAncestors(_ body: (PlatformAccessibilityElement) -> Bool) {
        #if os(macOS) || canImport(UIKit)
        var element: PlatformAccessibilityElement? = self
        while let current = element {
            guard body(current) else {
                return
            }
            #if os(macOS)
            if let cell = current as? NSCell, let controlView = cell.controlView {
                element = controlView
            } else if let parent = current.valueForAttribute(.parent, asType: NSObject.self),
                      !(parent is NSWindow), !(parent is NSView) {
                element = parent
            } else if let view = current as? NSView, let superview = view.superview {
                element = superview
            } else {
                element = current.valueForAttribute(.parent, asType: NSObject.self)
            }
            #else
            if current.responds(to: #selector(getter: UIAccessibilityElement.accessibilityContainer)),
               let container = (current as AnyObject).accessibilityContainer as? PlatformAccessibilityElement {
                element = container
            } else if let view = current as? UIView {
                element = view.superview
            } else {
                element = nil
            }
            #endif
        }
        #else
        _openSwiftUIUnimplementedFailure()
        #endif
    }

    #if os(macOS)
    func valueForAttribute<Value>(_ attribute: NSAccessibility.Attribute, asType: Value.Type) -> Value? {
        NSAccessibilityBeginInternalAccessors()
        defer { NSAccessibilityEndInternalAccessors() }
        guard let value = NSAccessibilityEntryPointValueForAttribute(self, attribute),
              !(value is NSNull) else {
            return nil
        }
        return value as? Value
    }
    #endif
}
