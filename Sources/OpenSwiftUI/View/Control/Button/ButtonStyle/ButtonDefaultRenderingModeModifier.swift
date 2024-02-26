//
//  ButtonDefaultRenderingModeModifier.swift
//  OpenSwiftUI
//
//  Audited for RELEASE_2021
//  Status: Complete
//  ID: 6C985860B64B768EC9A2691B5DBA71A0

internal import COpenSwiftUI

extension View {
    func buttonDefaultRenderingMode() -> some View {
        EmptyView()
            .modifier(StaticIf(ShouldRenderAsTemplate.self, then: ButtonDefaultRenderingModeModifier()))
    }
}

private struct ButtonDefaultRenderingModeModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
//            .environment(\.defaultRenderingMode, .template)
    }
}

private struct ShouldRenderAsTemplate: Feature {
    static var isEnable: Bool {
        let semantics = Semantics.v2
        if let forced = Semantics.forced {
            return forced >= semantics
        } else {
            return dyld_program_sdk_at_least(.init(semantics: semantics))
        }
    }
}
