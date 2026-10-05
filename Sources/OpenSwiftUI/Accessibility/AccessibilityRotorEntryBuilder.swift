//
//  AccessibilityRotorEntryBuilder.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: WIP (TBA)
//  ID: C2A5ACE36769891C54EB5D74DF758042 (SwiftUI)

// MARK: - AccessibilityRotorEntryVisitor

protocol AccessibilityRotorEntryVisitor {
    mutating func visit(entry: AccessibilityListRotorEntry) -> Bool
}

// MARK: - AccessibilityRotorEntryGenerator

protocol AccessibilityRotorEntryGenerator {
    func visitEntries<V>(applying visitor: inout V, from index: inout Int) -> Bool where V: AccessibilityRotorEntryVisitor

    var count: Int { get }
}

// MARK: - AccessibilityRotorEntryList

struct AccessibilityRotorEntryList {
    var generator: any AccessibilityRotorEntryGenerator
}
