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

    @Test(
        .bug(
            "https://github.com/OpenSwiftUIProject/OpenSwiftUI/issues/632",
            id: 632
        )
    )
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
        withKnownIssue("#632", isIntermittent: true) {
            // FIXME: Re-enable after #632 is fixed.
            // openSwiftUIAssertAnimationSnapshot(of: ContentView())
            Issue.record("AttributeGraph precondition failure in insertAnimation")
        }
    }

    @Test(
        .bug(
            "https://github.com/OpenSwiftUIProject/OpenSwiftUI/issues/669",
            id: 669
        )
    )
    func dynamicContainerIndex() {
        struct ContentView1: View {
            var body: some View {
                VStack {
                    Color.red
                    Color.green
                    ForEach(0 ..< 1) { index in
                        Color.red.frame(width: 20, height: 20)
                        Spacer()
                        Color.blue.frame(width: 20, height: 20)
                    }
                }
            }
        }
        struct ContentView2: View {
            var body: some View {
                VStack {
                    Color.red
                    Color.green
                    ForEach(0 ..< 1) { index in
                        Spacer()
                        Color.blue
                    }
                }
            }
        }
        struct ContentView3: View {
            var body: some View {
                VStack {
                    Color.red.frame(width: 10, height: 10)
                    Color.green.frame(width: 20, height: 20)
                    ForEach(0 ..< 1) { index in
                        Color.blue.frame(width: 40, height: 40)
                    }
                }
            }
        }
        openSwiftUIAssertSnapshot(of: ContentView1(), named: "1")
        openSwiftUIAssertSnapshot(of: ContentView2(), named: "2")
        openSwiftUIAssertSnapshot(of: ContentView3(), named: "3")
    }

    @Test(
        .bug(
            "https://github.com/OpenSwiftUIProject/OpenSwiftUI/issues/701",
            id: 701
        )
    )
    func emptyDynamicContainer() {
        struct ContentView: View {
            @State private var items = [6]
            var body: some View {
                VStack(spacing: 10) {
                    ForEach(items, id: \.self) { item in
                        Color.blue.opacity(Double(item) / 6.0)
                            .frame(height: 50)
                    }
                }
                .onAppear {
                    items.removeAll { $0 == 6 }
                }
            }
        }
        openSwiftUIAssertSnapshot(of: ContentView())
    }

    @Test(
        .bug(
            "https://github.com/OpenSwiftUIProject/OpenSwiftUI/issues/655",
            id: 655
        )
    )
    func transitionAnimation() {
        struct ContentView: AnimationTestView {
            nonisolated static var model: AnimationTestModel {
                AnimationTestModel(duration: 2.0, count: 4)
            }
            @State private var items = [6]

            var body: some View {
                VStack(spacing: 10) {
                    ForEach(items, id: \.self) { item in
                        Color.blue.opacity(Double(item) / 6.0)
                            .frame(height: 50)
                            .transition(.slide)
                    }
                }
                .animation(.easeInOut(duration: Self.model.duration), value: items)
                .onAppear {
                    items.removeAll { $0 == 6 }
                }
            }
        }
        withKnownIssue(isIntermittent: true) {
            openSwiftUIAssertAnimationSnapshot(of: ContentView())
        }
    }
}
