//
//  Text+AlwaysOn.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: F24B13C37D4990A93C622BFF14CD564A (SwiftUICore)

package import OpenAttributeGraphShims

package protocol TextAlwaysOnProvider {
    static func makeAlwaysOn(
        inputs: _ViewInputs,
        schedule: @autoclosure () -> Attribute<(any TimelineSchedule)?>,
        outputs: inout _ViewOutputs
    )
}

extension _ViewInputs {
    package var textAlwaysOnProvider: (any TextAlwaysOnProvider.Type)? {
        get { base.textAlwaysOnProvider }
        set { base.textAlwaysOnProvider = newValue }
    }
}

extension _GraphInputs {
    private struct TextAlwaysOnProviderKey: GraphInput {
        static var defaultValue: (any TextAlwaysOnProvider.Type)? { nil }
    }

    package var textAlwaysOnProvider: (any TextAlwaysOnProvider.Type)? {
        get { self[TextAlwaysOnProviderKey.self] }
        set { self[TextAlwaysOnProviderKey.self] = newValue }
    }
}
