//
//  FrameLayoutUITests.swift
//  OpenSwiftUIUITests

import Testing
import SnapshotTesting

@MainActor
@Suite(.snapshots(record: .never, diffTool: diffTool))
struct FrameLayoutUITests {
    @Test
    func noFrame() {
        struct ContentView: View {
            var body: some View {
                Color.red.frame()
            }
        }
        openSwiftUIAssertSnapshot(of: ContentView())
    }

    @Test
    func frameSize() {
        struct ContentView: View {
            var body: some View {
                Color.red.frame(width: 50, height: 50)
            }
        }
        openSwiftUIAssertSnapshot(of: ContentView())
    }

    @Test
    func flexFrameMax() {
        struct ContentView: View {
            var body: some View {
                VStack {
                    VStack(alignment: .leading) {
                        Color.red.frame(maxWidth: 50, maxHeight: 50)
                        Color.green.frame(maxWidth: 40, maxHeight: 30)
                        Color.blue.frame(maxWidth: 30, maxHeight: 30)
                    }
                    HStack(alignment: .top) {
                        Color.red.frame(maxWidth: 50, maxHeight: 50)
                        Color.green.frame(maxWidth: 40, maxHeight: 30)
                        Color.blue.frame(maxWidth: 30, maxHeight: 30)
                    }
                }

            }
        }
        openSwiftUIAssertSnapshot(of: ContentView())
    }
}
