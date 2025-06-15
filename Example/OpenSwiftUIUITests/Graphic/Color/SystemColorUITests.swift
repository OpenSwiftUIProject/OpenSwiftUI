//
//  SystemColorUITests.swift
//  OpenSwiftUIUITests

import Testing
import SnapshotTesting

#if OPENSWIFTUI
import OpenSwiftUI
#else
import SwiftUI
#endif

@MainActor
@Suite(.snapshots(record: .never, diffTool: diffTool))
struct SystemColorUITests {
    @Test(
        arguments: [
            (Color.red, "red"),
            (Color.blue, "blue"),
            (Color.green, "green"),
            (Color.yellow, "yellow"),
            (Color.orange, "orange"),
            (Color.purple, "purple"),
            (Color.pink, "pink"),
            (Color.black, "black"),
            (Color.white, "white"),
            (Color.gray, "gray"),
            (Color.clear, "clear"),
        ]
    )
    func systemColors(_ color: Color, name: String) {
        openSwiftUIAssertSnapshot(
            of: color,
            testName: "system_color_\(name)"
        )
    }

    @Test(
        arguments: [
            (Color.primary, "primary"),
            (Color.secondary, "secondary"),
        ]
    )
    func hierarchicalColors(_ color: Color, name: String) {
        openSwiftUIAssertSnapshot(
            of: color,
            testName: "hierarchical_color_\(name)"
        )
    }
}
