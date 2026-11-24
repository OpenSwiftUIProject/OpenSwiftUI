//
//  GroupBox.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete

public import OpenSwiftUICore

// MARK: - GroupBox

/// A container that groups related views with an optional label.
@available(OpenSwiftUI_v1_0, *)
@available(OpenSwiftUI_iOS_v2_0, *)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
public struct GroupBox<Label, Content>: View where Label: View, Content: View {
    var label: Label?
    var content: Content
    @Namespace private var namespace

    init(content: Content, label: Label?) {
        self.content = content
        self.label = label
    }

    /// Creates a group box with a custom label.
    @_alwaysEmitIntoClient
    public init(@ViewBuilder content: () -> Content, @ViewBuilder label: () -> Label) {
        self.init(label: label(), content: content)
    }

    public var body: some View {
        ResolvedGroupBoxStyle(configuration: .init(label: .init(), content: .init()))
            .optionalViewAlias(GroupBoxStyleConfiguration.Label.self) {
                label?.accessibilityConfiguration(AccessibilityGroupBoxLabelModifier(namespace: namespace))
            }
            .viewAlias(GroupBoxStyleConfiguration.Content.self) {
                content.accessibilityConfiguration(AccessibilityGroupBoxContentModifier(namespace: namespace))
            }
    }
}

@available(*, unavailable)
extension GroupBox: Sendable {}

// MARK: - GroupBox + GroupBoxStyleConfiguration

@available(OpenSwiftUI_v2_0, *)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
extension GroupBox where Label == GroupBoxStyleConfiguration.Label, Content == GroupBoxStyleConfiguration.Content {
    /// Creates a group box that applies the next style to the same label and content.
    nonisolated public init(_ configuration: GroupBoxStyleConfiguration) {
        self.init(content: configuration.content, label: configuration.label)
    }
}

// MARK: - Unlabeled initializer

@available(OpenSwiftUI_v1_0, *)
@available(OpenSwiftUI_iOS_v2_0, *)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
extension GroupBox where Label == EmptyView {
    /// Creates a group box without a label.
    nonisolated public init(@ViewBuilder content: () -> Content) {
        self.init(content: content(), label: nil)
    }
}

// MARK: - Text initializers

@available(OpenSwiftUI_v3_0, *)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
extension GroupBox where Label == Text {
    /// Creates a group box with a localized title.
    nonisolated public init(_ titleKey: LocalizedStringKey, @ViewBuilder content: () -> Content) {
        self.init(content: content) { Text(titleKey) }
    }

    /// Creates a group box with a string title.
    @_disfavoredOverload
    nonisolated public init<S>(_ title: S, @ViewBuilder content: () -> Content) where S: StringProtocol {
        self.init(content: content) { Text(title) }
    }
}

// MARK: - Deprecated initializer

@available(OpenSwiftUI_v1_0, *)
@available(OpenSwiftUI_iOS_v2_0, *)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
extension GroupBox {
    /// Creates a group box with the supplied label and content.
    @available(iOS, deprecated: 100000.0, renamed: "GroupBox(content:label:)")
    @available(macOS, deprecated: 100000.0, renamed: "GroupBox(content:label:)")
    @available(visionOS, deprecated: 100000.0, renamed: "GroupBox(content:label:)")
    nonisolated public init(label: Label, @ViewBuilder content: () -> Content) {
        self.init(content: content(), label: label)
    }
}
