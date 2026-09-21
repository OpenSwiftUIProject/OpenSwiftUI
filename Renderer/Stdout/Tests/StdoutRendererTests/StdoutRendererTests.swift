//
//  StdoutRendererTests.swift
//  StdoutRendererTests

#if canImport(Darwin)
import Darwin
#elseif canImport(Glibc)
import Glibc
#else
#error("Unsupported platform")
#endif
import Foundation
@_spi(StdoutRenderer) import OpenSwiftUI
import OpenSwiftUITestsSupport
import Testing

@Suite(.tags(.aigc), .timeLimit(.minutes(1)))
struct StdoutRendererTests {
    @Test(arguments: [nil, "0", "1"] as [String?])
    func displayListOutput(printTree: String?) async throws {
        let result = try await #require(
            processExitsWith: .success,
            observing: [\.standardOutputContent, \.standardErrorContent]
        ) { [printTree] in
            configurePrintTree(printTree)
            await ColorStackApp.main()
        }
        let output = try #require(String(validating: result.standardOutputContent, as: UTF8.self))
        let rendered = try rendererOutput(output, printTree: printTree == "1")
        #expect(rendered == """
        OpenSwiftUI backend: stdout
        surface: 640.0x480.0
        display-list-version: <version>
        rendered:
          - fill x:0.0 y:0.0 w:640.0 h:235.0 #FF0000FF
          - fill x:0.0 y:245.0 w:640.0 h:235.0 #0000FFFF

        """)
    }

    @Test(arguments: [nil, "0", "1"] as [String?])
    func terminalOutput(printTree: String?) async throws {
        let result = try await #require(
            processExitsWith: .success,
            observing: [\.standardOutputContent, \.standardErrorContent]
        ) { [printTree] in
            configurePrintTree(printTree)
            await TerminalColorStackApp.main()
        }
        let output = try #require(String(validating: result.standardOutputContent, as: UTF8.self))
        let rendered = try rendererOutput(output, printTree: printTree == "1")
        #expect(rendered == """
        OpenSwiftUI backend: stdout
        surface: 640.0x480.0
        display-list-version: <version>
        terminal: 4x3 color:trueColor
        rendered:
        \u{001B}[0;48;2;255;0;0m    \u{001B}[0m
        \("    ")
        \u{001B}[0;48;2;0;0;255m    \u{001B}[0m

        """)
    }
}

private func configurePrintTree(_ value: String?) {
    // This runs only in the exit-test child, before the renderer reads its environment.
    if let value {
        setenv("OPENSWIFTUI_PRINT_TREE", value, 1)
    } else {
        unsetenv("OPENSWIFTUI_PRINT_TREE")
    }
}

private func rendererOutput(_ output: String, printTree: Bool) throws -> String {
    let marker = "OpenSwiftUI backend: stdout\n"
    let start = try #require(output.range(of: marker))
    #expect(output.components(separatedBy: marker).count == 2)

    if printTree {
        let prefix = output[..<start.lowerBound]
        let treeStart = try #require(prefix.range(of: "View 0x"))
        let tree = String(prefix[treeStart.lowerBound...])
            .replacingOccurrences(
                of: #"View 0x[0-9a-fA-F]+ at Time\(seconds: [0-9.eE+-]+\):"#,
                with: "View <address> at <time>:", options: .regularExpression
            )
            .replacingOccurrences(of: #"#:identity [0-9]+"#, with: "#:identity <id>", options: .regularExpression)
            .replacingOccurrences(of: #"#:version [0-9]+"#, with: "#:version <version>", options: .regularExpression)
            .replacingOccurrences(of: #"content-seed [0-9]+"#, with: "content-seed <seed>", options: .regularExpression)
        #expect(tree == """
        View <address> at <time>:
        (display-list
          (item #:identity <id> #:version <version>
            (frame (0.0 0.0; 640.0 235.0))
            (content-seed <seed>)
            (color #FF0000FF))
          (item #:identity <id> #:version <version>
            (frame (0.0 245.0; 640.0 235.0))
            (content-seed <seed>)
            (color #0000FFFF)))

        """)
    } else {
        #expect(!output.contains("View 0x"))
        #expect(!output.contains("(display-list"))
    }

    return String(output[start.lowerBound...]).replacingOccurrences(
        of: #"(?m)^display-list-version: [0-9]+$"#,
        with: "display-list-version: <version>", options: .regularExpression
    )
}

private struct ColorStackApp: App {
    nonisolated static var rendererConfiguration: _RendererConfiguration? {
        var options = _RendererConfiguration.StdoutOptions()
        options.surface = CGSize(width: 640, height: 480)
        return .stdout(options)
    }

    var body: some Scene {
        WindowGroup {
            VStack(spacing: 10) {
                Color(.sRGB, red: 1, green: 0, blue: 0)
                Color(.sRGB, red: 0, green: 0, blue: 1)
            }
        }
    }
}

private struct TerminalColorStackApp: App {
    nonisolated static var rendererConfiguration: _RendererConfiguration? {
        var options = _RendererConfiguration.StdoutOptions()
        options.surface = CGSize(width: 640, height: 480)
        options.viewMode = .terminal
        options.terminalSize = .init(columns: 4, rows: 3)
        options.colorMode = .trueColor
        return .stdout(options)
    }

    var body: some Scene {
        ColorStackApp().body
    }
}
