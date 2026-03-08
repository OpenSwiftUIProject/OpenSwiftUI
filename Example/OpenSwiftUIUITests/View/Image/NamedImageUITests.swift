//
//  NamedImageUITests.swift
//  OpenSwiftUIUITests

import SnapshotTesting
import Testing
@testable import TestingHost

@MainActor
@Suite(.snapshots(record: .never, diffTool: diffTool))
struct NamedImageUITests {
    @Test("Test named image of logo with resizable")
    func decorativeLogo() {
        struct ContentView: View {
            var body: some View {
                Image(decorative: "logo")
                    .resizable()
                    .frame(width: 100, height: 100)
            }
        }
        openSwiftUIAssertSnapshot(of: ContentView())
    }

    @Test("Test named image of logo with different renderingMode")
    func renderingModeLogo() {
        struct ContentView: View {
            var body: some View {
                VStack(spacing: .zero) {
                    Image(decorative: "logo")
                        .renderingMode(.original)
                        .resizable()
                        .frame(width: 100, height: 100)
                    HStack(spacing: .zero) {
                        Image(decorative: "logo")
                            .renderingMode(.template)
                            .resizable()
                        Image(decorative: "logo")
                            .renderingMode(.template)
                            .resizable()
                            .foregroundStyle(.red)
                    }
                    .frame(width: 200, height: 100)
                }
            }
        }
        openSwiftUIAssertSnapshot(of: ContentView())
    }
}
