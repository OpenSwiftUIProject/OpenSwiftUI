//
//  EnvironmentValues.swift
//  OpenSwiftUI
//
//  Created by Kyle on 2023/9/22.
//  Lastest Version: iOS 15.5
//  Status: Empty
//  ID: CEAC6A812C645DD28AF9055EFDEFFB46

// MARK: - EnvironmentValues
public struct EnvironmentValues: CustomStringConvertible {
    public init() {}

    // FIXME:
    public subscript<K>(_: K.Type) -> K.Value where K: EnvironmentKey {
        get {
            K.defaultValue
        }
        set {}
    }

    public var description: String { "" }

    //    var _plist: PropertyList
    //    let tracker: PropertyList.Tracker?
}

// MARK: - Font
private struct FontKey: EnvironmentKey {
    static var defaultValue: Font? { nil }
}

private struct DefaultFontKey: EnvironmentKey {
    typealias Value = Font?
    static var defaultValue: Font? { nil }
}

private struct EffectiveFontKey: DerivedEnvironmentKey {
    typealias Value = Font

    static func value(in environment: EnvironmentValues) -> Font {
        environment.font ?? environment.defaultFont ?? .body
    }
}

extension EnvironmentValues {
    @inline(__always)
    public var font: Font? {
        get { self[FontKey.self] }
        set { self[FontKey.self] = newValue }
    }

    @inline(__always)
    var defaultFont: Font? {
        get { self[DefaultFontKey.self] }
        set { self[DefaultFontKey.self] = newValue }
    }

    @inline(__always)
    var effectiveFont: Font {
        EffectiveFontKey.value(in: self)
    }
}
