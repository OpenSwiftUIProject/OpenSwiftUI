//
//  DefaultStyle.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete

// MARK: - AnyDefaultStyle

package protocol AnyDefaultStyle {
    init()
}

// MARK: - DefaultStyleModifier

package protocol DefaultStyleModifier: StyleModifier where Style: AnyDefaultStyle {}

// MARK: - StyleOverrideModifier

package protocol StyleOverrideModifier: DefaultStyleModifier where Style == OverrideStyleModifier.Style {
    associatedtype OriginalStyle

    associatedtype OverrideStyleModifier: StyleModifier
}

// MARK: - StyleWriterOverrideModifier

package protocol StyleWriterOverrideModifier: AnyDefaultStyle {
    associatedtype OriginalStyle

    associatedtype StyleOverride

    static func injectStyleOverride(in inputs: inout _ViewInputs) -> ()
}

extension StyleWriterOverrideModifier {
    package static func injectStyleOverride<P>(
        in inputs: inout _ViewInputs,
        requiring: P.Type
    ) where P: ViewInputPredicate {
        guard requiring.evaluate(inputs: inputs) else {
            return
        }
        injectStyleOverride(in: &inputs)
    }
}

// MARK: - DefaultStyleModifierTypeVisitor

package protocol DefaultStyleModifierTypeVisitor {
    func visit<T>(type: T.Type) where T: DefaultStyleModifier
}

// MARK: - StyleOverrideModifierTypeVisitor

package protocol StyleOverrideModifierTypeVisitor {
    func visit<T>(type: T.Type) where T: StyleOverrideModifier
}

// MARK: - StyleWriterOverrideModifierTypeVisitor

package protocol StyleWriterOverrideModifierTypeVisitor {
    func visit<T>(type: T.Type) where T: StyleWriterOverrideModifier
}
