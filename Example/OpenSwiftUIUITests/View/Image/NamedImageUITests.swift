//
//  NamedImageUITests.swift
//  OpenSwiftUIUITests

import SnapshotTesting
import Testing
@testable import TestingHost

@MainActor
@Suite(
    .snapshots(record: .never, diffTool: diffTool),
    .disabled("#817")
)
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

    @Test("Test different symbol varient")
    func symbolVarient() {
        struct ContentView: View {
            let name = "document"
            var body: some View {
                VStack {
                    Image(systemName: name)
                    Image(systemName: name)
                        .symbolVariant(.circle)
                    Image(systemName: name)
                        .symbolVariant(.fill)
                }
            }
        }
        openSwiftUIAssertSnapshot(of: ContentView())
    }

    @Test("Test symbol image with variable value")
    func symbolImageWithVariableValue() {
        struct ContentView: View {
            let name: String = "speaker.wave.3"
            var body: some View {
                VStack {
                    Image(systemName: name, variableValue: 0)
                    Image(systemName: name, variableValue: 0.33)
                    Image(systemName: name, variableValue: 0.67)
                    Image(systemName: name, variableValue: 1)
                }
            }
        }
        openSwiftUIAssertSnapshot(of: ContentView())
    }

    @Test(
        "Test symbol image with different rendering mode",
        .disabled("renderVectorGlyph is not supported yet")
    )
    func symbolImageRenderingMode() {
        struct ContentView: View {
            let name: String = "gear"
            var body: some View {
                VStack(spacing: .zero) {
                    Image(systemName: name)
                        .foregroundStyle(.red)
                    Image(systemName: name)
                        .symbolRenderingMode(.multicolor)
                        .foregroundStyle(.red, .blue)
                    Image(systemName: name)
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(.red, .blue)
                }.symbolVariant(.circle)
            }
        }
        openSwiftUIAssertSnapshot(of: ContentView())
    }
}
