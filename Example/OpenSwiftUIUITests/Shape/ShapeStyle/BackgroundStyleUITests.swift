//
//  BackgroundStyleUITests.swift
//  OpenSwiftUIUITests

import Testing
import SnapshotTesting

@MainActor
@Suite(.snapshots(record: .never, diffTool: diffTool))
struct BackgroundStyleUITests {
    @Test
    func backgroundDefault() {
        struct ContentView: View {
            var body: some View {
                Rectangle()
                    .fill(.background)
                    .frame(width: 100, height: 100)
            }
        }
        openSwiftUIAssertSnapshot(of: ContentView())
    }

    @Test
    func backgroundInGroup() {
        struct ContentView: View {
            var body: some View {
                VStack(spacing: 0) {
                    Rectangle()
                        .fill(.background)
                        .frame(width: 100, height: 50)
                    Rectangle()
                        .fill(.background)
                        .frame(width: 100, height: 50)
                        ._addingBackgroundGroup()
                }
            }
        }
        openSwiftUIAssertSnapshot(of: ContentView())
    }

    @Test
    func backgroundInLayer() {
        struct ContentView: View {
            var body: some View {
                VStack(spacing: 0) {
                    Rectangle()
                        .fill(.background)
                        .frame(width: 100, height: 50)
                    Rectangle()
                        .fill(.background)
                        .frame(width: 100, height: 50)
                        ._addingBackgroundLayer()
                }
            }
        }
        openSwiftUIAssertSnapshot(of: ContentView())
    }

    @Test
    func backgroundCustomStyle() {
        struct ContentView: View {
            var body: some View {
                Rectangle()
                    .fill(.background)
                    .frame(width: 100, height: 100)
                    .backgroundStyle(.blue)
            }
        }
        openSwiftUIAssertSnapshot(of: ContentView())
    }

    @Test
    func backgroundNestedCustomStyle() {
        struct ContentView: View {
            var body: some View {
                VStack(spacing: 0) {
                    Rectangle()
                        .fill(.background)
                        .frame(width: 100, height: 50)
                    Rectangle()
                        .fill(.background)
                        .frame(width: 100, height: 50)
                        .backgroundStyle(.red)
                }
                .backgroundStyle(.blue)
            }
        }
        openSwiftUIAssertSnapshot(of: ContentView())
    }

    @Test
    func backgroundWithContent() {
        struct ContentView: View {
            var body: some View {
                ZStack {
                    Rectangle()
                        .fill(.background)
                    Capsule()
                        .foregroundStyle(.primary)
                }
                .frame(width: 100, height: 100)
            }
        }
        openSwiftUIAssertSnapshot(of: ContentView())
    }
}
