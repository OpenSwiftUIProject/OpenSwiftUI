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

public struct ViewRendererVendor: RawRepresentable, Hashable, CaseIterable {
    public let rawValue: String

    public init(rawValue: String) {
        self.rawValue = rawValue
    }

    /// OpenSwiftUI's view renderer.
    public static let osui = ViewRendererVendor(rawValue: "org.OpenSwiftUIProject.OpenSwiftUI")

    /// Apple's SwiftUI view renderer.
    public static let sui = ViewRendererVendor(rawValue: "com.apple.SwiftUI")

    public static var allCases: [ViewRendererVendor] { [.osui, .sui] }
}
public let viewRendererVendor = ViewRendererVendor.sui
#endif
let diffTool: SnapshotTestingConfiguration.DiffTool = .odiff

extension SnapshotTestingConfiguration.DiffTool {
    static let odiff = Self {
        "odiff \"\($0)\" \"\($1)\""
    }
}
