//
//  TextSelectionInteractionTests.swift
//  OpenSwiftUIInteractionTests

#if os(macOS)
#if OPENSWIFTUI
import OpenSwiftUI
#else
import SwiftUI
#endif
import Testing

@MainActor
@Suite(.serialized, .tags(.interaction))
struct TextSelectionInteractionTests {
    enum Selectability: CaseIterable {
        case defaultSelection
        case enabled
        case disabled
        case inheritedEnabled
        case inheritedDisabled
        case disabledChild
        case enabledChild

        var allowsSelection: Bool {
            switch self {
            case .enabled, .inheritedEnabled, .enabledChild: true
            default: false
            }
        }
    }

    @Test(arguments: Selectability.allCases)
    func doubleClickRespectsSelectability(_ selectability: Selectability) async throws {
        let content = ContentView(selectability: selectability)
        try await withInteractionTestHost(of: content) { host in
            #expect(host.selectedText == nil)
            try await host.tap(count: 2)
            if selectability.allowsSelection {
                try await host.waitUntil(host.selectedText == "Selection")
                #expect(host.selectedText == "Selection")
            } else {
                #expect(host.selectedText == nil)
            }
        }
    }

    private struct ContentView: View {
        var selectability: Selectability

        private var text: some View {
            Text("Selection")
                .font(.system(size: 24))
        }

        @ViewBuilder
        var body: some View {
            switch selectability {
            case .defaultSelection:
                text
            case .enabled:
                text.textSelection(.enabled)
            case .disabled:
                text.textSelection(.disabled)
            case .inheritedEnabled:
                VStack { text }.textSelection(.enabled)
            case .inheritedDisabled:
                VStack { text }.textSelection(.disabled)
            case .disabledChild:
                VStack { text.textSelection(.disabled) }.textSelection(.enabled)
            case .enabledChild:
                VStack { text.textSelection(.enabled) }.textSelection(.disabled)
            }
        }
    }
}
#endif
