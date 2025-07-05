//
//  HVStackUITests.swift
//  OpenSwiftUIUITests

import Testing
import SnapshotTesting

@MainActor
@Suite(.snapshots(record: .never, diffTool: diffTool))
struct HVStackUITests {
    @Test
    func fixFrameForHStack() {
        struct ContentView: View {
            var body: some View {
                HStack {
                    Color.red.frame(width: 50, height: 50)
                    Color.blue.frame(width: 50, height: 50)
                }
                .frame(width: 150, height: 150)
                .background { Color.black }
            }
        }
        openSwiftUIAssertSnapshot(
            of: ContentView()
        )
    }

    @Test
    func fixFrameForVStack() {
        struct ContentView: View {
            var body: some View {
                VStack {
                    Color.red.frame(width: 50, height: 50)
                    Color.blue.frame(width: 50, height: 50)
                }
                .frame(width: 150, height: 150)
                .background { Color.black }
            }
        }
        openSwiftUIAssertSnapshot(
            of: ContentView()
        )
    }

    @Test
    func fixFrameForHVStack() {
        struct ContentView: View {
            var body: some View {
                VStack {
                    Color.red.frame(width: 40, height: 40)
                    Color.blue.frame(width: 40, height: 40)
                    HStack {
                        Color.green.frame(width: 40, height: 40)
                        Color.yellow.frame(width: 40, height: 40)
                    }
                }
                .frame(width: 150, height: 150)
                .background { Color.black }
            }
        }
        withKnownIssue("Spacing is not implemented") {
            openSwiftUIAssertSnapshot(
                of: ContentView()
            )
        }
    }

    @Test
    func fixElementForHVStack() {
        struct ContentView: View {
            var body: some View {
                VStack {
                    Color.red.frame(width: 40, height: 40)
                    Color.blue.frame(width: 40, height: 40)
                    HStack {
                        Color.green.frame(width: 40, height: 40)
                        Color.yellow.frame(width: 40, height: 40)
                    }
                }
                .background { Color.black }
            }
        }
        withKnownIssue("Spacing is not implemented") {
            openSwiftUIAssertSnapshot(
                of: ContentView()
            )
        }
    }

    @Test
    func equalSizeForHVStack() {
        struct ContentView: View {
            var body: some View {
                VStack {
                    Color.red
                    Color.blue
                    HStack {
                        Color.green
                        Color.yellow
                    }
                }
                .background { Color.black }
            }
        }
        withKnownIssue("Proposal implmentation is not correct") {
            openSwiftUIAssertSnapshot(
                of: ContentView()
            )
        }
    }

    @Test
    func layoutPriorityForHVStack() {
        struct ContentView: View {
            var body: some View {
                VStack {
                    Color.red
                    Color.blue.layoutPriority(1)
                    HStack {
                        Color.green
                        Color.yellow
                    }
                }
                .background { Color.black }
            }
        }
        withKnownIssue("Proposal implmentation is not correct") {
            openSwiftUIAssertSnapshot(
                of: ContentView()
            )
        }
    }
}
