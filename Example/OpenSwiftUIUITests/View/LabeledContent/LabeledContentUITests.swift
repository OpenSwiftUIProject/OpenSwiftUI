//
//  LabeledContentUITests.swift
//  OpenSwiftUIUITests

import Testing
import SnapshotTesting

@MainActor
@Suite(.snapshots(record: .never, diffTool: diffTool))
struct LabeledContentUITests {
    @Test
    func defaultStyle() {
        struct ContentView: View {
            var body: some View {
                LabeledContent {
                    Color.red
                } label: {
                    Color.blue
                }

            }
        }
        openSwiftUIAssertSnapshot(of: ContentView())
    }

    @Test
    func customStyle() {
        struct CustomStyle: LabeledContentStyle {
            func makeBody(configuration: Configuration) -> some View {
                VStack(spacing: 0) {
                    configuration.label
                    configuration.content
                }
            }
        }
        struct ContentView: View {
            var body: some View {
                LabeledContent {
                    Color.red
                } label: {
                    Color.blue
                }.labeledContentStyle(CustomStyle())
            }
        }
        openSwiftUIAssertSnapshot(of: ContentView())
    }
}
