//
//  PhoneIdiomGroupBoxStyle.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete

@_spi(ForOpenSwiftUIOnly)
import OpenSwiftUICore

struct PhoneIdiomGroupBoxStyle: GroupBoxStyle {
    @Environment(\.disableGroupBoxPadding)
    private var disablePadding

    func makeBody(configuration: Configuration) -> some View {
        VStack {
            configuration.label
                .modifier(_AlignmentLayout(horizontal: .leading))
                .font(.headline)
            configuration.content
        }
        .padding(disablePadding ? [] : .all)
        .background(in: RoundedRectangle(cornerRadius: 8, style: .continuous))
        .styleContext(.container)
        .spacing(Spacing())
    }
}
