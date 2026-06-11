//
//  GestureDebugDualTests.swift
//  OpenSwiftUISymbolDualTests

#if canImport(SwiftUI, _underlyingVersion: 6.5.4)
import Foundation
import OSLog
@_spi(ForOpenSwiftUIOnly)
import OpenSwiftUICore
import Testing

extension GestureDebug.Data {
    @_silgen_name("OpenSwiftUITestStub_GestureDebugDataPrintTree")
    func swiftUI_printTree()
}

#if arch(x86_64)
private let isX86_64 = true
#else
private let isX86_64 = false
#endif

struct PrintTreeCase: @unchecked Sendable {
    var root: GestureDebug.Data
    var expected: [String]
}

private let printTreeCases: [PrintTreeCase] = [
    .gestureWithModifierChild,
    .gestureWithZeroFrameChild,
    .emptyRoot,
    .combinerWithSameFrameChild,
    .primitiveWithFrameDeltaChildren,
]

private extension PrintTreeCase {
    static var gestureWithModifierChild: PrintTreeCase {
        var properties = GestureDebug.Properties()
        properties.append(("trackingID", "touch#7"))
        properties.append(("state", "active"))

        let child = makeData(
            kind: .modifier,
            phase: .ended(()),
            resetSeed: 2,
            frame: CGRect(x: 4, y: 5, width: 6, height: 7),
            properties: properties
        )
        let root = makeData(
            kind: .gesture,
            children: GestureDebug.Data.Children(child),
            phase: .active(()),
            resetSeed: 1,
            frame: CGRect(x: 1, y: 2, width: 3, height: 4)
        )
        return PrintTreeCase(
            root: root,
            expected: [
                "* EmptyGesture<Void> (active) reset:1 {(3.0, 4.0)} @(1.0, 2.0)",
                "* * .(EmptyGesture<Void>) (ended) reset:2 {(6.0, 7.0)} @(4.0, 5.0) [trackingID: touch#7, state: active]",
            ]
        )
    }

    static var gestureWithZeroFrameChild: PrintTreeCase {
        let child = makeData(
            kind: .primitive,
            phase: .failed,
            frame: .zero
        )
        let root = makeData(
            kind: .gesture,
            children: GestureDebug.Data.Children(child),
            phase: .failed,
            frame: CGRect(x: 1, y: 2, width: 3, height: 4)
        )
        return PrintTreeCase(
            root: root,
            expected: [
                "* EmptyGesture<Void> (failed) {(3.0, 4.0)} @(1.0, 2.0)",
                "* * EmptyGesture<Void> (failed)",
            ]
        )
    }

    static var emptyRoot: PrintTreeCase {
        let root = makeData(
            kind: .empty,
            phase: .possible(nil),
            frame: .zero
        )
        return PrintTreeCase(
            root: root,
            expected: [
                "(empty) ()",
            ]
        )
    }

    static var combinerWithSameFrameChild: PrintTreeCase {
        let frame = CGRect(x: 1, y: 2, width: 3, height: 4)
        let child = makeData(
            kind: .primitive,
            phase: .failed,
            resetSeed: 3,
            frame: frame
        )
        let root = makeData(
            kind: .combiner,
            children: GestureDebug.Data.Children(child),
            phase: .possible(()),
            resetSeed: 3,
            frame: frame
        )
        return PrintTreeCase(
            root: root,
            expected: [
                "+ EmptyGesture<Void> (possible(some)) reset:3 {(3.0, 4.0)} @(1.0, 2.0)",
                "| + EmptyGesture<Void> (failed)",
            ]
        )
    }

    static var primitiveWithFrameDeltaChildren: PrintTreeCase {
        let parentFrame = CGRect(x: 1, y: 2, width: 3, height: 4)
        let sizeChangedChild = makeData(
            kind: .primitive,
            phase: .active(()),
            frame: CGRect(x: 1, y: 2, width: 5, height: 6)
        )
        let originChangedChild = makeData(
            kind: .modifier,
            phase: .ended(()),
            frame: CGRect(x: 7, y: 8, width: 3, height: 4)
        )
        let root = makeData(
            kind: .primitive,
            children: GestureDebug.Data.Children(sizeChangedChild, originChangedChild),
            phase: .failed,
            frame: parentFrame
        )
        return PrintTreeCase(
            root: root,
            expected: [
                "EmptyGesture<Void> (failed) {(3.0, 4.0)} @(1.0, 2.0)",
                "EmptyGesture<Void> (active) {(5.0, 6.0)}",
                ".(EmptyGesture<Void>) (ended) @(7.0, 8.0)",
            ]
        )
    }
}

private func makeData(
    kind: GestureDebug.Kind = .primitive,
    type: any Any.Type = EmptyGesture<Void>.self,
    children: GestureDebug.Data.Children = GestureDebug.Data.Children(),
    phase: GesturePhase<()> = .failed,
    resetSeed: UInt32 = 0,
    frame: CGRect = .zero,
    properties: GestureDebug.Properties = GestureDebug.Properties()
) -> GestureDebug.Data {
    GestureDebug.Data(
        kind: kind,
        type: type,
        children: children,
        phase: phase,
        attribute: nil,
        resetSeed: resetSeed,
        frame: frame,
        properties: properties
    )
}

@MainActor
@Suite(.disabled(if: isX86_64, "OSLogStore does not reliably return current-process log entries on x86_64 simulator."))
struct GestureDebugDualTests {
    // NOTE: entry.date has some range diff. So we can't use $0.date > date. Use count instead.
    @available(iOS 15, macOS 12, *)
    private func getLogEntries(count: Int) throws -> [String] {
        let store = try OSLogStore(scope: .currentProcessIdentifier)
        let entries = try store
            .getEntries() // NOTE: options and position are not respected consistently.
            .lazy
            .compactMap {
                $0 as? OSLogEntryLog
            }
            .filter {
                $0.subsystem == "com.apple.diagnostics.events" && $0.category == "SwiftUI"
            }
            .reversed()
            .prefix(count)
            .reversed()
        return Array(entries.map { $0.composedMessage })
    }

    @available(iOS 15, macOS 12, *)
    @Test(arguments: printTreeCases)
    func printTreeAcceptsOpenSwiftUIGestureDebugData(_ testCase: PrintTreeCase) throws {
        testCase.root.swiftUI_printTree()
        let logs = try getLogEntries(count: testCase.expected.count)
        #expect(logs == testCase.expected)
    }
}
#endif
