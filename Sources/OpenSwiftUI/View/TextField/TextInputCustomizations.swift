//
//  TextFieldInputModifiers.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: WIP
//  ID: 358223D01E778F87FED5B25B5CFE864D (SwiftUI?)

public import OpenSwiftUICore

// MARK: - View + Text Field Scrolling

extension View {
    @_spi(Private)
    @available(OpenSwiftUI_v3_4, *)
    @available(iOS, unavailable)
    @available(tvOS, unavailable)
    @available(watchOS, unavailable)
    nonisolated public func textFieldScrollingDisabled(_ scrollDisabled: Bool = true) -> some View {
        #if os(macOS)
        environment(\.textFieldIsScrollable, !scrollDisabled)
        #else
        _openSwiftUIUnreachableCode()
        #endif
    }
}

#if os(macOS)
// MARK: - TextFieldIsScrollableKey

private struct TextFieldIsScrollableKey: EnvironmentKey {
    static let defaultValue = true
}

extension EnvironmentValues {
    var textFieldIsScrollable: Bool {
        get { self[TextFieldIsScrollableKey.self] }
        set { self[TextFieldIsScrollableKey.self] = newValue }
    }
}
#endif
