//
//  HelpTag.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: 7529EF7F24AB68C916419BA46B1AEA8F (SwiftUI)

public import OpenSwiftUICore

@available(OpenSwiftUI_v2_0, *)
extension View {
    /// Adds help text to a view using a localized string that you provide.
    ///
    /// Adding help to a view configures the view's accessibility hint and
    /// its help tag (also called a _tooltip_) in macOS or visionOS.
    /// For more information on using help tags, see
    /// [Offering help](https://developer.apple.com/design/human-interface-guidelines/offering-help)
    /// in the Human Interface Guidelines.
    ///
    ///     Button(action: composeMessage) {
    ///         Image(systemName: "square.and.pencil")
    ///     }
    ///     .help("Compose a new message")
    ///
    /// - Parameter textKey: The key for the localized text to use as help.
    nonisolated public func help(_ textKey: LocalizedStringKey) -> some View {
        HelpView(content: self, text: Text(textKey))
    }

    /// Adds help text to a view using a text view that you provide.
    ///
    /// Adding help to a view configures the view's accessibility hint and
    /// its help tag (also called a _tooltip_) in macOS or visionOS.
    /// For more information on using help tags, see
    /// [Offering help](https://developer.apple.com/design/human-interface-guidelines/offering-help)
    /// in the Human Interface Guidelines.
    ///
    ///     Slider("Opacity", value: $selectedShape.opacity)
    ///         .help(Text("Adjust the opacity of the selected \(selectedShape.name)"))
    ///
    /// - Parameter text: The ``Text`` view to use as help.
    nonisolated public func help(_ text: Text) -> some View {
        HelpView(content: self, text: text)
    }

    /// Adds help text to a view using a string that you provide.
    ///
    /// Adding help to a view configures the view's accessibility hint and
    /// its help tag (also called a _tooltip_) in macOS or visionOS.
    /// For more information on using help tags, see
    /// [Offering help](https://developer.apple.com/design/human-interface-guidelines/offering-help)
    /// in the Human Interface Guidelines.
    ///
    ///     Image(systemName: "pin.circle")
    ///         .foregroundColor(pointOfInterest.tintColor)
    ///         .help(pointOfInterest.name)
    ///
    /// - Parameter text: The text to use as help.
    @_disfavoredOverload
    nonisolated public func help<S>(_ text: S) -> some View where S: StringProtocol {
        HelpView(content: self, text: Text(text))
    }
}

#if os(macOS)
extension View {
    @inline(__always)
    func help<Label>(@ViewBuilder _ label: () -> Label) -> some View where Label: View {
        ViewBasedHelpView(content: self, label: label())
    }
}

private struct ViewBasedHelpView<Content, Label>: View where Content: View, Label: View {
    var content: Content
    var label: Label

    var body: some View {
        PlatformItemsReader(for: TextPlatformItemsStrategy()) { item in
            HelpView(content: content, text: Text(item.content?.text?.string ?? ""))
        } source: {
            label
        }
    }
}
#endif
