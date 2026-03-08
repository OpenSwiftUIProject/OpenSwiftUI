//
//  ViewDebugTests.swift
//
//
//  Created by Kyle on 2023/10/6.
//

import OpenSwiftUICore
import OpenAttributeGraphShims
import Testing
import Foundation

struct ViewDebugTests {
    private func checkJSONEqual(data: Data, expected expectedData: Data) -> Bool {
        let json = try? JSONSerialization.jsonObject(with: data)
        let expectedJSON = try? JSONSerialization.jsonObject(with: expectedData)
        guard let json = json as? [[String: AnyHashable]], let expectedJSON = expectedJSON as? [[String: AnyHashable]] else {
            return false
        }
        return json == expectedJSON
    }

    @Test(.enabled(if: attributeGraphVendor == .ag ,"Only enable the test when AG is enabled"))
    func serializeData() throws {
        var rawData = _ViewDebug.Data()
        rawData.data = [.type: CGSize.self]
        let data = try #require(_ViewDebug.serializedData([rawData]))
        #expect(checkJSONEqual(
            data: data,
            expected: #"""
            [{"properties":[{"id":0,"attribute":{"type":"__C.CGSize","flags":0,"readableType":"CGSize"}}],"children":[]}]
            """#.data(using: .utf8)!
        ))
    }

    @Test(.enabled(if: attributeGraphVendor == .ag ,"Only enable the test when AG is enabled"))
    func size() throws {
        var rawData = _ViewDebug.Data()
        rawData.data = [.size: CGSize(width: 20, height: 20)]
        let data = try #require(_ViewDebug.serializedData([rawData]))
        #expect(checkJSONEqual(
            data: data,
            expected: #"""
            [{"properties":[{"id":4,"attribute":{"value":[20,20],"type":"__C.CGSize","flags":0,"readableType":"CGSize"}}],"children":[]}]
            """#.data(using: .utf8)!
        ))
    }
}
