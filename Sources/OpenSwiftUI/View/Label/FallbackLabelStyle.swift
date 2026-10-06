//
//  FallbackLabelStyle.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: 5F7CFEF27A8C84D7109190C998A5AF5F (SwiftUI)

import OpenSwiftUICore

// MARK: - FallbackLabelStyle

struct FallbackLabelStyle: LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
        StaticIf(ButtonContainerIsBorderedInput.self) {
            ResolvedFallbackLabel(configuration: configuration)
        } else: {
            Label(configuration)
                .labelStyle(.titleAndIcon)
        }
    }
}

// MARK: - ResolvedFallbackLabel

private struct ResolvedFallbackLabel: View {
    @Environment(\.buttonBorderShape)
    private var buttonShape: ButtonBorderShape

    let configuration: LabelStyleConfiguration

    var body: some View {
        if buttonShape == .circle {
            Label(configuration)
                .labelStyle(.iconOnly)
        } else {
            Label(configuration)
                .labelStyle(.titleAndIcon)
        }
    }
}
