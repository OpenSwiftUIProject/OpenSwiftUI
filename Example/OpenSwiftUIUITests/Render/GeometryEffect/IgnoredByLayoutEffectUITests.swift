//
//  IgnoredByLayoutEffectUITests.swift
//  OpenSwiftUIUITests

import Testing
import SnapshotTesting

@MainActor
@Suite(.snapshots(record: .never, diffTool: diffTool))
struct IgnoredByLayoutEffectUITests {
    @Test
    func offsetIgnoredByLayout() {
        struct ContentView: View {
            var body: some View {
                WobbleColorView()
            }
        }

        struct WobbleEffect: GeometryEffect {
            var amount: CGFloat = 10
            var shakesPerUnit = 3
            var animatableData: CGFloat

            nonisolated func effectValue(size: CGSize) -> ProjectionTransform {
                let translation = amount * sin(animatableData * .pi * CGFloat(shakesPerUnit))
                return ProjectionTransform(CGAffineTransform(translationX: translation, y: 0))
            }
        }

        struct WobbleColorView: View {
            @State private var wobble = false

            var body: some View {
                Color.red.frame(width: 200, height: 200)
                    .modifier(_OffsetEffect(offset: CGSize(width: 0, height: 100)).ignoredByLayout())
            }
        }
        openSwiftUIAssertSnapshot(of: ContentView())
    }
}
