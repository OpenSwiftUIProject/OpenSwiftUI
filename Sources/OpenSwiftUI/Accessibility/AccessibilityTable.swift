//
//  AccessibilityTable.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Empty
//  ID: 8280BD803D2CBCC6FA870ED247BC75F3 (SwiftUI)

// MARK: - AccessibilityTableNodeVisitor

protocol AccessibilityTableNodeVisitor {
    mutating func visit(node: AccessibilityNode) -> Bool
}

// MARK: - AccessibilityTableDataSource

protocol AccessibilityTableDataSource {
    var rowCount: Int { get }

    var columnCount: Int { get }

    var hasGlobalHeader: Bool { get }

    func visitNodes<V>(applying visitor: inout V, at index: Int) where V: AccessibilityTableNodeVisitor

    func visitHeaderNodes<V>(applying visitor: inout V) where V: AccessibilityTableNodeVisitor
}

// MARK: - AccessibilityTableContext

enum AccessibilityTableContext {
    case table(any AccessibilityTableDataSource)
    case cell(AccessibilityTableCellPosition)
    case span(AccessibilityTableSpanPosition)
    case header(Int)
    case sectionHeader
}

// MARK: - AccessibilityTableSpanPosition

struct AccessibilityTableSpanPosition {
    var rowIndex: Int
    var columnCount: Int
}

// MARK: - AccessibilityTableCellPosition

struct AccessibilityTableCellPosition {
    var rowIndex: Int
    var columnIndex: Int
}
