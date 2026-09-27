//
//  SnapshotTesting+Testing.swift
//  OpenSwiftUIUITests

#if os(macOS)
import AppKit
#endif
import Foundation
import SnapshotTesting
import TestingHost

let defaultSize = CGSize(width: 200, height: 200)

#if os(macOS)
extension Snapshotting where Value == NSViewController, Format == NSImage {
    /// drawHierarchyInKeyWindow is iOS only parameter, here for compatibility
    static func image(
        drawHierarchyInKeyWindow: Bool,
        precision: Float = 1,
        perceptualPrecision: Float = 1,
        size: CGSize? = nil,
    ) -> Snapshotting {
        .image(precision: precision, perceptualPrecision: perceptualPrecision, size: size)
    }
}
#endif

func openSwiftUIAssertSnapshot<V: View>(
    of value: @autoclosure () -> V,
    drawHierarchyInKeyWindow: Bool = false,
    precision: Float = 1,
    perceptualPrecision: Float = 1,
    size: CGSize = defaultSize,
    named name: String? = nil,
    record recording: SnapshotTestingConfiguration.Record? = shouldRecord,
    timeout: TimeInterval = 5,
    fileID: StaticString = #fileID,
    file filePath: StaticString = #filePath,
    testName: String = #function,
    line: UInt = #line,
    column: UInt = #column
) {
    openSwiftUIAssertSnapshotValue(
        of: PlatformHostingController(rootView: value()),
        as: .image(drawHierarchyInKeyWindow: drawHierarchyInKeyWindow, precision: precision, perceptualPrecision: perceptualPrecision, size: size),
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
    record recording: SnapshotTestingConfiguration.Record? = shouldRecord,
    timeout: TimeInterval = 5,
    fileID: StaticString = #fileID,
    file filePath: StaticString = #filePath,
    testName: String = #function,
    line: UInt = #line,
    column: UInt = #column
) {
    openSwiftUIAssertSnapshotValue(
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
    record recording: SnapshotTestingConfiguration.Record? = shouldRecord,
    timeout: TimeInterval = 5,
    fileID: StaticString = #fileID,
    file filePath: StaticString = #filePath,
    testName: String = #function,
    line: UInt = #line,
    column: UInt = #column
) {
    openSwiftUIAssertSnapshotValue(
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
    record recording: SnapshotTestingConfiguration.Record? = shouldRecord,
    timeout: TimeInterval = 5,
    fileID: StaticString = #fileID,
    file filePath: StaticString = #filePath,
    testName: String = #function,
    line: UInt = #line,
    column: UInt = #column
) {
    openSwiftUIAssertSnapshotValue(
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

// MARK: - Animation

func openSwiftUIAssertAnimationSnapshot<V: AnimationTestView>(
    of value: @autoclosure () -> V,
    precision: Float = 1,
    perceptualPrecision: Float = 1,
    size: CGSize = defaultSize,
    record recording: SnapshotTestingConfiguration.Record? = shouldRecord,
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
        openSwiftUIAssertSnapshotValue(
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
