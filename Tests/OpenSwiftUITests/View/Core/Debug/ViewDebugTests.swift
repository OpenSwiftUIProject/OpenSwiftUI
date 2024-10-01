//
//  ViewDebugTests.swift
//
//
//  Created by Kyle on 2023/10/6.
//

@testable import OpenSwiftUI
import Testing
import Foundation

struct ViewDebugTests {
    @Test(.disabled("Skip the test until we finish the implementation of _ViewDebug"))
    func type() throws {
        var rawData = _ViewDebug.Data()
        rawData.data = [.type: CGSize.self]
        let data = try #require(_ViewDebug.serializedData([rawData]))
        let content = String(decoding: data, as: UTF8.self)
        #expect(content == #"""
        [{"properties":[{"id":0,"attribute":{"type":"__C.CGSize","flags":0,"readableType":""}}],"children":[]}]
        """#)
    }

    @Test(.disabled("Skip the test until we finish the implementation of _ViewDebug"))
    func size() throws {
        var rawData = _ViewDebug.Data()
        rawData.data = [.size: CGSize(width: 20, height: 20)]
        let data = try #require(_ViewDebug.serializedData([rawData]))
        let content = String(decoding: data, as: UTF8.self)
        #expect(content == #"""
        [{"properties":[],"children":[]}]
        """#)
    }
}
