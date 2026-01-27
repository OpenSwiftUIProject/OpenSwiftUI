//
//  ToolbarTitleDisplayMode.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete

// MARK: - ToolbarTitleDisplayMode

package struct ToolbarTitleDisplayMode: Equatable {
    enum Role {
        case automatic
        case large
        case inlineLarge
        case inline
        case settings
    }

    package var role: ToolbarTitleDisplayMode.Role

    package init(role: ToolbarTitleDisplayMode.Role) {
        self.role = role
    }

    package static let automatic: ToolbarTitleDisplayMode = .init(role: .automatic)

    package static let large: ToolbarTitleDisplayMode = .init(role: .large)

    package static let inlineLarge: ToolbarTitleDisplayMode = .init(role: .inlineLarge)

    package static let inline: ToolbarTitleDisplayMode = .init(role: .inline)
}