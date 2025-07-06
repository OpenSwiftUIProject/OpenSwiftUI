//
//  HVStackUITests.swift
//  OpenSwiftUIUITests

import Testing
import SnapshotTesting

@MainActor
@Suite(.snapshots(record: .never, diffTool: diffTool))
struct HVStackUITests {
    // MARK: - Stack Frame + Element Frame

    @Test
    func stackFrameElementFrameHStack() {
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
    func stackFrameElementFrameVStack() {
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
    func stackFrameElementFrameHVStack() {
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
        openSwiftUIAssertSnapshot(
            of: ContentView()
        )
    }

    // MARK: - Element Frame

    @Test
    func elementFrameHVStack() {
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
        openSwiftUIAssertSnapshot(
            of: ContentView()
        )
    }

    @Test
    func elementFrameSpacingHVStack() {
        struct ContentView: View {
            var body: some View {
                VStack(spacing: 20) {
                    Color.red.frame(width: 40, height: 40)
                    Color.blue.frame(width: 40, height: 40)
                    HStack(spacing: 30) {
                        Color.green.frame(width: 40, height: 40)
                        Color.yellow.frame(width: 40, height: 40)
                    }
                }
                .background { Color.black }
            }
        }
        openSwiftUIAssertSnapshot(
            of: ContentView()
        )
    }

    @Test
    func elementFrameAlignmentHVStack() {
        struct ContentView: View {
            var body: some View {
                VStack(alignment: .leading) {
                    Color.red.frame(width: 30, height: 30)
                    Color.blue.frame(width: 40, height: 40)
                    HStack(alignment: .top) {
                        Color.green.frame(width: 50, height: 50)
                        Color.yellow.frame(width: 60, height: 60)
                    }
                }
                .background { Color.black }
            }
        }
        openSwiftUIAssertSnapshot(
            of: ContentView()
        )
    }

    // MARK: - No frame constraint

    @Test
    func defaultHVStack() {
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
        openSwiftUIAssertSnapshot(
            of: ContentView()
        )
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
        withKnownIssue("layoutPriority is not implemented for HVStack yet") {
            openSwiftUIAssertSnapshot(
                of: ContentView()
            )
        }
    }
}
