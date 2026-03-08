//
//  DefaultDividerStyle.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete

// MARK: - DefaultDividerStyle

extension DividerStyle where Self == DefaultDividerStyle {
    static var `default`: DefaultDividerStyle {
        .init()
    }
}

struct DefaultDividerStyle: DividerStyle {
    func makeBody(configuration: Configuration) -> some View {
        Divider().dividerStyle(.plain)
    }
}
