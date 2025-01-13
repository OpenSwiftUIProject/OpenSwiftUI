//
//  IdentifiedViewTreeTests.swift
//  OpenSwiftUICompatibilityTests

import Testing

struct IdentifiedViewTreeTests {
    @Test
    func forEachEmpty() async {
        let tree = _IdentifiedViewTree.empty
        await confirmation(expectedCount: 0) { confirm in
            tree.forEach { _ in
                confirm()
            }
        }
    }
}
