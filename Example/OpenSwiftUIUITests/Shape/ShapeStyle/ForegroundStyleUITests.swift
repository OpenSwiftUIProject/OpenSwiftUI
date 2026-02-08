//
//  ForegroundStyleUITests.swift
//  OpenSwiftUIUITests

import Testing
import SnapshotTesting

@MainActor
@Suite(.snapshots(record: .never, diffTool: diffTool))
struct ForegroundStyleUITests {
    @Test
    func foregroundDefault() {
        struct ContentView: View {
            var body: some View {
                Rectangle()
                    .fill(.foreground)
                    .frame(width: 100, height: 100)
            }
        }
        openSwiftUIAssertSnapshot(of: ContentView())
    }

    @Test
    func foregroundSingleStyle() {
        struct ContentView: View {
            var body: some View {
                Rectangle()
                    .frame(width: 100, height: 100)
                    .foregroundStyle(.blue)
            }
        }
        openSwiftUIAssertSnapshot(of: ContentView())
    }

    @Test
    func foregroundPairStyle() {
        struct ContentView: View {
            var body: some View {
                VStack(spacing: 0) {
                    Rectangle()
                        .fill(.primary)
                        .frame(width: 100, height: 50)
                    Rectangle()
                        .fill(.secondary)
                        .frame(width: 100, height: 50)
                }
                .foregroundStyle(.red, .blue)
            }
        }
        openSwiftUIAssertSnapshot(of: ContentView())
    }

    @Test
    func foregroundTripleStyle() {
        struct ContentView: View {
            var body: some View {
                VStack(spacing: 0) {
                    Rectangle()
                        .fill(.primary)
                        .frame(width: 100, height: 34)
                    Rectangle()
                        .fill(.secondary)
                        .frame(width: 100, height: 33)
                    Rectangle()
                        .fill(.tertiary)
                        .frame(width: 100, height: 33)
                }
                .foregroundStyle(.red, .green, .blue)
            }
        }
        openSwiftUIAssertSnapshot(of: ContentView())
    }

    @Test
    func foregroundNestedStyle() {
        struct ContentView: View {
            var body: some View {
                VStack(spacing: 0) {
                    Rectangle()
                        .frame(width: 100, height: 50)
                    Rectangle()
                        .frame(width: 100, height: 50)
                        .foregroundStyle(.red)
                }
                .foregroundStyle(.blue)
            }
        }
        openSwiftUIAssertSnapshot(of: ContentView())
    }

    @Test(.disabled("Text is not supported yet"))
    func foregroundWithText() {
        struct ContentView: View {
            var body: some View {
                Text("Hello")
                    .font(.largeTitle)
                    .foregroundStyle(.blue)
            }
        }
        openSwiftUIAssertSnapshot(of: ContentView())
    }

    @Test
    func foregroundHierarchical() {
        struct ContentView: View {
            var body: some View {
                VStack(spacing: 0) {
                    Rectangle()
                        .fill(.primary)
                        .frame(width: 100, height: 50)
                    Rectangle()
                        .fill(.secondary)
                        .frame(width: 100, height: 50)
                }
                .foregroundStyle(.blue)
            }
        }
        openSwiftUIAssertSnapshot(of: ContentView())
    }
}
