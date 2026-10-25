//
//  LinkUITests.swift
//  OpenSwiftUIUITests

import SnapshotTesting
import Testing
@testable import TestingHost

@MainActor
@Suite(.snapshots(record: .never, diffTool: diffTool))
struct LinkUITests {
    @Test(.tags(.localization))
    func initializers() {
        openSwiftUIAssertSnapshot(
            of: LinkExample(),
            size: .init(width: 320, height: 160)
        )
    }

    @Test
    func buttonStyles() {
        openSwiftUIAssertSnapshot(
            of: LinkButtonStyleExample(),
            size: .init(width: 320, height: 360)
        )
    }

    @Test(arguments: [false, true])
    func appearance(isDisabled: Bool) {
        openSwiftUIAssertSnapshot(
            of: LinkAppearanceExample()
                .disabled(isDisabled),
            size: .init(width: 320, height: 200),
            named: isDisabled ? "disabled" : "enabled"
        )
    }

    @Test(arguments: [ColorScheme.light, .dark])
    func shapeStyle(colorScheme: ColorScheme) {
        openSwiftUIAssertSnapshot(
            of: LinkShapeStyleExample()
                .environment(\.colorScheme, colorScheme),
            size: .init(width: 320, height: 120),
            named: colorScheme == .dark ? "dark" : "light"
        )
    }
}
