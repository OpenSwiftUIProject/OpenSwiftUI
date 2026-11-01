//
//  ContainerBackgroundKind.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete

// MARK: - ContainerBackgroundKind

package enum ContainerBackgroundKind: Hashable {
    package enum Builtin: Hashable, CaseIterable {
        case navigation
        case navigationSplitView
        case tabView
        case presentation
        case window
    }

    case builtin(Builtin)
    case custom

    struct Key: EnvironmentKey {
        static let defaultValue: ContainerBackgroundKind? = nil
    }
}

extension EnvironmentValues {
    package var containerBackgroundKind: ContainerBackgroundKind? {
        get { self[ContainerBackgroundKind.Key.self] }
        set { self[ContainerBackgroundKind.Key.self] = newValue }
    }
}
