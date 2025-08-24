//
//  RotationEffectUITests.swift
//  OpenSwiftUIUITests

import Testing
import SnapshotTesting

@MainActor
@Suite(.snapshots(record: .never, diffTool: diffTool))
struct RotationEffectUITests {
    @Test
    func rotationEffect() {
        struct ContentView: View {
            var body: some View {
                Color.blue
                    .frame(width: 80, height: 60)
                    .rotationEffect(.degrees(30))
                    .background(Color.red)
                    .overlay(
                        Color.green
                            .frame(width: 40, height: 30)
                            .rotationEffect(.degrees(-30))
                    )
            }
        }
        openSwiftUIAssertSnapshot(of: ContentView())
    }
}
