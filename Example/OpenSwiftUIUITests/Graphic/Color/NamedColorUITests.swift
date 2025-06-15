//
//  NamedColorUITests.swift
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
struct NamedColorUITests {
    @Test
    func namedColor() {
        openSwiftUIAssertSnapshot(
            of: Color("custom")
        )
    }
}
