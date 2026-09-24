//
//  FocusEffectDelegate.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: WIP
//  ID: 8C909BE7747C720C6B9D560863FD7609 (SwiftUI)

#if os(macOS)
import OpenAttributeGraphShims
import OpenSwiftUICore

// MARK: - EnvironmentValues + Focus Effect Delegation

extension EnvironmentValues {
    var delegatesFocusEffect: Bool {
        get { self[DelegatesFocusEffectKey.self] }
        set { self[DelegatesFocusEffectKey.self] = newValue }
    }
}

private struct DelegatesFocusEffectKey: EnvironmentKey {
    static var defaultValue: Bool { false }
}

extension CachedEnvironment.ID {
    fileprivate static let delegatesFocusEffect: CachedEnvironment.ID = .init()
}

extension _GraphInputs {
    var delegatesFocusEffect: Attribute<Bool> {
        mapEnvironment(id: .delegatesFocusEffect) { $0.delegatesFocusEffect }
    }
}
#endif
