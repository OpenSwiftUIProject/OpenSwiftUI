//
//  CommandsList.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete

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

    func resolveOperations(into resolved: inout _ResolvedCommands) {
        for item in items {
            switch item.value {
            case let .operation(operation):
                if let resolver = operation.resolver {
                    resolver(operation, &resolved)
                }
            case let .flag(flag):
                resolved.flags.insert(flag)
            }
        }
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
