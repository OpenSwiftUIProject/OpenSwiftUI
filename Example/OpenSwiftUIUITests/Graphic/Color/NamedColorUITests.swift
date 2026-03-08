//
//  NamedColorUITests.swift
//  OpenSwiftUIUITests

import Testing
import SnapshotTesting

import Foundation

@MainActor
@Suite(.snapshots(record: .never, diffTool: diffTool))
struct NamedColorUITests {
    @Test(.disabled {
        #if os(macOS)
        true
        #else
        false
        #endif
    })
    func namedColor() {
        openSwiftUIAssertSnapshot(
            of: Color("custom")
        )
    }
}
