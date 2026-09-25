//
//  PlatformAccessibilityElement.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete

public import Foundation

// MARK: - PlatformAccessibilityElementProtocol

@_spi(ForOpenSwiftUIOnly)
@available(OpenSwiftUI_v6_0, *)
#if canImport(ObjectiveC)
@objc
#endif
public protocol PlatformAccessibilityElementProtocol: NSObjectProtocol {
    #if os(macOS)
    @objc dynamic var knownRepresentedElement: PlatformAccessibilityElement { get }
    @objc dynamic var rotorOwnerElement: PlatformAccessibilityElement { get }
    #endif
}

// MARK: - PlatformAccessibilityElement

@_spi(ForOpenSwiftUIOnly)
@available(OpenSwiftUI_v6_0, *)
public typealias PlatformAccessibilityElement = NSObject & PlatformAccessibilityElementProtocol

// MARK: - NSObject + PlatformAccessibilityElementProtocol

@_spi(ForOpenSwiftUIOnly)
@available(OpenSwiftUI_v6_0, *)
extension NSObject: PlatformAccessibilityElementProtocol {
    #if canImport(ObjectiveC)
    @objc
    #endif
    dynamic open var knownRepresentedElement: PlatformAccessibilityElement {
        self
    }

    #if canImport(ObjectiveC)
    @objc
    #endif
    dynamic open var rotorOwnerElement: PlatformAccessibilityElement {
        self
    }
}
