//
//  AccessibilityCore.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: TODO

package enum AccessibilityCore {}

extension _GraphInputs {
    package var needsAccessibility: Bool {
        get { options.contains(.needsAccessibility) }
        set { options.setValue(newValue, for: .needsAccessibility) }
    }
}

extension _ViewInputs {
    package var needsAccessibility: Bool {
        get { base.needsAccessibility }
        set { base.needsAccessibility = newValue }
    }
}

package struct WithinAccessibilityRotor: ViewInputBoolFlag {
    package init() {}
}

extension _ViewInputs {
    @inline(__always)
    package var withinAccessibilityRotor: Bool {
        needsAccessibility && self[WithinAccessibilityRotor.self]
    }
}
