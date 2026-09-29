//
//  AccessibilityChildBehavior.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Blocked by AnyAccessibilityViewModifier
//  ID: F0D4BE429651399A5FAD2DF7DCDF699D (SwiftUI)

import OpenSwiftUICore

// MARK: - AccessibilityChildBehavior [TBA]

@available(OpenSwiftUI_v1_0, *)
public struct AccessibilityChildBehavior: Hashable {
    var modifier: AnyAccessibilityViewModifier

    static func defaultCombine(
        childProperties: [AccessibilityProperties],
        createsCustomActions: Bool
    ) -> AccessibilityProperties {
        _openSwiftUIUnimplementedFailure()
    }

    public func hash(into hasher: inout Hasher) {
        modifier.hash(into: &hasher)
    }

    public static func == (lhs: AccessibilityChildBehavior, rhs: AccessibilityChildBehavior) -> Bool {
        lhs.modifier.isEqual(to: rhs.modifier)
    }
}

@available(*, unavailable)
extension AccessibilityChildBehavior: Sendable {}
