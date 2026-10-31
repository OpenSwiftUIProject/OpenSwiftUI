//
//  AccessibilityRotorEntryRange.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: WIP (TBA)

import Foundation

// MARK: - AccessibilityRotorEntryRange [TBA]

enum AccessibilityRotorEntryRange {
    case nsRange(NSRange)
    case stringRange(Range<String.Index>)
    #if canImport(UIKit)
    case uiTextRange(UITextRange)
    #endif
}
