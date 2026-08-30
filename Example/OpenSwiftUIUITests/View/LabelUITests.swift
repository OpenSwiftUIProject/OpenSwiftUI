//
//  LabelUITests.swift
//  OpenSwiftUIUITests

import SnapshotTesting
import Testing

@MainActor
@Suite(.snapshots(record: .never, diffTool: diffTool))
struct LabelUITests {
    @Test
    func builtInStyles() {
        struct ContentView: View {
            var body: some View {
                VStack(alignment: .leading, spacing: 12) {
                    Label {
                        Text("Automatic")
                    } icon: {
                        Color.red
                            .frame(width: 16, height: 16)
                    }
                    .labelStyle(.automatic)

                    Label {
                        Text("Icon only")
                    } icon: {
                        Color.green
                            .frame(width: 16, height: 16)
                    }
                    .labelStyle(.iconOnly)

                    Label {
                        Text("Title only")
                    } icon: {
                        Color.blue
                            .frame(width: 16, height: 16)
                    }
                    .labelStyle(.titleOnly)

                    Label {
                        Text("Title and icon")
                    } icon: {
                        Color.orange
                            .frame(width: 16, height: 16)
                    }
                    .labelStyle(.titleAndIcon)
                }
                .padding()
            }
        }

        openSwiftUIAssertSnapshot(of: ContentView())
    }
}
