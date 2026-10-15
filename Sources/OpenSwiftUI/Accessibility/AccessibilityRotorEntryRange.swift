//
//  AccessibilityRotorEntryRange.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: WIP (TBA)

import Foundation
#if !os(Android) && canImport(UIKit)
import UIKit
#endif

// MARK: - AccessibilityRotorEntryRange [TBA]

enum AccessibilityRotorEntryRange {
    case nsRange(NSRange)
    case stringRange(Range<String.Index>)
    #if !os(Android) && canImport(UIKit)
    case uiTextRange(UITextRange)
    #endif
}
