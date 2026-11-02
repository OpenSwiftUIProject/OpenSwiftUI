//
//  ResponderCommandPreferenceExample.swift
//  Shared

#if os(macOS)
import AppKit

#if OPENSWIFTUI
import OpenSwiftUI
#else
import SwiftUI
#endif

private let resetCommandSelector = NSSelectorFromString("openswiftui_exampleReset:")

struct ResponderCommandPreferenceExample: View {
    @State private var secondPanelEnabled = true

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Responder commands")
                .font(.headline)
            Text("Use Tab and Shift-Tab to move focus between the panels.")
            Text("Arrow keys move the focused panel. Escape resets its position and move count.")
            Text("Open Commands to reset the focused panel through the menu.")

            Toggle("Enable second panel commands", isOn: $secondPanelEnabled)

            HStack(alignment: .top, spacing: 16) {
                ResponderCommandPanel(title: "First panel", isEnabled: true)
                ResponderCommandPanel(title: "Second panel", isEnabled: secondPanelEnabled)
            }

            ResponderCommandMenu()
                .frame(width: 200, height: 28)
            Text("When commands are off, the second panel does not move or reset, and its menu item is disabled.")
        }
        .padding(24)
        .frame(maxWidth: 680)
    }
}

private struct ResponderCommandPanel: View {
    let title: String
    let isEnabled: Bool

    @State private var x = 0
    @State private var y = 0
    @State private var moveCount = 0
    @State private var resetCount = 0
    @State private var lastCommand = "None"

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ResponderCommandPanelLabel(title: title)
            Text(isEnabled ? "Commands: On" : "Commands: Off")
            Text("Position: (\(x), \(y))")
            Text("Moves: \(moveCount)")
            Text("Resets: \(resetCount)")
            Text("Last command: \(lastCommand)")
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.gray.opacity(0.1))
        .focusable()
        .onMoveCommand(perform: isEnabled ? move : nil)
        .onCommand(
            #selector(NSResponder.cancelOperation(_:)),
            perform: isEnabled ? { reset("Escape") } : nil
        )
        .onCommand(
            resetCommandSelector,
            perform: isEnabled ? { reset("Menu reset") } : nil
        )
    }

    private func move(_ direction: MoveCommandDirection) {
        switch direction {
        case .up:
            y += 1
            lastCommand = "Up"
        case .down:
            y -= 1
            lastCommand = "Down"
        case .left:
            x -= 1
            lastCommand = "Left"
        case .right:
            x += 1
            lastCommand = "Right"
        @unknown default:
            return
        }
        moveCount += 1
    }

    private func reset(_ source: String) {
        x = 0
        y = 0
        moveCount = 0
        resetCount += 1
        lastCommand = source
    }
}

private struct ResponderCommandPanelLabel: View {
    @Environment(\.isFocused) private var isFocused

    let title: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.headline)
            Text(isFocused ? "Focused" : "Not focused")
                .foregroundColor(isFocused ? .blue : .gray)
        }
    }
}

private struct ResponderCommandMenu: NSViewRepresentable {
    func makeNSView(context: Context) -> NSPopUpButton {
        let button = NSPopUpButton(frame: .zero, pullsDown: true)
        // Keep the command panel focused while the menu is open.
        button.refusesFirstResponder = true
        let menu = NSMenu()
        menu.autoenablesItems = true
        menu.addItem(withTitle: "Commands", action: nil, keyEquivalent: "")
        let resetItem = menu.addItem(
            withTitle: "Reset focused panel",
            action: resetCommandSelector,
            keyEquivalent: ""
        )
        // Let AppKit validate and dispatch through the responder chain.
        resetItem.target = nil
        button.menu = menu
        return button
    }

    func updateNSView(_ nsView: NSPopUpButton, context: Context) {}
}

#Preview {
    ResponderCommandPreferenceExample()
}
#endif
