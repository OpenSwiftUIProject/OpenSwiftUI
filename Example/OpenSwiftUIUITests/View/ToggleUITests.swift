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
        withKnownIssue(isIntermittent: true) {
            openSwiftUIAssertSnapshot(of: ContentView())
        }
        #else
        withKnownIssue("checkBox style is not supported yet") {
            openSwiftUIAssertSnapshot(of: ContentView())
        }
        #endif
    }

    @Test(.bug("https://github.com/OpenSwiftUIProject/OpenSwiftUI/issues/518", id: 518, "UIViewRepresentable size issue"))
    func emptyViewLabel() {
        struct ContentView: View {
            @State private var toggle = false

            var body: some View {
                VStack {
                    Toggle(isOn: $toggle) {
                        EmptyView()
                    }
                    Color.red
                }
                .padding()
                .background { Color.green }
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
