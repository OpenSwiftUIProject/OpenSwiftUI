//
//  Utils.swift
//  OpenSwiftUICore
//
//  Audited for RELEASE_2024
//  Status: WIP

internal import COpenSwiftUICore

@inlinable
@inline(__always)
func asOptional<Value>(_ value: Value) -> Value? {
    func unwrap<T>() -> T { value as! T }
    let optionalValue: Value? = unwrap()
    return optionalValue
}

#if canImport(Darwin)

// NOTE: use runtime check instead of #if targetEnvironment(macCatalyst) here
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
