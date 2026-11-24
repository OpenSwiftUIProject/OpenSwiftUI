//
//  GroupBoxStyle.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete

public import OpenSwiftUICore

// MARK: - GroupBoxStyle

/// A style that controls the appearance of a group box.
@available(OpenSwiftUI_v2_0, *)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
@preconcurrency
@MainActor
public protocol GroupBoxStyle {
    /// The view that displays the group box.
    associatedtype Body: View

    /// Creates a view for the group's label and content.
    @ViewBuilder
    func makeBody(configuration: Configuration) -> Body

    /// The properties of a group box.
    typealias Configuration = GroupBoxStyleConfiguration
}

/// The label and content supplied to a group box style.
@available(OpenSwiftUI_v2_0, *)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
public struct GroupBoxStyleConfiguration {
    /// A type-erased view of the group box's label.
    @MainActor
    @preconcurrency
    public struct Label: ViewAlias {
        init() {
            _openSwiftUIEmptyStub()
        }
    }

    /// A type-erased view of the group box's content.
    @MainActor
    @preconcurrency
    public struct Content: ViewAlias {
        init() {
            _openSwiftUIEmptyStub()
        }
    }

    /// The label that describes the group.
    public let label: Label

    /// The views in the group.
    public let content: Content
}

@available(*, unavailable)
extension GroupBoxStyleConfiguration: Sendable {}

@available(*, unavailable)
extension GroupBoxStyleConfiguration.Content: Sendable {}

@available(*, unavailable)
extension GroupBoxStyleConfiguration.Label: Sendable {}

// MARK: - View + groupBoxStyle

@available(OpenSwiftUI_v2_0, *)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
extension View {
    /// Sets the style for group boxes in this view.
    nonisolated public func groupBoxStyle<S>(_ style: S) -> some View where S: GroupBoxStyle {
        modifier(GroupBoxStyleModifier(style: style))
    }
}

// MARK: - ResolvedGroupBoxStyle

struct ResolvedGroupBoxStyle: StyleableView {
    var configuration: GroupBoxStyleConfiguration

    static var defaultStyleModifier: GroupBoxStyleModifier<DefaultGroupBoxStyle> {
        GroupBoxStyleModifier(style: DefaultGroupBoxStyle())
    }

    var body: some View {
        _UnaryViewAdaptor(
            GroupBox(configuration)
                ._addingBackgroundGroup()
                .modifier(AccessibilityAttachmentModifier(
                    storage: MutableBox(.properties(AccessibilityProperties(reserving: 4))),
                    behavior: .contain
                ))
        )
    }
}

// MARK: - GroupBoxStyleModifier

struct GroupBoxStyleModifier<Style>: StyleModifier where Style: GroupBoxStyle {
    var style: Style

    func styleBody(configuration: GroupBoxStyleConfiguration) -> Style.Body {
        style.makeBody(configuration: configuration)
    }
}
