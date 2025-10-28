//
//  LabelsHiddenModifier.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete

public import OpenSwiftUICore

@available(OpenSwiftUI_v1_0, *)
extension View {

    /// Hides the labels of any controls contained within this view.
    ///
    /// Use this modifier when you want to omit a label from one or more
    /// controls in your user interface. For example, the first ``Toggle`` in
    /// the following example hides its label:
    ///
    ///     VStack {
    ///         Toggle(isOn: $toggle1) {
    ///             Text("Toggle 1")
    ///         }
    ///         .labelsHidden()
    ///
    ///         Toggle(isOn: $toggle2) {
    ///             Text("Toggle 2")
    ///         }
    ///     }
    ///
    /// The ``VStack`` in the example above centers the first toggle's control
    /// element in the available space, while it centers the second toggle's
    /// combined label and control element:
    ///
    /// ![A screenshot showing a view with two toggle controls where one label
    ///   is visible and the other label is hidden.](View-labelsHidden-1.png)
    ///
    /// Always provide a label for controls, even when you hide the label,
    /// because SwiftUI uses labels for other purposes, including accessibility.
    ///
    /// > Note: This modifier doesn't work for all labels. It applies to
    ///   labels that are separate from the rest of the control's interface,
    ///   like they are for ``Toggle``, but not to controls like a bordered
    ///   button where the label is inside the button's border.
    nonisolated public func labelsHidden() -> some View {
        modifier(LabelsHiddenModifier())
    }
}

struct LabelsHiddenModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .labeledContentStyle(HiddenLabeledContentStyle())
            .labelsVisibility(.hidden)
    }
}

struct HiddenLabeledContentStyle: LabeledContentStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.content
    }
}
