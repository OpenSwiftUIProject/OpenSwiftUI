//
//  LabeledContent.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete

public import Foundation
public import OpenSwiftUICore

/// A container for attaching a label to a value-bearing view.
///
/// The instance's content represents a read-only or read-write value, and its
/// label identifies or describes the purpose of that value.
/// The resulting element has a layout that's consistent with other framework
/// controls and automatically adapts to its container, like a form or toolbar.
/// Some styles of labeled content also apply styling or behaviors to the value
/// content, like making ``Text`` views selectable.
///
/// The following example associates a label with a custom view and has
/// a layout that matches the label of the ``Picker``:
///
///     Form {
///         LabeledContent("Custom Value") {
///             MyCustomView(value: $value)
///         }
///         Picker("Selected Value", selection: $selection) {
///             Text("Option 1").tag(1)
///             Text("Option 2").tag(2)
///         }
///     }
///
/// ### Custom view labels
///
/// You can assemble labeled content with an explicit view for its label
/// using the ``init(content:label:)`` initializer. For example, you can
/// rewrite the previous labeled content example using a ``Text`` view:
///
///     LabeledContent {
///         MyCustomView(value: $value)
///     } label: {
///         Text("Custom Value")
///     }
///
/// The `label` view builder accepts any kind of view, like a ``Label``:
///
///     LabeledContent {
///         MyCustomView(value: $value)
///     } label: {
///         Label("Custom Value", systemImage: "hammer")
///     }
///
/// For cases where adding a subtitle to the label is desired, use a view
/// builder that creates multiple `Text` views where the first text represents
/// the title and the second text represents the subtitle:
///
///     LabeledContent {
///         MyCustomView(value: $value)
///     } label: {
///         Text("Custom Value")
///         Text("Custom Subtitle Value")
///     }
///
/// ### Textual labeled content
///
/// You can construct labeled content with string values or formatted values
/// to create read-only displays of textual values:
///
///     Form {
///         Section("Information") {
///             LabeledContent("Name", value: person.name)
///             LabeledContent("Age", value: person.age, format: .number)
///             LabeledContent("Height", value: person.height,
///                 format: .measurement(width: .abbreviated))
///         }
///         if !person.pets.isEmpty {
///             Section("Pets") {
///                 ForEach(pet) { pet in
///                     LabeledContent(pet.species, value: pet.name)
///                 }
///             }
///         }
///     }
///
/// Wherever possible, OpenSwiftUI makes this text selectable.
///
/// ### Compositional elements
///
/// You can use labeled content as the label for other elements. For example,
/// a ``NavigationLink`` can present a summary value for the destination it
/// links to:
///
///     Form {
///         NavigationLink(value: Settings.wifiDetail) {
///             LabeledContent("Wi-Fi", value: ssidName)
///         }
///     }
///
/// In some cases, the styling of views used as the value content is
/// specialized as well. For example, while a ``Toggle`` in an inset group
/// form on macOS is styled as a switch by default, it's styled as a checkbox
/// when used as a value element within a surrounding `LabeledContent`
/// instance:
///
///     Form {
///         LabeledContent("Source Control") {
///             Toggle("Refresh local status automatically",
///                 isOn: $refreshLocalStatus)
///             Toggle("Fetch and refresh server status automatically",
///                 isOn: $refreshServerStatus)
///             Toggle("Add and remove files automatically",
///                 isOn: $addAndRemoveFiles)
///             Toggle("Select files to commit automatically",
///                 isOn: $selectFiles)
///         }
///     }
///
/// ### Controlling label visibility
///
/// A label communicates the identity or purpose of the value, which is
/// important for accessibility. However, you might want to hide the label
/// in the display, and some controls or contexts may visually hide their label
/// by default. The ``View/labelsHidden()`` modifier allows controlling that
/// visibility. The following example hides both labels, producing only a
/// group of the two value views:
///
///     Group {
///         LabeledContent("Custom Value") {
///             MyCustomView(value: $value)
///         }
///         Picker("Selected Value", selection: $selection) {
///             Text("Option 1").tag(1)
///             Text("Option 2").tag(2)
///         }
///     }
///     .labelsHidden()
///
/// ### Styling labeled content
///
/// You can set label styles using the ``View/labeledContentStyle(_:)``
/// modifier. You can also build custom styles using ``LabeledContentStyle``.
@available(OpenSwiftUI_v4_0, *)
public struct LabeledContent<Label, Content> {
    var label: Label

