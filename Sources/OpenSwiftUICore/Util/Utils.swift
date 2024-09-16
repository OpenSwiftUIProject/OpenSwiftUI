//
//  Utils.swift
//  OpenSwiftUICore
//
//  Audited for RELEASE_2024
//  Status: WIP

internal import COpenSwiftUI

@inlinable
@inline(__always)
func asOptional<Value>(_ value: Value) -> Value? {
    func unwrap<T>() -> T { value as! T }
    let optionalValue: Value? = unwrap()
    return optionalValue
}

@inline(__always)
package func isCatalyst() -> Bool {
    #if os(iOS) || os(tvOS) || os(watchOS)
    false
    #elseif os(macOS)
    // NOTE: use runtime check instead of #if targetEnvironment(macCatalyst) here
    _CFMZEnabled()
    #else
    false
    #endif
}

@inline(__always)
package func isUIKitBased() -> Bool {
    #if os(iOS) || os(tvOS) || os(watchOS)
    true
    #elseif os(macOS)
    _CFMZEnabled()
    #else
    false
    #endif
}

@inline(__always)
package func isAppKitBased() -> Bool {
    #if os(iOS) || os(tvOS) || os(watchOS)
    false
    #elseif os(macOS)
    !_CFMZEnabled()
    #else
    false
    #endif
}
