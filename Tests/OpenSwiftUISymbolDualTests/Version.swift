//
//  Version.swift
//  OpenSwiftUISymbolDualTests

let isSwiftUIVersionAtLeast65AndBefore70: Bool = {
    guard #available(iOS 18.5, macOS 15.5, tvOS 18.5, watchOS 11.5, *) else {
        return false
    }
    guard #unavailable(iOS 26.0, macOS 26.0, tvOS 26.0, watchOS 26.0) else {
        return false
    }
    return true
}()
