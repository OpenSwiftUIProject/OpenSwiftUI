//
//  ScaleEffectUITests.swift
//  OpenSwiftUIUITests

import Testing
import SnapshotTesting

@MainActor
@Suite(.snapshots(record: .never, diffTool: diffTool))
struct ScaleEffectUITests {
    @Test
    func scaleWithFrame() {
        struct ContentView: View {
            var body: some View {
                Color.blue
                    .frame(width: 80, height: 60)
                    .scaleEffect(0.5)
                    .background { Color.red }
                    .overlay {
                        Color.green
                            .frame(width: 40, height: 30)
                            .scaleEffect(1.5)
                    }
            }
        }
        openSwiftUIAssertSnapshot(of: ContentView())
    }

    @Test
    func scaleWithAnchor() {
        struct ContentView: View {
            var body: some View {
                Color.blue
                    .frame(width: 80, height: 60)
                    .scaleEffect(0.5, anchor: .topLeading)
                    .background { Color.red }
            }
        }
        openSwiftUIAssertSnapshot(of: ContentView())
    }

    @Test
    func scaleWithXY() {
        struct ContentView: View {
            var body: some View {
                Color.blue
                    .frame(width: 80, height: 60)
                    .scaleEffect(x: 0.5, y: 1.5)
                    .background { Color.red }
            }
        }
        openSwiftUIAssertSnapshot(of: ContentView())
    }
}

