//
//  DefaultFocus.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: WIP
//  ID: 1F8B69996BE941D510140AD6558D8844 (SwiftUI)

import OpenAttributeGraphShims
@_spi(ForOpenSwiftUIOnly)
import OpenSwiftUICore

// MARK: - FocusScopesKey

struct FocusScopesKey: EnvironmentKey {
    static var defaultValue: [Namespace.ID] { [] }
}

extension CachedEnvironment.ID {
    fileprivate static let focusScopes: CachedEnvironment.ID = .init()
}

extension _GraphInputs {
    var focusScopes: Attribute<[Namespace.ID]> {
        mapEnvironment(id: .focusScopes) { $0[FocusScopesKey.self] }
    }
}
