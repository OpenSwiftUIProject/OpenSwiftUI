//
//  WidgetLinkButtonStyle.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete

import OpenSwiftUICore

struct WidgetLinkButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .modifier(OpacityButtonHighlightModifier(highlighted: configuration.isPressed))
            .contentShape(Rectangle())
    }
}
