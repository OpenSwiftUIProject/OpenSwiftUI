//
//  AccessibilityRotorEntry.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: WIP (TBA)
//  ID: 030667BFE09FD674B7612731735E240E (SwiftUI)

import Foundation
import OpenSwiftUICore

// MARK: - AccessibilityRotorEntryElementSpecifier [TBA]

enum AccessibilityRotorEntryElementSpecifier<ID> where ID: Hashable {
    case implicit(ID)
    case namespaced(ID, Namespace.ID)
    case rotorOwner
}

// MARK: - AccessibilityListRotorEntry [TBA]

struct AccessibilityListRotorEntry {
    var elementSpecifier: AccessibilityRotorEntryElementSpecifier<AnyHashable>
    var label: NSAttributedString?
    var range: AccessibilityRotorEntryRange?
    var prepare: () -> Void
    var index: Int?
}
