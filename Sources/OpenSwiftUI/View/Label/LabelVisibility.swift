//
//  LabelVisibility.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: D83D7206E97BF0FFC98D060894E9FA4D (SwiftUI)

import OpenSwiftUICore

// MARK: - View + labelsVisibility

extension View {

    /// Controls the visibility of labels of any controls contained within this
    /// view.
    ///
    /// Use this modifier when you want to omit a label from one or more
    /// labeled content in your user interface. For example, the first ``Toggle``
    /// in the following example hides its label:
    ///
    ///     VStack {
    ///         Toggle(isOn: $toggle1) {
    ///             Text("Toggle 1")
    ///         }
    ///         .labelsVisibility(.hidden)
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
    /// because OpenSwiftUI uses labels for other purposes, including accessibility.
    ///
    /// On iOS, a `Picker` within a `Menu` hides its label by default. You can use
    /// this modifier to explicitly show the label in that context:
    ///
    ///     Menu {
    ///         Picker("Flavor", selection: $selectedFlavor) {
    ///             Text("Chocolate").tag(Flavor.chocolate)
    ///             Text("Vanilla").tag(Flavor.vanilla)
    ///             Text("Strawberry").tag(Flavor.strawberry)
    ///         }
    ///         .labelsVisibility(.visible)
    ///     }
    ///
    /// > Note: This modifier doesn't work for all labels. It applies to
    ///   ``LabeledContent`` elements, including controls like ``Picker`` and
    ///   ``Toggle``, but not to controls like a bordered button where the label
    ///   is inside the button's border.
    @available(OpenSwiftUI_v6_0, *)
    nonisolated public func labelsVisibility(_ visibility: Visibility) -> some View {
        labels(visibility)
    }

    @_spi(Private)
    @available(OpenSwiftUI_v4_0, *)
    @available(*, deprecated, message: "Use labelsVisibility(_:) instead")
    nonisolated public func labels(_ visibility: Visibility) -> some View {
        environment(\.labelsVisibility, visibility)
            .input(LabelVisibilityConfigured.self)
    }
}

// MARK: Environment + labelsVisibility

private struct LabelsVisibilityKey: EnvironmentKey {
    static var defaultValue: Visibility { .automatic }
}

@available(OpenSwiftUI_v6_0, *)
extension EnvironmentValues {

    /// The labels visibility set by ``View/labelsVisibility(_:)``.
    ///
    /// Read this environment value from within a view to obtain the preferred
    /// visibility for labels within the hierarchy. If you would like to
    /// dynamically hide the label of your custom view, make sure to include an
    /// accessibility label via the ``View/accessibilityLabel(content:)``
    /// modifier as illustrated below:
    ///
    ///     @Environment(\.labelsVisibility)
    ///     private var labelsVisibility
    ///
    ///     var body: some View {
    ///         VStack {
    ///             QuizCardView()
    ///             if labelsVisibility != .hidden {
    ///                 label
    ///             }
    ///         }
    ///         .accessibilityLabel {
    ///             label
    ///         }
    ///     }
    ///
    ///     private var label: some View {
    ///         Text("Quiz Card")
    ///     }
    public var labelsVisibility: Visibility {
        get { self[LabelsVisibilityKey.self] }
        set { self[LabelsVisibilityKey.self] = newValue }
    }
}

// MARK: - LabelVisibilityConfigured

struct LabelVisibilityConfigured: ViewInputBoolFlag {}
