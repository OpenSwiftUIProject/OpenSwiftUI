//
//  ViewStyle.swift
//  OpenSwiftUI
//
//  Audited for iOS 18.0
//  Status: WIP
//  ID: AC03956538119E2820390436C305EBF1 (SwiftUI)

protocol StyleModifier: MultiViewModifier, PrimitiveViewModifier {
    associatedtype Style

    associatedtype StyleConfiguration

    associatedtype StyleBody: View

    init(style: Style)

    var style: Style { get set }

    func styleBody(configuration: StyleConfiguration) -> StyleBody
}

protocol AnyDefaultStyle {
    init()
}

protocol DefaultStyleModifier: StyleModifier, AnyDefaultStyle {}

protocol StyleOverrideModifier: DefaultStyleModifier {
    associatedtype OriginalStyle

    associatedtype OverrideStyleModifier: StyleModifier
}

protocol StyleWriterOverrideModifier: AnyDefaultStyle {
    associatedtype OriginalStyle

    associatedtype StyleOverride

    static func injectStyleOverride(in: inout _ViewInputs) -> ()
}

protocol DefaultStyleModifierTypeVisitor {
    func visit<S>(type: S.Type) where S: DefaultStyleModifier
}

protocol StyleOverrideModifierTypeVisitor {
    func visit<S>(type: S.Type) where S: StyleOverrideModifier
}

protocol StyleWriterOverrideModifierTypeVisitor {
    func visit<S>(type: S.Type) where S: StyleWriterOverrideModifier
}
