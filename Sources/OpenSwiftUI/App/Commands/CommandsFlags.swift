//
//  CommandsFlags.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: 8CA450E42E2AFC68A9A1CEB51C79EBE5 (SwiftUI)

import OpenAttributeGraphShims
import OpenSwiftUICore

// MARK: - CommandFlag

struct CommandFlag {
    let id: Int

    init() {
        defer { Self.nextID &+= 1 }
        self.id = Self.nextID
    }

    private static var nextID: Int = 0

    static let printing: CommandFlag = CommandFlag()
}

// MARK: - WithCommandFlag

struct WithCommandFlag<Content>: PrimitiveCommands where Content: Commands {
    var flag: CommandFlag

    var content: Content

    static func _makeCommands(
        content: _GraphValue<Self>,
        inputs: _CommandsInputs
    ) -> _CommandsOutputs {
        var outputs = Content._makeCommands(
            content: content[offset: { .of(&$0.content) }],
            inputs: inputs
        )
        if inputs.preferences.contains(CommandsList.Key.self) {
            let setFlag = Attribute(
                SetFlag(
                    container: content.value,
                    list: .init(outputs.preferences[CommandsList.Key.self]),
                )
            )
            outputs.preferences[CommandsList.Key.self] = setFlag
        }
        return outputs
    }

    private struct SetFlag: Rule {
        @Attribute var container: WithCommandFlag
        @OptionalAttribute var list: CommandsList?

        var value: CommandsList {
            var list = list ?? .init(items: [])
            list.items.append(.init(value: .flag(container.flag), version: .init(forUpdate: ())))
            return list
        }
    }
}
