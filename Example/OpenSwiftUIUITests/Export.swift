//
//  FrameLayoutUITests.swift
//  OpenSwiftUIUITests

import XCTest

#if OPENSWIFTUI
@_exported import OpenSwiftUI
@_exported import OpenAttributeGraphShims
#else
@_exported import SwiftUI

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

public struct AttributeGraphVendor: RawRepresentable, Hashable, CaseIterable {
    public let rawValue: String

    public init(rawValue: String) {
        self.rawValue = rawValue
    }

    /// Apple's private AttributeGraph framework.
    public static let ag = AttributeGraphVendor(rawValue: "com.apple.AttributeGraph")

    /// An incremental computation library for Swift by @jcmosc.
    public static let compute = AttributeGraphVendor(rawValue: "dev.incrematic.compute")

    public static var allCases: [AttributeGraphVendor] { [.ag, .compute] }
}
public let attributeGraphVendor = AttributeGraphVendor.ag
#endif
