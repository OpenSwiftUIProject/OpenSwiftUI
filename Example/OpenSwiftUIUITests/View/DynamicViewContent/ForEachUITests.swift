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

    @Test
    func insertAnimation() {
        struct ContentView: AnimationTestView {
            nonisolated static var model: AnimationTestModel {
                AnimationTestModel(duration: 1.0, count: 5)
            }

            @State private var opacities = [0, 0.5, 1.0]

            var body: some View {
                VStack(spacing: 0) {
                    ForEach(opacities, id: \.self) { opacity in
                        Color.red.opacity(opacity)
                    }
                }.onAppear {
                    withAnimation(.spring(duration: Self.model.duration)) {
                        opacities.insert(0.25, at: 1)
                        opacities.insert(0.75, at: 3)
                    }
                }
            }
        }
        withKnownIssue("#632") {
            Issue.record("AttributeGraph precondition failure: accessing attribute in a different namespace: 36376.")
            // openSwiftUIAssertAnimationSnapshot(of: ContentView())
        }
    }
}
