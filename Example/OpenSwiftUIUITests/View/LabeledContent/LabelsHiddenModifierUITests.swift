//
//  LabelsHiddenModifierUITests.swift
//  OpenSwiftUIUITests

import Testing
import SnapshotTesting

@MainActor
@Suite(
    .disabled(if: attributeGraphVendor == .compute, "Temporarily disabled for Compute snapshot stack overflow. See https://github.com/jcmosc/Compute/issues/47"),
    .snapshots(record: .never, diffTool: diffTool)
)
struct LabelsHiddenModifierUITests {
    @Test
    func toggleLabelsHidden() {
        struct ContentView: View {
            @State private var toggle1 = false
            @State private var toggle2 = false
            var body: some View {
                VStack {
                    Toggle(isOn: $toggle1) {
                        // Text("Toggle 1")
                        Color.red
                    }
                    .labelsHidden()
                    Toggle(isOn: $toggle2) {
                        // Text("Toggle 2")
                        Color.blue
                    }
                }
            }
        }
        #if os(iOS) || os(visionOS)
        withKnownIssue(isIntermittent: true) {
            openSwiftUIAssertSnapshot(of: ContentView())
        }
        #else
        withKnownIssue("checkBox style is not supported yet") {
            openSwiftUIAssertSnapshot(of: ContentView())
        }
        #endif
    }
}
