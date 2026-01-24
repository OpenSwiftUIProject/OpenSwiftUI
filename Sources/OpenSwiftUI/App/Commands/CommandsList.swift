//
//  CommandsList.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Blocked by resolveOperations

// MARK: - CommandsList

struct CommandsList: Hashable {
    var items: [CommandsList.Item]

    var version: DisplayList.Version {
        var version = DisplayList.Version()
        for item in items {
            let newVersion = item.version
            version = newVersion >= version ? newVersion : version
        }
        return version
    }

    func resolveOperations(into resolvedCommands: inout _ResolvedCommands) {
        _openSwiftUIUnimplementedFailure()
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(version)
    }

    static func == (lhs: CommandsList, rhs: CommandsList) -> Bool {
        lhs.version == rhs.version
    }
}

// MARK: - CommandsList.Item

extension CommandsList {
    struct Item {
        enum Value {
            case operation(CommandOperation)
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
