//
//  _ViewDebugTests.swift
//  
//
//  Created by Kyle on 2023/10/6.
//

import XCTest
@testable import OpenSwiftUI

final class _ViewDebugTests: XCTestCase {
    func testType() throws {
        throw XCTSkip("Skip the test until we finish the implementation of _ViewDebug")
//        let data = try XCTUnwrap(_ViewDebug.serializedData([
//            .init(
//                data: [
//                    .type: CGSize.self,
//                ],
//                childData: []
//            )
//        ]))
//        let content = String(decoding: data, as: UTF8.self)
//        XCTAssertEqual(content, """
//        [{"properties":[{"id":0,"attribute":{"type":"__C.CGSize","flags":0,"readableType":""}}],"children":[]}]
//        """)
    }

    func testSize() throws {
        throw XCTSkip("Skip the test until we finish the implementation of _ViewDebug")
//        let data = try XCTUnwrap(_ViewDebug.serializedData([
//            .init(
//                data: [
//                    .size: CGSize(width: 20, height: 20),
//                ],
//                childData: []
//            )
//        ]))
//        let content = String(decoding: data, as: UTF8.self)
//        XCTAssertEqual(content, """
//        [{"properties":[],"children":[]}]
//        """)
    }
}
