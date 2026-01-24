//
//  CommandsList.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: WIP

// MARK: - CommandsList
struct CommandsList {
    var items: [CommandsList.Item]
}

// MARK: - CommandsList.Item

extension CommandsList {
    struct Item {
        enum Value {
//            case operation(CommandOperation)
            case flag(CommandFlag)
        }

        var value: CommandsList.Item.Value
        var version: DisplayList.Version
    }
}

// MARK: - CommandsList.Key

extension CommandsList {
    struct Key: PreferenceKey {
        typealias Value = CommandsList

        static var defaultValue: CommandsList { .init(items: []) }

        static func reduce(value: inout CommandsList, nextValue: () -> CommandsList) {
            value.items.append(contentsOf: nextValue().items)
        }
    }
}
