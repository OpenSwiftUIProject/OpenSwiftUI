//
//  CommandGroup.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: B3A3F592E699B55425F5A5625DAFF2C0 (SwiftUI)

import Foundation
import OpenAttributeGraphShims
import OpenSwiftUICore

// MARK: - CommandGroup

@available(OpenSwiftUI_v2_0, *)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
struct CommandGroup<Content>: Commands where Content: View {
    var change: CommandOperation

    init(
        after placement: CommandGroupPlacement,
        @ViewBuilder addition: () -> Content
    ) {
        change = CommandOperation(
            mutation: .append,
            placement: placement,
            content: addition()
        )
    }

    init(
        before placement: CommandGroupPlacement,
        @ViewBuilder addition: () -> Content
    ) {
        change = CommandOperation(
            mutation: .prepend,
            placement: placement,
            content: addition()
        )
    }

    init(
        replacing placement: CommandGroupPlacement,
        @ViewBuilder addition: () -> Content
    ) {
        change = CommandOperation(
            mutation: .replace,
            placement: placement,
            content: addition()
        )
    }

    var body: some Commands {
        _openSwiftUIUnimplementedFailure()
    }

    func _resolve(
        into resolved: inout _ResolvedCommands
    ) {
        if let resolver = change.resolver {
            resolver(change, &resolved)
        }
    }

    nonisolated static func _makeCommands(
        content: _GraphValue<Self>,
        inputs: _CommandsInputs
    ) -> _CommandsOutputs {
        var outputs = PreferencesOutputs()
        outputs.makePreferenceWriter(
            inputs: inputs.preferences,
            key: CommandsList.Key.self,
            value: Attribute(MakeList(commandGroup: content.value))
        )
        _openSwiftUIUnimplementedFailure()
    }

    private struct MakeList: Rule {
        @Attribute var commandGroup: CommandGroup

        var value: CommandsList {
            CommandsList(
                items: [
                    .init(
                        value: .operation(commandGroup.change),
                        version: DisplayList.Version(forUpdate: ())
                    ),
                ]
            )
        }
    }
}

@available(*, unavailable)
extension CommandGroup: Sendable {}

// MARK: - CommandGroupPlacement

@available(OpenSwiftUI_v2_0, *)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
struct CommandGroupPlacement {
    let name: Text
    let id: UUID

    init(_ text: String) {
        let name = Text(verbatim: text)
        name.assertUnstyled()
        self.name = name
        self.id = UUID()
    }

    static let appInfo = CommandGroupPlacement("App Info")
    static let appSettings = CommandGroupPlacement("App Settings")
    static let systemServices = CommandGroupPlacement("System Services")
    static let appVisibility = CommandGroupPlacement("App Visibility")
    static let appTermination = CommandGroupPlacement("App Termination")
    static let newItem = CommandGroupPlacement("New Item")
    static let saveItem = CommandGroupPlacement("Save Item")
    static let importExport = CommandGroupPlacement("Import/Export Item")
    static let printItem = CommandGroupPlacement("Print Item")
    static let undoRedo = CommandGroupPlacement("Undo/Redo")
    static let pasteboard = CommandGroupPlacement("Pasteboard")
    static let textEditing = CommandGroupPlacement("Text Editing")
    static let textFormatting = CommandGroupPlacement("Text Formatting")
    static let toolbar = CommandGroupPlacement("Toolbar")
    static let sidebar = CommandGroupPlacement("Sidebar")
    static let windowSize = CommandGroupPlacement("Window Size")
    static let windowList = CommandGroupPlacement("Window List")
    static let windowArrangement = CommandGroupPlacement("Window Arrangement")
    static let help = CommandGroupPlacement("Help")

    @available(iOS, unavailable)
    static let appShortcuts = CommandGroupPlacement("App Shortcuts")

    @available(iOS, unavailable)
    static let singleWindowList: CommandGroupPlacement = CommandGroupPlacement("Singleton Window List")
}

// MARK: - CommandGroupPlacementBox

struct CommandGroupPlacementBox: Hashable {
    var placement: CommandGroupPlacement

    func hash(into hasher: inout Hasher) {
        hasher.combine(placement.id)
    }

    static func == (lhs: CommandGroupPlacementBox, rhs: CommandGroupPlacementBox) -> Bool {
        lhs.placement.id == rhs.placement.id
    }
}
