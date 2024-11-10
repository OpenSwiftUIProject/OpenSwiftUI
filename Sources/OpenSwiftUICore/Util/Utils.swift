//
//  Utils.swift
//  OpenSwiftUICore
//
//  Audited for iOS 18.0
//  Status: WIP

import OpenSwiftUI_SPI

@inlinable
@inline(__always)
func asOptional<Value>(_ value: Value) -> Value? {
    func unwrap<T>() -> T { value as! T }
    let optionalValue: Value? = unwrap()
    return optionalValue
}

#if canImport(Darwin)

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
    #else
    true
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

#endif
