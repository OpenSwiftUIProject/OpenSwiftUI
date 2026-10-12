//
//  ButtonUtilities.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: 6C985860B64B768EC9A2691B5DBA71A0 (SwiftUI)

import OpenSwiftUICore

extension View {
    func buttonDefaultRenderingMode() -> some View {
        modifier(StaticIf(ShouldRenderAsTemplate.self, then: ButtonDefaultRenderingModeModifier()))
    }
}

// MARK: - ButtonDefaultRenderingModeModifier

private struct ButtonDefaultRenderingModeModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .environment(\.defaultRenderingMode, .template)
    }
}

// MARK: - ShouldRenderAsTemplate

private struct ShouldRenderAsTemplate: Feature {
    static var isEnabled: Bool {
        !isLinkedOnOrAfter(.v2)
    }
}