    var content: Content

    var accessibilityPresentation: AccessibilityLabeledContentPresentation?
}

@available(*, unavailable)
extension LabeledContent: Sendable {}

@available(OpenSwiftUI_v4_0, *)
extension LabeledContent: View where Label: View, Content: View {

    /// Creates a standard labeled element, with a view that conveys
    /// the value of the element and a label.
    ///
    /// - Parameters:
    ///   - content: The view that conveys the value of the resulting labeled
    ///     element.
    ///   - label: The label that describes the purpose of the result.
    nonisolated public init(
        @ViewBuilder content: () -> Content,
        @ViewBuilder label: () -> Label
    ) {
        self.content = content()
        self.label = label()
        self.accessibilityPresentation = nil
    }

    public var body: some View {
        ResolvedLabeledContent(
            configuration: LabeledContentStyleConfiguration(
                label: .init(),
                content: .init(),
                accessibilityPresentation: accessibilityPresentation
            )
        ).viewAlias(LabeledContentStyleConfiguration.Label.self) {
            label
        }.viewAlias(LabeledContentStyleConfiguration.Content.self) {
            content
        }
    }
}

@available(OpenSwiftUI_v4_0, *)
extension LabeledContent where Label == Text, Content: View {
    /// Creates a labeled view that generates its label from a localized string
    /// key.
    ///
    /// This initializer creates a ``Text`` label on your behalf, and treats the
    /// localized key similar to ``Text/init(_:tableName:bundle:comment:)``. See
    /// `Text` for more information about localizing strings.
    ///
    /// - Parameters:
    ///   - titleKey: The key for the view's localized title, that describes
    ///     the purpose of the view.
    ///   - content: The value content being labeled.
    public init(
        _ titleKey: LocalizedStringKey,
        @ViewBuilder content: () -> Content
    ) {
        self.init(content: content) {
            Text(titleKey)
        }
        accessibilityPresentation = .merged
    }

    /// Creates a labeled view that generates its label from a string.
    ///
    /// This initializer creates a ``Text`` label on your behalf, and treats the
    /// title similar to ``Text/init(_:)``. See `Text` for more
    /// information about localizing strings.
    ///
    /// - Parameters:
    ///   - title: A string that describes the purpose of the view.
    ///   - content: The value content being labeled.
    @_disfavoredOverload
    public init<S>(
        _ title: S,
        @ViewBuilder content: () -> Content
    ) where S: StringProtocol {
        self.init(content: content) {
            Text(title)
        }
        accessibilityPresentation = .merged
    }
}

@available(OpenSwiftUI_v4_0, *)
extension LabeledContent where Label == Text, Content == Text {
    /// Creates a labeled informational view.
    ///
    /// This initializer creates a ``Text`` label on your behalf, and treats the
    /// localized key similar to ``Text/init(_:tableName:bundle:comment:)``. See
    /// `Text` for more information about localizing strings.
    ///
    ///     Form {
    ///         LabeledContent("Name", value: person.name)
    ///     }
    ///
    /// In some contexts, this text will be selectable by default.
    ///
    /// - Parameters:
    ///   - titleKey: The key for the view's localized title, that describes
    ///     the purpose of the view.
    ///   - value: The value being labeled.
    public init<S>(
        _ titleKey: LocalizedStringKey,
        value: S
    ) where S: StringProtocol {
        self.init(titleKey) {
            Text(value)
        }
    }

