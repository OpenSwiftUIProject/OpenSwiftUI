//
//  Rotation3DEffectUITests.swift
//  OpenSwiftUIUITests

import Testing
import SnapshotTesting

@MainActor
@Suite(.snapshots(record: .never, diffTool: diffTool))
struct Rotation3DEffectUITests {
    @Test
    func rotation3DEffect() {
        struct ContentView: View {
            var body: some View {
                Color.blue
                    .frame(width: 80, height: 60)
                    .rotation3DEffect(
                        .degrees(45),
                        axis: (x: 0, y: 1, z: 0),
                        anchor: .center,
                        anchorZ: 0,
                        perspective: 1
                    )
                    .background(Color.red)
                    .overlay(
                        Color.green
                            .frame(width: 40, height: 30)
                            .rotation3DEffect(
                                .degrees(-45),
                                axis: (x: 1, y: 0, z: 0),
                                anchor: .center,
                                anchorZ: 0,
                                perspective: 1
                            )
                    )
            }
        }
        openSwiftUIAssertSnapshot(of: ContentView())
    }
}
