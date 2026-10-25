//
//  GaugeStyle.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete

@_spi(ForOpenSwiftUIOnly)
public import OpenSwiftUICore

// MARK: - GaugeStyle

/// Defines the implementation of all gauge instances within a view
/// hierarchy.
///
/// To configure the style for all the ``Gauge`` instances in a view hierarchy,
/// use the ``View/gaugeStyle(_:)`` modifier. For example, you can configure
/// a gauge to use the ``circular`` style:
///
///     Gauge(value: batteryLevel, in: 0...100) {
///         Text("Battery Level")
///     }
///     .gaugeStyle(.circular)
///
/// A type conforming to this protocol inherits `@preconcurrency @MainActor`
/// isolation from the protocol if the conformance is included in the type's
/// base declaration:
///
///     struct MyCustomType: GaugeStyle {
///         // `@preconcurrency @MainActor` isolation by default
///     }
///
/// Isolation to the main actor is the default, but it's not required. Declare
/// the conformance in an extension to opt out of main actor isolation:
///
///     extension MyCustomType: GaugeStyle {
///         // `nonisolated` by default
///     }
@available(OpenSwiftUI_v4_0, *)
@available(tvOS, unavailable)
@preconcurrency
@MainActor
public protocol GaugeStyle {
    /// A view representing the body of a gauge.
    associatedtype Body: View

    /// Creates a view representing the body of a gauge.
    ///
    /// The system calls this modifier on each instance of gauge within a view
    /// hierarchy where this style is the current gauge style.
    ///
    /// - Parameter configuration: The properties to apply to the gauge instance.
    @ViewBuilder
    func makeBody(configuration: Configuration) -> Body

    /// The properties of a gauge instance.
    typealias Configuration = GaugeStyleConfiguration
}

// MARK: - GaugeStyleConfiguration

/// The properties of a gauge instance.
@available(OpenSwiftUI_v4_0, *)
@available(tvOS, unavailable)
public struct GaugeStyleConfiguration {
    /// A type-erased label of a gauge, describing its purpose.
    public struct Label: ViewAlias {
        init() {
            _openSwiftUIEmptyStub()
        }
    }

    /// A type-erased value label of a gauge that contains the current value.
    public struct CurrentValueLabel: ViewAlias {
        init() {
            _openSwiftUIEmptyStub()
        }
    }

    /// A type-erased value label of a gauge describing the minimum value.
    public struct MinimumValueLabel: ViewAlias {
        init() {
            _openSwiftUIEmptyStub()
        }
    }

    /// A type-erased value label of a gauge describing the maximum value.
    public struct MaximumValueLabel: ViewAlias {
        init() {
            _openSwiftUIEmptyStub()
        }
    }

    /// A type-erased label describing a specific value of a gauge.
    public struct MarkedValueLabel: ViewAlias {
        init() {
            _openSwiftUIEmptyStub()
        }
    }

    /// The current value of the gauge.
    ///
    /// The valid range is `0.0...1.0`.
    public var value: Double

    /// A view that describes the purpose of the gauge.
    public var label: Label

    /// A view that describes the current value.
    public var currentValueLabel: CurrentValueLabel?

    /// A view that describes the minimum of the range for the current value.
    public var minimumValueLabel: MinimumValueLabel?

    /// A view that describes the maximum of the range for the current value.
    public var maximumValueLabel: MaximumValueLabel?
}

@available(*, unavailable)
extension GaugeStyleConfiguration: Sendable {}

@available(*, unavailable)
extension GaugeStyleConfiguration.Label: Sendable {}

@available(*, unavailable)
extension GaugeStyleConfiguration.CurrentValueLabel: Sendable {}

@available(*, unavailable)
extension GaugeStyleConfiguration.MinimumValueLabel: Sendable {}

@available(*, unavailable)
extension GaugeStyleConfiguration.MaximumValueLabel: Sendable {}

@available(*, unavailable)
extension GaugeStyleConfiguration.MarkedValueLabel: Sendable {}

// MARK: - View + GaugeStyle

@available(OpenSwiftUI_v4_0, *)
@available(tvOS, unavailable)
extension View {
    /// Sets the style for gauges within this view.
    nonisolated public func gaugeStyle<S>(_ style: S) -> some View where S: GaugeStyle {
        modifier(GaugeStyleModifier(style: style))
    }
}

// MARK: - GaugeStyleModifier

struct GaugeStyleModifier<Style>: StyleModifier where Style: GaugeStyle {
    var style: Style

    init(style: Style) {
        self.style = style
    }

    func styleBody(configuration: GaugeStyleConfiguration) -> Style.Body {
        style.makeBody(configuration: configuration)
    }
}

// MARK: - ResolvedGaugeStyle

struct ResolvedGaugeStyle: StyleableView {
    var configuration: GaugeStyleConfiguration

    static var defaultStyleModifier: GaugeStyleModifier<DefaultGaugeStyle> {
        GaugeStyleModifier(style: DefaultGaugeStyle())
    }
}
