//
//  ShapeUITests.swift
//  OpenSwiftUIUITests

import Testing
import SnapshotTesting

@MainActor
@Suite(.snapshots(record: .never, diffTool: diffTool))
struct ShapeUITests {
    @Test
    func rectangle() {
        struct ContentView: View {
            var body: some View {
                Rectangle()
                    .fill(Color.red)
                    .frame(width: 100, height: 100, alignment: .center)
            }
        }
        openSwiftUIAssertSnapshot(of: ContentView())
    }

    @Test
    func circle() {
        struct ContentView: View {
            var body: some View {
                Circle()
                    .fill(Color.red)
                    .frame(width: 100, height: 100, alignment: .center)
            }
        }
        openSwiftUIAssertSnapshot(of: ContentView())
    }

    @Test
    func shadow() {
        struct ContentView: View {
            var body: some View {
                Circle()
                    .fill(Color.red.shadow(.drop(color: .blue,radius: 5, x: 10, y: 10)))
                    .frame(width: 100, height: 100, alignment: .center)
            }
        }
        openSwiftUIAssertSnapshot(of: ContentView())
    }
}
