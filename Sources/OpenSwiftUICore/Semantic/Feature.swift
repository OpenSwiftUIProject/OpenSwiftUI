//
//  Feature.swift
//  OpenSwiftUICore
//
//  Audited for 6.0.87
//  Status: Complete

package import Foundation

package protocol Feature: ViewInputBoolFlag {
    static var isEnabled: Bool { get }
}

extension Feature {
    @inlinable
    package static var defaultValue: Bool { isEnabled }
}

package protocol UserDefaultKeyedFeature: Feature {
    static var key: String { get }

    static var defaultFeatureValue: Bool { get }

    #if !os(WASI)
    static var defaults: UserDefaults { get }
    #endif

    static var cachedValue: Bool? { get set }
}

extension UserDefaultKeyedFeature {
    package static var isEnabled: Bool {
        if let cachedValue {
            return cachedValue
        } else {
            #if os(WASI)
            cachedValue = defaultFeatureValue
            return defaultFeatureValue
            #else
            if defaults.object(forKey: key) != nil {
                let enable = defaults.bool(forKey: key)
                cachedValue = enable
                return enable
            } else {
                cachedValue = defaultFeatureValue
                return defaultFeatureValue
            }
            #endif
        }
    }
    
    package static var defaultFeatureValue: Bool { false }

    #if !os(WASI)
    package static var defaults: UserDefaults { .standard }
    #endif
}

extension UserDefaultKeyedFeature {
    package static func test<R>(enabled: Bool, _ body: () throws -> R) rethrows -> R {
        let oldCache = cachedValue
        cachedValue = enabled
        defer { cachedValue = oldCache }
        return try body()
    }
}

package struct BothFeatures<Left, Right>: Feature where Left: Feature, Right: Feature {
    @inlinable
    package init() {}
    
    @inlinable
    package static var isEnabled: Bool {
        Left.isEnabled && Right.isEnabled
    }
}
