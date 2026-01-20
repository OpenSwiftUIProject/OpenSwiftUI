//
//  SnapshotTesting+Testing.swift
//  OpenSwiftUIUITests

import SnapshotTesting
import Testing
import Foundation

#if canImport(AppKit)
import AppKit
typealias PlatformHostingController = NSHostingController
typealias PlatformHostingView = NSHostingView
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
typealias PlatformHostingView = _UIHostingView
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
    of value: @autoclosure () -> V,
    drawHierarchyInKeyWindow: Bool = false,
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
        of: PlatformHostingController(rootView: value()),
        as: .image(drawHierarchyInKeyWindow: drawHierarchyInKeyWindow, perceptualPrecision: perceptualPrecision, size: size),
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
    of value: @autoclosure () -> V,
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
        of: PlatformHostingController(rootView: value()),
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
    of value: @autoclosure () -> V,
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
        of: PlatformHostingController(rootView: value()),
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

// FIXME: Should remove controller in name
func openSwiftUIControllerAssertSnapshot<V: PlatformViewController, Format>(
    of value: @autoclosure () -> V,
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
        of: value(),
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

// FIXME: Should be internal, private due to conflict infer
private func openSwiftUIAssertSnapshot<Value, Format>(
    of value: @autoclosure () -> Value,
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
    let failure = verifySnapshot(
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

// MARK: - Animation

func openSwiftUIAssertAnimationSnapshot<V: AnimationTestView>(
    of value: @autoclosure () -> V,
    precision: Float = 1,
    perceptualPrecision: Float = 1,
    size: CGSize = defaultSize,
    record recording: Bool? = shouldRecord,
    timeout: TimeInterval = 5,
    fileID: StaticString = #fileID,
    file filePath: StaticString = #filePath,
    testName: String = #function,
    line: UInt = #line,
    column: UInt = #column
) {
    let vc = AnimationDebugController(value())
    let model = V.model
    var intervals = model.intervals
    intervals.insert(.zero, at: 0)
    intervals.enumerated().forEach { (index, interval) in
        switch index {
        case 0:
            break
        case 1:
            vc.advance(interval: .zero)
            vc.advance(interval: .zero)
            vc.advance(interval: .zero)
            vc.advance(interval: interval)
        default:
            vc.advance(interval: interval)
        }
        openSwiftUIAssertSnapshot(
            of: vc,
            as: .image(precision: precision, perceptualPrecision: perceptualPrecision, size: size),
            named: "\(index)_\(model.intervals.count).\(Int(size.width))x\(Int(size.height))",
            record: recording,
            timeout: timeout,
            fileID: fileID,
            file: filePath,
            testName: testName,
            line: line,
            column: column
        )
    }
}
