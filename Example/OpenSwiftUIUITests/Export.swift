//
//  FrameLayoutUITests.swift
//  OpenSwiftUIUITests

import XCTest
import SnapshotTesting

#if OPENSWIFTUI
@_exported import OpenSwiftUI
let shouldRecord: Bool? = nil
#else
@_exported import SwiftUI
let shouldRecord: Bool? = true
#endif
let diffTool: SnapshotTestingConfiguration.DiffTool = .odiff

extension SnapshotTestingConfiguration.DiffTool {
    static let odiff = Self {
        "odiff \"\($0)\" \"\($1)\""
    }
}
