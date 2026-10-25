//
//  TextSelectionExample.swift
//  Shared

#if OPENSWIFTUI
import OpenSwiftUI
#else
import SwiftUI
#endif

struct TextSelectionExample: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Default: text selection is disabled.")

            Text("Enabled: select and copy this text.")
                .textSelection(.enabled)

            Text("Disabled: this text is not selectable.")
                .textSelection(.disabled)

            VStack(alignment: .leading, spacing: 8) {
                Text("This text inherits enabled selection.")
                Text("This child disables selection.")
                    .textSelection(.disabled)
            }
            .textSelection(.enabled)

            VStack(alignment: .leading, spacing: 8) {
                Text("This text inherits disabled selection.")
                Text("This child enables selection.")
                    .textSelection(.enabled)
            }
            .textSelection(.disabled)
        }
        .frame(width: 300, alignment: .leading)
        .padding()
    }
}

struct TextSelectionLayoutExample: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Select words across several lines of text. The selection should follow the text as it wraps within this narrow column.")

            Text("This selectable single line has enough text to truncate in the middle.")
                .lineLimit(1)
                .truncationMode(.middle)

            Text("Right-aligned selectable text\non a second line.")
                .multilineTextAlignment(.trailing)
                .frame(maxWidth: .infinity, alignment: .trailing)

            Text("Select **bold** and *italic* text, or open [OpenSwiftUI](https://github.com/OpenSwiftUIProject/OpenSwiftUI).")
        }
        .textSelection(.enabled)
        .frame(width: 300, alignment: .leading)
        .padding()
    }
}

struct TextSelectionUpdateExample: View {
    @State private var selectionEnabled = true
    @State private var showsAlternateText = false

    private var text: Text {
        Text(showsAlternateText
             ? "The text has changed. Select a new range in this longer sentence."
             : "Select this text, then change it.")
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Toggle("Allow selection", isOn: $selectionEnabled)
            Button("Change text") {
                showsAlternateText.toggle()
            }
            if selectionEnabled {
                text.textSelection(.enabled)
            } else {
                text.textSelection(.disabled)
            }
        }
        .frame(width: 300, alignment: .leading)
        .padding()
    }
}

#Preview("TextSelectionExample") {
    TextSelectionExample()
}

#Preview("TextSelectionLayoutExample") {
    TextSelectionLayoutExample()
}

#Preview("TextSelectionUpdateExample") {
    TextSelectionUpdateExample()
}
