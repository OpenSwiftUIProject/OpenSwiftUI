//
//  GroupBoxExample.swift
//  Shared

#if OPENSWIFTUI
import OpenSwiftUI
#else
import SwiftUI
#endif

struct GroupBoxExample: View {
    @State private var userAgreed: Bool

    init(userAgreed: Bool = false) {
        _userAgreed = State(initialValue: userAgreed)
    }

    var body: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 12) {
                // TODO: Place the terms in a ScrollView when OpenSwiftUI supports it.
                Text("Use this sample for evaluation. Keep a copy of the terms for your records.")
                    .font(.footnote)
                Toggle("I agree to the above terms", isOn: $userAgreed)
            }
        } label: {
            Label("End-User Agreement", systemImage: "building.columns")
        }
        .padding()
    }
}

struct GroupBoxStyleExample: View {
    var body: some View {
        VStack(spacing: 12) {
            GroupBox("Account status") {
                Text("Ready")
            }
            GroupBox {
                Text("Notifications are enabled.")
            }
        }
        .groupBoxStyle(SummaryGroupBoxStyle())
        .padding()
    }
}

private struct SummaryGroupBoxStyle: GroupBoxStyle {
    func makeBody(configuration: Configuration) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            configuration.label
                .font(.headline)
            configuration.content
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(Color.blue.opacity(0.12), in: RoundedRectangle(cornerRadius: 8))
    }
}

#Preview("End-User Agreement") {
    GroupBoxExample()
}

#Preview("Custom GroupBox Style") {
    GroupBoxStyleExample()
}
