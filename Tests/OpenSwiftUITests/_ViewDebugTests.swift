//
//  _ViewDebugTests.swift
//
//
//  Created by Kyle on 2023/10/6.
//

@testable import OpenSwiftUI
import Testing
#if canImport(Darwin)
import CoreGraphics
#elseif os(Linux)
import Foundation
#endif

struct _ViewDebugTests {
    @Test(.disabled("Skip the test until we finish the implementation of _ViewDebug"))
    func type() throws {
        let data = try #require(_ViewDebug.serializedData([
            .init(
                data: [
                    .type: CGSize.self,
                ],
                childData: []
            ),
        ]))
        let content = String(decoding: data, as: UTF8.self)
        #expect(content == #"""
        [{"properties":[{"id":0,"attribute":{"type":"__C.CGSize","flags":0,"readableType":""}}],"children":[]}]
        """#)
    }

    @Test(.disabled("Skip the test until we finish the implementation of _ViewDebug"))
    func size() throws {
        let data = try #require(_ViewDebug.serializedData([
            .init(
                data: [
                    .size: CGSize(width: 20, height: 20),
                ],
                childData: []
            ),
        ]))
        let content = String(decoding: data, as: UTF8.self)
        #expect(content == #"""
        [{"properties":[],"children":[]}]
        """#)
    }
}
