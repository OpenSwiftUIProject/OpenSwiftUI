//
//  LabeledContentStyleConfiguration.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete

import OpenSwiftUICore

// MARK: - LabeledContentStyle

/// The appearance and behavior of a labeled content instance..
///
/// Use ``View/labeledContentStyle(_:)`` to set a style on a view.
///
/// A type conforming to this protocol inherits `@preconcurrency @MainActor`
/// isolation from the protocol if the conformance is included in the type's
/// base declaration:
///
///     struct MyCustomType: Transition {
///         // `@preconcurrency @MainActor` isolation by default
///     }
///
/// Isolation to the main actor is the default, but it's not required. Declare
/// the conformance in an extension to opt out of main actor isolation:
///
///     extension MyCustomType: Transition {
///         // `nonisolated` by default
///     }
///
@available(OpenSwiftUI_v4_0, *)
@preconcurrency
@MainActor
public protocol LabeledContentStyle {

    /// A view that represents the appearance and behavior of labeled content.
    associatedtype Body: View

    /// Creates a view that represents the body of labeled content.
    @ViewBuilder
    func makeBody(configuration: Configuration) -> Body

    /// The properties of a labeled content instance.
    typealias Configuration = LabeledContentStyleConfiguration
}

// MARK: - LabeledContentStyleConfiguration

/// The properties of a labeled content instance.
@available(OpenSwiftUI_v4_0, *)
public struct LabeledContentStyleConfiguration {

    /// A type-erased label of a labeled content instance.
    @MainActor
    @preconcurrency
    public struct Label: ViewAlias {
        init() {}
    }

    /// A type-erased content of a labeled content instance.
    @MainActor
    @preconcurrency
    public struct Content: ViewAlias {
        init() {}
    }

    /// The label of the labeled content instance.
    public let label: LabeledContentStyleConfiguration.Label

    /// The content of the labeled content instance.
    public let content: LabeledContentStyleConfiguration.Content

    var accessibilityPresentation: AccessibilityLabeledContentPresentation?
}

@available(*, unavailable)
extension LabeledContentStyleConfiguration: Sendable {}

@available(*, unavailable)
extension LabeledContentStyleConfiguration.Label: Sendable {}

@available(*, unavailable)
extension LabeledContentStyleConfiguration.Content: Sendable {}

// MARK: - View + labeledContentStyle

@available(OpenSwiftUI_v3_0, *)
extension View {

    /// Sets a style for labeled content.
    nonisolated public func labeledContentStyle<S>(_ style: S) -> some View where S: LabeledContentStyle {
        modifier(_LabeledContentStyleModifier(style: style))
    }
}

// MARK: - ResolvedLabeledContent

struct ResolvedLabeledContent: StyleableView {
    struct _Body: View {
        var configuration: LabeledContentStyleConfiguration

        var body: some View {
            LabeledContent {
                configuration.content
            } label: {
                configuration.label
            }.viewAlias(LabeledContentStyleConfiguration.Label.self) {
                configuration.label
                    .modifier(
                        AccessibilityLabeledContentLabelModifier(
                            presentation: configuration.accessibilityPresentation
                        )
                    )
            }.viewAlias(LabeledContentStyleConfiguration.Content.self) {
                configuration.content
                    .modifier(
                        AccessibilityLabeledContentContentModifier(
                            label: configuration.label,
                            presentation: configuration.accessibilityPresentation
                        )
                    )
            }.modifier(AccessibilityFrameModifier())
        }
    }

    var body: _Body {
        _Body(configuration: configuration)
    }

    var configuration: LabeledContentStyleConfiguration

    static let defaultStyleModifier: _LabeledContentStyleModifier<AutomaticLabeledContentStyle> = .init(style: .init())
}

// MARK: - _LabeledContentStyleModifier

struct _LabeledContentStyleModifier<S>: StyleModifier where S: LabeledContentStyle {
    var style: S

    init(style: S) {
        self.style = style
    }

    func styleBody(configuration: LabeledContentStyleConfiguration) -> S.Body {
        style.makeBody(configuration: configuration)
    }
}
