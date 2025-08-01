//
//  IdentifiedViewTreeCompatibilityTests.swift
//  OpenSwiftUICompatibilityTests

import Testing

struct IdentifiedViewTreeCompatibilityTests {
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
