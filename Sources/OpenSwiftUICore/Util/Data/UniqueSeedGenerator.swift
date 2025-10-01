//
//  UniqueSeedGenerator.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete

package struct UniqueSeedGenerator {
    var nextID: Int

    package init() {
        nextID = .zero
    }

    package mutating func generate() -> Int {
        defer { nextID += 1 }
        return nextID
    }
}
