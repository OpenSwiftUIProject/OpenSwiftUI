//
//  ToggleUITests.swift
//  OpenSwiftUIUITests

import Testing
import SnapshotTesting

@MainActor
@Suite(.snapshots(record: .never, diffTool: diffTool))
struct ToggleUITests {
    @Test
    func onAndOffWithDefaultStyle() {
        struct ContentView: View {
            var body: some View {
                VStack {
                    Toggle(isOn: .constant(true)) { Color.green }
                    Toggle(isOn: .constant(false)) { Color.red }
                }
            }
        }
        #if os(iOS) || os(visionOS)
        openSwiftUIAssertSnapshot(of: ContentView())
        #else
        withKnownIssue("checkBox style is not supported yet") {
            openSwiftUIAssertSnapshot(of: ContentView())
        }
        #endif
    }
}
