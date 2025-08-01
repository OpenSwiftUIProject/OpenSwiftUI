//
//  SnapshotTesting+Testing.swift
//  OpenSwiftUIUITests

import SnapshotTesting
import Testing
import Foundation

#if canImport(AppKit)
import AppKit
typealias PlatformHostingController = NSHostingController
typealias PlatformViewController = NSViewController
typealias PlatformView = NSView
typealias PlatformImage = NSImage
typealias PlatformColor = NSColor
extension Color {
    init(platformColor: PlatformColor) {
        self.init(nsColor: platformColor)
    }
}
#else
import UIKit
typealias PlatformHostingController = UIHostingController
typealias PlatformViewController = UIViewController
typealias PlatformView = UIView
typealias PlatformImage = UIImage
typealias PlatformColor = UIColor
extension Color {
    init(platformColor: PlatformColor) {
        self.init(uiColor: platformColor)
    }
}
#endif

let defaultSize = CGSize(width: 200, height: 200)

func openSwiftUIAssertSnapshot<V: View>(
    of value: @autoclosure () throws -> V,
    perceptualPrecision: Float = 1,
    size: CGSize = defaultSize,
    named name: String? = nil,
    record recording: Bool? = shouldRecord,
    timeout: TimeInterval = 5,
    fileID: StaticString = #fileID,
    file filePath: StaticString = #filePath,
    testName: String = #function,
    line: UInt = #line,
    column: UInt = #column
) {
    openSwiftUIAssertSnapshot(
        of: PlatformHostingController(rootView: try value()),
        as: .image(perceptualPrecision: perceptualPrecision, size: size),
        named: (name.map { ".\($0)" } ?? "") + "\(Int(size.width))x\(Int(size.height))",
        record: recording,
        timeout: timeout,
        fileID: fileID,
        file: filePath,
        testName: testName,
        line: line,
        column: column
    )
}

func openSwiftUIAssertSnapshot<V: View>(
    of value: @autoclosure () throws -> V,
    as snapshotting: Snapshotting<PlatformViewController, PlatformImage>,
    named name: String? = nil,
    record recording: Bool? = shouldRecord,
    timeout: TimeInterval = 5,
    fileID: StaticString = #fileID,
    file filePath: StaticString = #filePath,
    testName: String = #function,
    line: UInt = #line,
    column: UInt = #column
) {
    openSwiftUIAssertSnapshot(
        of: PlatformHostingController(rootView: try value()),
        as: snapshotting,
        named: name,
        record: recording,
        timeout: timeout,
        fileID: fileID,
        file: filePath,
        testName: testName,
        line: line,
        column: column
    )
}

func openSwiftUIAssertSnapshot<V: View, Format>(
    of value: @autoclosure () throws -> V,
    as snapshotting: Snapshotting<PlatformViewController, Format>,
    named name: String? = nil,
    record recording: Bool? = shouldRecord,
    timeout: TimeInterval = 5,
    fileID: StaticString = #fileID,
    file filePath: StaticString = #filePath,
    testName: String = #function,
    line: UInt = #line,
    column: UInt = #column
) {
    openSwiftUIAssertSnapshot(
        of: PlatformHostingController(rootView: try value()),
        as: snapshotting,
        named: name,
        record: recording,
        timeout: timeout,
        fileID: fileID,
        file: filePath,
        testName: testName,
        line: line,
        column: column
    )
}

private func openSwiftUIAssertSnapshot<Value, Format>(
    of value: @autoclosure () throws -> Value,
    as snapshotting: Snapshotting<Value, Format>,
    named name: String? = nil,
    record recording: Bool? = shouldRecord,
    timeout: TimeInterval = 5,
    fileID: StaticString = #fileID,
    file filePath: StaticString = #filePath,
    testName: String = #function,
    line: UInt = #line,
    column: UInt = #column
) {
    #if os(macOS)
    let os = "macOS"
    #elseif os(iOS) && targetEnvironment(simulator)
    let os = "iOS_Simulator"
    #endif
    let snapshotDirectory = ProcessInfo.processInfo.environment["SNAPSHOT_REFERENCE_DIR"]! + "/\(os)/" + fileID.description
    let failure = try verifySnapshot(
        of: value(),
        as: snapshotting,
        named: name,
        record: recording,
        snapshotDirectory: snapshotDirectory,
        timeout: timeout,
        fileID: fileID,
        file: filePath,
        testName: testName,
        line: line,
        column: column
    )
    guard let message = failure else { return }
    Issue.record(
        Comment(rawValue: message),
        sourceLocation: SourceLocation(
            fileID: fileID.description,
            filePath: filePath.description,
            line: Int(line),
            column: Int(column)
        )
    )
}
