//
//  DefaultPaddingUITests.swift
//  OpenSwiftUIUITests

import SnapshotTesting
import Testing

@MainActor
@Suite(.snapshots(record: .never, diffTool: diffTool))
struct DefaultPaddingUITests {
    // MARK: - Basic Padding

    @Test
    func defaultAutomaticPadding() {
        struct ContentView: View {
            var body: some View {
                Color.red
                    ._automaticPadding()
                    .background(Color.blue)
            }
        }
        openSwiftUIAssertSnapshot(of: ContentView())
    }

    @Test
    func customAutomaticPadding() {
        struct ContentView: View {
            var body: some View {
                Color.red
                    ._automaticPadding(
                        .init(
                            top: 20,
                            leading: 20,
                            bottom: 20,
                            trailing: 20
                        )
                    )
                    .background(Color.blue)
            }
        }
        openSwiftUIAssertSnapshot(of: ContentView())
    }

    @Test
    func mixAutomaticPadding() {
        struct ContentView: View {
            var body: some View {
                VStack {
                    Color.red
                        ._automaticPadding()
                    Color.green
                        ._automaticPadding()
                        ._ignoresAutomaticPadding(false)
                    Color.blue
                        ._automaticPadding()
                        ._ignoresAutomaticPadding(true)
                }
                .background(Color.yellow)
            }
        }
        openSwiftUIAssertSnapshot(of: ContentView())
    }
}
