//
//  MaterialUITests.swift
//  OpenSwiftUIUITests

import SnapshotTesting
import Testing
@testable import TestingHost

@MainActor
@Suite(.snapshots(record: .never, diffTool: diffTool))
struct MaterialUITests {
    @Test(arguments: [ColorScheme.light, .dark])
    func colorBackground(colorScheme: ColorScheme) {
        openSwiftUIAssertSnapshot(
            of: MaterialExample()
                .environment(\.colorScheme, colorScheme),
            drawHierarchyInKeyWindow: true,
            size: CGSize(width: 320, height: 240),
            named: colorScheme == .dark ? "dark" : "light"
        )
    }

    @Test(arguments: [ColorScheme.light, .dark])
    func imageBackground(colorScheme: ColorScheme) {
        openSwiftUIAssertSnapshot(
            of: MaterialImageBackgroundExample()
                .environment(\.colorScheme, colorScheme),
            drawHierarchyInKeyWindow: true,
            size: CGSize(width: 320, height: 240),
            named: colorScheme == .dark ? "dark" : "light"
        )
    }

    @Test(arguments: [ColorScheme.light, .dark])
    func shapeBackground(colorScheme: ColorScheme) {
        openSwiftUIAssertSnapshot(
            of: MaterialShapeBackgroundExample()
                .environment(\.colorScheme, colorScheme),
            drawHierarchyInKeyWindow: true,
            size: CGSize(width: 320, height: 240),
            named: colorScheme == .dark ? "dark" : "light"
        )
    }
}
