//
//  SidebarSectionActionButtonStyle_Mac.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete

#if os(macOS)
import OpenSwiftUICore

struct SidebarSectionActionButtonStyle_Mac: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(minWidth: 12, minHeight: 12)
            .contentShape(Rectangle())
            .labelStyle(.iconOnly)
            .defaultForegroundStyle(
                configuration.isPressed
                    ? HierarchicalShapeStyle.secondary
                    : HierarchicalShapeStyle.tertiary
            )
            .help {
                configuration.label
            }
    }
}
#endif
