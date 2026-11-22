//
//  PathUITests.swift
//  OpenSwiftUIUITests

import SnapshotTesting
import Testing
@testable import TestingHost

@MainActor
@Suite(.snapshots(record: .never, diffTool: diffTool))
struct PathUITests {
    @Test(arguments: PathTrimExample.RangeKind.allCases)
    func trimInfinity(range: PathTrimExample.RangeKind) {
        openSwiftUIAssertSnapshot(
            of: PathTrimExample(range: range),
            named: range.rawValue
        )
    }

    @Test
    func arcSector() {
        openSwiftUIAssertSnapshot(of: PathArcSectorExample())
    }

    @Test
    func trapezoidBackground() {
        openSwiftUIAssertSnapshot(
            of: PathTrapezoidBackgroundExample(styleKind: .explicitTeal)
        )
    }

    @Test(.disabled {
        #if os(macOS)
        // FIXME: Update RenderShape DL
        true
        #else
        false
        #endif
    })
    func trapezoidDefaultBackground() {
        openSwiftUIAssertSnapshot(
            of: PathTrapezoidBackgroundExample(styleKind: .defaultBackground)
        )
    }

    @Test(arguments: PathCurvesAndFillRuleExample.Variant.allCases)
    func curvesAndFillRules(variant: PathCurvesAndFillRuleExample.Variant) {
        openSwiftUIAssertSnapshot(
            of: PathCurvesAndFillRuleExample(variant: variant),
            named: variant.rawValue
        )
    }

    @Test(arguments: PathBooleanExample.Operation.allCases)
    func booleanOperations(operation: PathBooleanExample.Operation) {
        openSwiftUIAssertSnapshot(
            of: PathBooleanExample(operation: operation),
            named: operation.rawValue
        )
    }
}
