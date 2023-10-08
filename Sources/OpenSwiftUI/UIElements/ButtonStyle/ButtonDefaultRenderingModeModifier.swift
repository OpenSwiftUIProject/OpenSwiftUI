//
//  ButtonDefaultRenderingModeModifier.swift
//  OpenSwiftUI
//
//  Created by Kyle on 2023/9/24.
//  Lastest Version: iOS 15.5
//  Status: Complete
//  ID: 6C985860B64B768EC9A2691B5DBA71A0

@_implementationOnly import OpenSwiftUIShims

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
