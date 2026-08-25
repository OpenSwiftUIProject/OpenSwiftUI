//
//  ProgressViewStyle.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete

@_spi(ForOpenSwiftUIOnly)
public import OpenSwiftUICore

// MARK: - ProgressViewStyle

/// A type that applies standard interaction behavior to all progress views
/// within a view hierarchy.
///
/// To configure the current progress view style for a view hierarchy, use the
/// ``View/progressViewStyle(_:)`` modifier.
@available(OpenSwiftUI_v2_0, *)
@preconcurrency
@MainActor
public protocol ProgressViewStyle {

    /// A view representing the body of a progress view.
    associatedtype Body: View

    /// Creates a view representing the body of a progress view.
    ///
    /// - Parameter configuration: The properties of the progress view being
    ///   created.
    ///
    /// The view hierarchy calls this method for each progress view where this
    /// style is the current progress view style.
    ///
    /// - Parameter configuration: The properties of the progress view, such as
    ///  its preferred progress type.
    @ViewBuilder
    func makeBody(configuration: Configuration) -> Body

    /// A type alias for the properties of a progress view instance.
    typealias Configuration = ProgressViewStyleConfiguration
}

// MARK: - ProgressViewStyleConfiguration

/// The properties of a progress view instance.
@available(OpenSwiftUI_v2_0, *)
public struct ProgressViewStyleConfiguration {

    /// A type-erased label describing the task represented by the progress
    /// view.
    public struct Label: ViewAlias {
        init() {
            _openSwiftUIEmptyStub()
        }
    }

    /// A type-erased label that describes the current value of a progress view.
    public struct CurrentValueLabel: ViewAlias {
        init() {
            _openSwiftUIEmptyStub()
        }
    }

    let value: ProgressViewValue

    /// The completed fraction of the task represented by the progress view,
    /// from `0.0` (not yet started) to `1.0` (fully complete), or `nil` if the
    /// progress is indeterminate or relative to a date interval.
    public let fractionCompleted: Double?

    var alwaysIndeterminate: Bool

    /// A view that describes the task represented by the progress view.
    ///
    /// If `nil`, then the task is self-evident from the surrounding context,
    /// and the style does not need to provide any additional description.
    ///
    /// If the progress view is defined using a `Progress` instance, then this
    /// label is equivalent to its `localizedDescription`.
    public var label: Label?

    /// A view that describes the current value of a progress view.
    ///
    /// If `nil`, then the value of the progress view is either self-evident
    /// from the surrounding context or unknown, and the style does not need to
    /// provide any additional description.
    ///
    /// If the progress view is defined using a `Progress` instance, then this
    /// label is equivalent to its `localizedAdditionalDescription`.
    public var currentValueLabel: CurrentValueLabel?

    init(
        value: ProgressViewValue,
        label: Label?,
        currentValueLabel: CurrentValueLabel?
    ) {
        self.value = value
        switch value {
        case let .absolute(fractionCompleted, alwaysIndeterminate):
            self.fractionCompleted = fractionCompleted
            self.alwaysIndeterminate = alwaysIndeterminate
        case .dateRelative:
            self.fractionCompleted = nil
            self.alwaysIndeterminate = false
        }
        self.label = label
        self.currentValueLabel = currentValueLabel
    }
}

@available(*, unavailable)
extension ProgressViewStyleConfiguration: Sendable {}

@available(*, unavailable)
extension ProgressViewStyleConfiguration.CurrentValueLabel: Sendable {}

@available(*, unavailable)
extension ProgressViewStyleConfiguration.Label: Sendable {}

// MARK: - ProgressViewStyleModifier

struct ProgressViewStyleModifier<Style>: StyleModifier where Style: ProgressViewStyle {
    var style: Style

    init(style: Style) {
        self.style = style
    }

    func styleBody(configuration: ProgressViewStyleConfiguration) -> Style.Body {
        style.makeBody(configuration: configuration)
    }
}

// MARK: - ResolvedProgressViewStyle

struct ResolvedProgressViewStyle: StyleableView {
    var configuration: ProgressViewStyleConfiguration

    static var defaultStyleModifier: ProgressViewStyleModifier<DefaultProgressViewStyle> {
        ProgressViewStyleModifier(style: DefaultProgressViewStyle())
    }

    var body: some View {
        AccessibilityProgressViewModifier(
            fractionCompleted: configuration.fractionCompleted
        ).body(
            content: ProgressView(configuration)
        )
    }
}

// MARK: - View + ProgressViewStyle

@available(OpenSwiftUI_v2_0, *)
extension View {
    /// Sets the style for progress views in this view.
    ///
    /// For example, the following code creates a progress view that uses the
    /// "circular" style:
    ///
    ///     ProgressView()
    ///         .progressViewStyle(.circular)
    ///
    /// - Parameter style: The progress view style to use for this view.
    nonisolated public func progressViewStyle<S>(_ style: S) -> some View where S: ProgressViewStyle {
        modifier(ProgressViewStyleModifier(style: style))
    }
}
