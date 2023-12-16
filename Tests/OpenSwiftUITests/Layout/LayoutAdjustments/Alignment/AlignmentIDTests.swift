//
//  AlignmentIDTests.swift
//
//
//  Created by Kyle on 2023/12/16.
//

@testable import OpenSwiftUI
import XCTest

final class AlignmentIDTests: XCTestCase {
    private struct TestAlignment: AlignmentID {
        static func defaultValue(in _: ViewDimensions) -> CGFloat { .zero }
    }

    func testCombineExplicitLinear() throws {
        var value: CGFloat?
        (0 ... 10).forEach { n in
            TestAlignment._combineExplicit(
                childValue: .init(n),
                n,
                into: &value
            )
            XCTAssertEqual(value!, CGFloat(n) / 2, accuracy: 0.0001)
        }
    }

    func testCombineExplicitSame() throws {
        var value: CGFloat?
        let child = CGFloat.random(in: 0.0 ... 100.0)
        (0 ... 10).forEach { n in
            TestAlignment._combineExplicit(
                childValue: child,
                n,
                into: &value
            )
            XCTAssertEqual(value!, child, accuracy: 0.0001)
        }
    }
}
