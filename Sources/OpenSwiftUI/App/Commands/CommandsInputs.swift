//
//  CommandsInputs.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete

import OpenAttributeGraphShims
package import OpenSwiftUICore

// MARK: - _CommandsInputs

/// Inputs used for creating attributes of a Commands hierarchy.
@available(OpenSwiftUI_v2_0, *)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
public struct _CommandsInputs {
    package var base: _GraphInputs
    package var preferences: PreferencesInputs

    package mutating func copyCaches() {
        base.copyCaches()
    }
}

@available(*, unavailable)
extension _CommandsInputs: Sendable {}

// MARK: - _CommandsOutputs

/// Outputs used for storing preference values from a Commands hierarchy.
@available(OpenSwiftUI_v2_0, *)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
public struct _CommandsOutputs {
    package var preferences: PreferencesOutputs

    package init() {
        preferences = .init()
    }

    package init(preferences: PreferencesOutputs) {
        self.preferences = preferences
    }
}

@available(*, unavailable)
extension _CommandsOutputs: Sendable {}