    /// Creates a labeled informational view.
    ///
    /// This initializer creates a ``Text`` label on your behalf, and treats the
    /// title similar to ``Text/init(_:)``. See `Text` for more
    /// information about localizing strings.
    ///
    ///     Form {
    ///         ForEach(person.pet) { pet in
    ///             LabeledContent(pet.species, value: pet.name)
    ///         }
    ///     }
    ///
    /// - Parameters:
    ///   - title: A string that describes the purpose of the view.
    ///   - value: The value being labeled.
    @_disfavoredOverload
    public init<S1, S2>(
        _ title: S1,
        value: S2
    ) where S1: StringProtocol, S2: StringProtocol {
        self.init(title) {
            Text(value)
        }
    }

    /// Creates a labeled informational view from a formatted value.
    ///
    /// This initializer creates a ``Text`` label on your behalf, and treats the
    /// localized key similar to ``Text/init(_:tableName:bundle:comment:)``. See
    /// `Text` for more information about localizing strings.
    ///
    ///     Form {
    ///         LabeledContent("Age", value: person.age, format: .number)
    ///         LabeledContent("Height", value: person.height,
    ///             format: .measurement(width: .abbreviated))
    ///     }
    ///
    /// - Parameters:
    ///   - titleKey: The key for the view's localized title, that describes
    ///     the purpose of the view.
    ///   - value: The value being labeled.
    ///   - format: A format style of type `F` to convert the underlying value
    ///     of type `F.FormatInput` to a string representation.
    public init<F>(
        _ titleKey: LocalizedStringKey,
        value: F.FormatInput,
        format: F
    ) where F: FormatStyle, F.FormatInput: Equatable, F.FormatOutput == String {
        self.init(titleKey) {
            Text(value, format: format)
        }
    }

    /// Creates a labeled informational view from a formatted value.
    ///
    /// This initializer creates a ``Text`` label on your behalf, and treats the
    /// title similar to ``Text/init(_:)``. See `Text` for more
    /// information about localizing strings.
    ///
    ///     Form {
    ///         Section("Downloads") {
    ///             ForEach(download) { file in
    ///                 LabeledContent(file.name, value: file.downloadSize,
    ///                     format: .byteCount(style: .file))
    ///            }
    ///         }
    ///     }
    ///
    /// - Parameters:
    ///   - title: A string that describes the purpose of the view.
    ///   - value: The value being labeled.
    ///   - format: A format style of type `F` to convert the underlying value
    ///     of type `F.FormatInput` to a string representation.
    public init<S, F>(
        _ title: S,
        value: F.FormatInput,
        format: F
    ) where S: StringProtocol, F: FormatStyle, F.FormatInput: Equatable, F.FormatOutput == String {
        self.init(title) {
            Text(value, format: format)
        }
    }
}

@available(OpenSwiftUI_v4_0, *)
extension LabeledContent where Label == LabeledContentStyleConfiguration.Label, Content == LabeledContentStyleConfiguration.Content {
    /// Creates labeled content based on a labeled content style configuration.
    ///
    /// You can use this initializer within the
    /// ``LabeledContentStyle/makeBody(configuration:)`` method of a
    /// ``LabeledContentStyle`` to create a labeled content instance.
    /// This is useful for custom styles that only modify the current style,
    /// as opposed to implementing a brand new style.
    ///
    /// For example, the following style adds a red border around the labeled
    /// content, but otherwise preserves the current style:
    ///
    ///     struct RedBorderLabeledContentStyle: LabeledContentStyle {
    ///         func makeBody(configuration: Configuration) -> some View {
    ///             LabeledContent(configuration)
    ///                 .border(.red)
    ///         }
    ///     }
    ///
    /// - Parameter configuration: The properties of the labeled content
    public init(_ configuration: LabeledContentStyleConfiguration) {
        self.init {
            configuration.content
        } label: {
            configuration.label
        }
    }
}
