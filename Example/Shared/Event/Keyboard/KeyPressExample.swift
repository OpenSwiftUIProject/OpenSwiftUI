//
//  KeyPressExample.swift
//  Shared

#if OPENSWIFTUI
import OpenSwiftUI
#else
import SwiftUI
#endif

struct KeyPressExample: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Keyboard actions")
                .font(.headline)
            Text("Use Tab and Shift-Tab to move focus between the panels.")
            Text("Press Space or Return to run an action. Hold Space to test key repeat.")
            Text("Press Escape to reset the focused panel's action count.")
            #if os(iOS) || os(visionOS)
            Text("Use a hardware keyboard for this example.")
            #endif

            HStack(alignment: .top, spacing: 16) {
                KeyPressPanel(title: "First panel")
                KeyPressPanel(title: "Second panel")
            }
        }
        .padding(24)
        .frame(maxWidth: 640)
    }
}

private struct KeyPressPanel: View {
    let title: String

    @State private var actionCount = 0
    @State private var downCount = 0
    @State private var repeatCount = 0
    @State private var upCount = 0
    @State private var lastEvent = "No key events"

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            KeyPressPanelLabel(title: title)
            Text("Actions: \(actionCount)")
            Text("Down: \(downCount)")
            Text("Repeat: \(repeatCount)")
            Text("Up: \(upCount)")
            Text("Last event: \(lastEvent)")
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.gray.opacity(0.1))
        .focusable()
        .onKeyPress(
            keys: [.space, .return, .escape],
            phases: [.down, .repeat, .up],
            action: handleKeyPress
        )
    }

    private func handleKeyPress(_ press: KeyPress) -> KeyPress.Result {
        let key: String
        switch press.key {
        case .space: key = "Space"
        case .return: key = "Return"
        case .escape: key = "Escape"
        default: return .ignored
        }
        lastEvent = "\(key) \(press.phase.debugDescription), modifiers: \(press.modifiers.rawValue)"
        switch press.phase {
        case .down:
            downCount += 1
            if press.key == .escape {
                actionCount = 0
            } else {
                actionCount += 1
            }
        case .repeat:
            repeatCount += 1
        case .up:
            upCount += 1
        default:
            break
        }
        return .handled
    }
}

private struct KeyPressPanelLabel: View {
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

#Preview {
    KeyPressExample()
}
