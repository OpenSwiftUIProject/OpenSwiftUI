//
//  View_Font.swift
//  OpenSwiftUI
//
//  Audited for RELEASE_2021
//  Status: TODO

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

// TODO
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


extension View {
    @inlinable
    @inline(__always)
    public func font(_ font: Font?) -> some View {
        environment(\.font, font)
    }
}

extension View {
    @inline(__always)
    func defaultFont(_ font: Font?) -> some View {
        environment(\.defaultFont, font)
    }
}
