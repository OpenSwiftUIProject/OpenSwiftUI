//
//  ForEachUITests.swift
//  OpenSwiftUIUITests

import Testing
import SnapshotTesting

@MainActor
@Suite(.snapshots(record: .never, diffTool: diffTool))
struct ForEachUITests {
    @Test
    func offset() {
        struct ContentView: View {
            var body: some View {
                VStack(spacing: 0) {
                    ForEach(0 ..< 6) { index in
                        Color.red.opacity(Double(index) / 6.0 )
                    }
                }
            }
        }
        openSwiftUIAssertSnapshot(of: ContentView())
    }

    @Test
    func keyPath() {
        struct ContentView: View {
            let opacities = [0, 0.2, 0.4, 0.6, 0.8, 1.0]

            var body: some View {
                VStack(spacing: 0) {
                    ForEach(opacities, id: \.self) { opacity in
                        Color.red.opacity(opacity)
                    }
                }
            }
        }
        openSwiftUIAssertSnapshot(of: ContentView())
    }
}
