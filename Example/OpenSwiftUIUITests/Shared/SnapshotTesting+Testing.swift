//
//  SnapshotTesting+Testing.swift
//  OpenSwiftUIUITests

import SnapshotTesting
import Testing
import Foundation
#if OPENSWIFTUI
import OpenSwiftUI
#else
import SwiftUI
#endif

#if canImport(AppKit)
import AppKit
typealias PlatformHostingController = NSHostingController
typealias PlatformViewController = NSViewController
typealias PlatformView = NSView
typealias PlatformImage = NSImage
#else
import UIKit
typealias PlatformHostingController = UIHostingController
typealias PlatformViewController = UIViewController
typealias PlatformView = UIView
typealias PlatformImage = UIImage
#endif

func openSwiftUIAssertSnapshot<V: View>(
    of value: @autoclosure () throws -> V,
    as snapshotting: Snapshotting<PlatformViewController, PlatformImage> = .image(size: CGSize(width: 200, height: 200)),
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
    as snapshotting: Snapshotting<UIViewController, Format>,
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

func openSwiftUIAssertSnapshot<Value, Format>(
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
    let snapshotDirectory = ProcessInfo.processInfo.environment["SNAPSHOT_REFERENCE_DIR"]! + "/" + fileID.description
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
