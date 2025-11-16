//
//  CoreSystemUtils.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete

import CoreFoundation_Private
package import OpenSwiftUI_SPI

// NOTE: use runtime check instead of #if targetEnvironment(macCatalyst)
// Because Mac Catalyst will use macOS-varient build of OpenSwiftUICore.framework and Mac Catalyst/UIKitForMac varient of OpenSwiftUI.framework
@inline(__always)
package func isCatalyst() -> Bool {
    #if os(macOS) || targetEnvironment(macCatalyst)
    _CFMZEnabled()
    #else
    false
    #endif
}

@inline(__always)
package func isUIKitBased() -> Bool {
    #if os(macOS) || targetEnvironment(macCatalyst)
    _CFMZEnabled()
    #elseif os(iOS) || os(visionOS)
    true
    #else
    false
    #endif
}

@inline(__always)
package func isAppKitBased() -> Bool {
    #if os(macOS) || targetEnvironment(macCatalyst)
    !_CFMZEnabled()
    #else
    false
    #endif
}

extension CoreSystem {
    @inline(__always)
    package static var `default`: CoreSystem {
        #if canImport(Darwin)
        isAppKitBased() ? .appKit : .uiKit
        #else
        .unknown
        #endif
    }
}
