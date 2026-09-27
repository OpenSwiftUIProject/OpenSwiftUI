//
//  SnapshotTesting.swift
//  Shared

import Foundation
import SnapshotTesting
import Testing

#if OPENSWIFTUI
let shouldRecord: SnapshotTestingConfiguration.Record? = nil
#else
let shouldRecord: SnapshotTestingConfiguration.Record? = .all
#endif

let diffTool: SnapshotTestingConfiguration.DiffTool = .odiff

extension SnapshotTestingConfiguration.DiffTool {
    static let odiff = Self {
        "odiff \"\($0)\" \"\($1)\""
    }
}

private let defaultSnapshotReferenceRoot: String = {
    URL(fileURLWithPath: #filePath)
        .deletingLastPathComponent()
        .deletingLastPathComponent()
        .appendingPathComponent("ReferenceImages")
        .path
}()

let snapshotReferenceDirectory: String = {
    #if os(macOS)
    let os = "macOS"
    #elseif os(iOS)
    #if targetEnvironment(simulator)
    let os = "iOS_Simulator"
    #else
    let os = "iOS"
    #endif
    #else
    #error("Unsupported UI test platform")
    #endif
    let version = ProcessInfo.processInfo.operatingSystemVersion
    let osVersion = "\(version.majorVersion).\(version.minorVersion).\(version.patchVersion)"
    let configuredRoot = ProcessInfo.processInfo.environment["SNAPSHOT_REFERENCE_DIR"]
    let referenceRoot: String
    if let configuredRoot, !configuredRoot.isEmpty, !configuredRoot.contains("$(") {
        referenceRoot = configuredRoot
    } else {
        referenceRoot = defaultSnapshotReferenceRoot
    }
    let directory = referenceRoot + "/\(os)/\(osVersion)"
    print("SNAPSHOT_REFERENCE_DIR: \(directory)")
    return directory
}()

func openSwiftUIAssertSnapshotValue<Value, Format>(
    of value: @autoclosure () -> Value,
    as snapshotting: Snapshotting<Value, Format>,
    named name: String? = nil,
    record recording: SnapshotTestingConfiguration.Record? = shouldRecord,
    timeout: TimeInterval = 5,
    fileID: StaticString = #fileID,
    file filePath: StaticString = #filePath,
    testName: String = #function,
    line: UInt = #line,
    column: UInt = #column
) {
    let snapshotDirectory = snapshotReferenceDirectory + "/" + fileID.description
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
