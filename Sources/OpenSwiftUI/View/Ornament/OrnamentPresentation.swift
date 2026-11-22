//
//  OrnamentPresentation.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: WIP
//  ID: BA67D9C96127B7B4431665E04B813A80 (SwiftUI)

#if os(visionOS)
public import OpenSwiftUICore

// MARK: - EnvironmentValues + isInOrnament

extension EnvironmentValues {
    @_spi(UIFrameworks)
    @available(OpenSwiftUI_v5_0, *)
    @available(iOS, unavailable)
    @available(macOS, unavailable)
    @available(watchOS, unavailable)
    @available(tvOS, unavailable)
    public var isInOrnament: Bool {
        get { self[IsInOrnamentKey.self] }
        set { self[IsInOrnamentKey.self] = newValue }
    }

    private struct IsInOrnamentKey: EnvironmentKey {
        static let defaultValue = false
    }
}
#endif
