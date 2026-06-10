//
//  GestureDebugTests.swift
//  OpenSwiftUICoreTests
//

import Foundation
import OpenAttributeGraphShims
#if !OPENSWIFTUI_SWIFT_LOG
import OSLog
#endif
@_spi(ForOpenSwiftUIOnly)
@testable
#if OPENSWIFTUI_ENABLE_PRIVATE_IMPORTS
@_private(sourceFile: "GestureDebug.swift")
#endif
import OpenSwiftUICore
import Testing

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

#if !OPENSWIFTUI_SWIFT_LOG
@MainActor
@Suite(.disabled(if: isX86_64, "OSLogStore does not reliably return current-process log entries on x86_64 simulator."))
struct GestureDebugLogTests {
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
                $0.subsystem == "com.apple.diagnostics.events" && $0.category == "OpenSwiftUI"
            }
            .reversed()
            .prefix(count)
            .reversed()
        return Array(entries.map { $0.composedMessage })
    }

    @available(iOS 15, macOS 12, *)
    @Test(arguments: printTreeCases)
    func printTreeEmitsExpectedLines(_ testCase: PrintTreeCase) throws {
        testCase.root.printTree()
        let logs = try getLogEntries(count: testCase.expected.count)
        #expect(logs == testCase.expected)
    }

    #if OPENSWIFTUI_ENABLE_PRIVATE_IMPORTS
    @available(iOS 15, macOS 12, *)
    @Test
    func printSubtreeEmitsOneFormattedLine() throws {
        let parent = makeData(
            kind: .gesture,
            phase: .active(()),
            resetSeed: 1,
            frame: CGRect(x: 1, y: 2, width: 3, height: 4)
        )
        let child = makeData(
            kind: .modifier,
            phase: .ended(()),
            resetSeed: 2,
            frame: CGRect(x: 4, y: 5, width: 6, height: 7)
        )

        child.printSubtree(parent: parent, indent: GestureDebug.Data.Indent("* ", kind: .gesture))
        let logs = try getLogEntries(count: 1)
        #expect(logs == [
            "* * .(EmptyGesture<Void>) (ended) reset:2 {(6.0, 7.0)} @(4.0, 5.0)",
        ])
    }
    #endif
}
#endif

#if OPENSWIFTUI_ENABLE_PRIVATE_IMPORTS
struct GestureDebugTests {
    @Test
    func frameDescriptionWithoutParent() {
        #expect(
            makeData(frame: .zero).frameDescription(relativeTo: nil) == ""
        )

        let sizeOnlyFrame = CGRect(origin: .zero, size: CGSize(width: 10, height: 20))
        #expect(
            makeData(frame: sizeOnlyFrame).frameDescription(relativeTo: nil) ==
            " {\((sizeOnlyFrame.size.width, sizeOnlyFrame.size.height))}"
        )

        let originOnlyFrame = CGRect(origin: CGPoint(x: 3, y: 4), size: .zero)
        #expect(
            makeData(frame: originOnlyFrame).frameDescription(relativeTo: nil) ==
            " @\((originOnlyFrame.origin.x, originOnlyFrame.origin.y))"
        )

        let fullFrame = CGRect(x: 3, y: 4, width: 10, height: 20)
        #expect(
            makeData(frame: fullFrame).frameDescription(relativeTo: nil) ==
            " {\((fullFrame.size.width, fullFrame.size.height))} @\((fullFrame.origin.x, fullFrame.origin.y))"
        )
    }

    @Test
    func frameDescriptionRelativeToParent() {
        let parentFrame = CGRect(x: 3, y: 4, width: 10, height: 20)
        let parent = makeData(frame: parentFrame)

        #expect(
            makeData(frame: parentFrame).frameDescription(relativeTo: parent) == ""
        )

        let changedSizeFrame = CGRect(x: 3, y: 4, width: 11, height: 22)
        #expect(
            makeData(frame: changedSizeFrame).frameDescription(relativeTo: parent) ==
            " {\((changedSizeFrame.size.width, changedSizeFrame.size.height))}"
        )

        let changedOriginFrame = CGRect(x: 5, y: 7, width: 10, height: 20)
        #expect(
            makeData(frame: changedOriginFrame).frameDescription(relativeTo: parent) ==
            " @\((changedOriginFrame.origin.x, changedOriginFrame.origin.y))"
        )

        let changedFrame = CGRect(x: 5, y: 7, width: 11, height: 22)
        #expect(
            makeData(frame: changedFrame).frameDescription(relativeTo: parent) ==
            " {\((changedFrame.size.width, changedFrame.size.height))} @\((changedFrame.origin.x, changedFrame.origin.y))"
        )

        #expect(
            makeData(frame: .zero).frameDescription(relativeTo: parent) == ""
        )
    }

    @Test
    func indentPrefixesFollowKind() {
        #expect(GestureDebug.Data.Indent(kind: .gesture).linePrefix == "* ")
        #expect(GestureDebug.Data.Indent(kind: .gesture).childText == "* ")

        #expect(GestureDebug.Data.Indent(kind: .combiner).linePrefix == "+ ")
        #expect(GestureDebug.Data.Indent(kind: .combiner).childText == "| ")

        #expect(GestureDebug.Data.Indent(kind: .modifier).linePrefix == "")
        #expect(GestureDebug.Data.Indent(kind: .modifier).childText == "")
    }
}
#endif
