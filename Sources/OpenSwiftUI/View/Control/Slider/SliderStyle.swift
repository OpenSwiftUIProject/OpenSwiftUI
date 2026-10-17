//
//  SliderStyle.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: F0F8A8741F68A968D995328632123C18 (SwiftUI)

@_spi(ForOpenSwiftUIOnly)
public import OpenSwiftUICore

// MARK: - SliderStyle

@_spi(Private)
@available(OpenSwiftUI_v4_0, *)
@preconcurrency
@MainActor
public protocol SliderStyle {
    associatedtype Body: View

    @ViewBuilder
    func makeBody(configuration: Configuration) -> Body

    typealias Configuration = SliderStyleConfiguration
}

// MARK: - View + SliderStyle

@available(OpenSwiftUI_v4_0, *)
extension View {
    @_spi(Private)
    nonisolated public func sliderStyle<S>(_ style: S) -> some View where S: SliderStyle {
        modifier(SliderStyleModifier(style: style))
    }
}

// MARK: - SliderStyleConfiguration

@_spi(Private)
@available(OpenSwiftUI_v4_0, *)
public struct SliderStyleConfiguration {
    public struct Label: ViewAlias {
        init() {
            _openSwiftUIEmptyStub()
        }
    }

    public struct MinimumValueLabel: ViewAlias {
        init() {
            _openSwiftUIEmptyStub()
        }
    }

    public struct MaximumValueLabel: ViewAlias {
        init() {
            _openSwiftUIEmptyStub()
        }
    }

    public var label: Label

    public var minimumValueLabel: MinimumValueLabel

    public var maximumValueLabel: MaximumValueLabel

    @Binding public var value: Double

    @_spi(UIFrameworks)
    public var onEditingChanged: (Bool) -> Void

    @_spi(UIFrameworks)
    public let skipDistance: Double

    @_spi(UIFrameworks)
    public let discreteValueCount: Int

    @_spi(UIFrameworks)
    public let marks: [SliderMark<Double>]?

    var hasCustomMinMaxValueLabels: Bool

    var accessibilityValue: AccessibilityBoundedNumber?

    @available(OpenSwiftUI_v6_0, *)
    public struct ValueLabel: View {
        var minimumValueLabel: MinimumValueLabel

        var maximumValueLabel: MaximumValueLabel

        var showMinimum: Bool

        public var body: some View {
            if showMinimum {
                minimumValueLabel
            } else {
                maximumValueLabel
            }
        }
    }
}

@_spi(Private)
@available(*, unavailable)
extension SliderStyleConfiguration.ValueLabel: Sendable {}

@_spi(Private)
@available(*, unavailable)
extension SliderStyleConfiguration.MinimumValueLabel: Sendable {}

@_spi(Private)
@available(*, unavailable)
extension SliderStyleConfiguration.Label: Sendable {}

@_spi(Private)
@available(*, unavailable)
extension SliderStyleConfiguration.MaximumValueLabel: Sendable {}

@_spi(Private)
@available(*, unavailable)
extension SliderStyleConfiguration: Sendable {}

// MARK: - SliderStyleModifier

struct SliderStyleModifier<Style>: StyleModifier where Style: SliderStyle {
    var style: Style

    init(style: Style) {
        self.style = style
    }

    func styleBody(configuration: SliderStyleConfiguration) -> Style.Body {
        style.makeBody(configuration: configuration)
    }
}

// MARK: - ResolvedSliderStyle

struct ResolvedSliderStyle: StyleableView {
    var configuration: SliderStyleConfiguration

    static var defaultStyleModifier: SliderStyleModifier<AutomaticSliderStyle> {
        SliderStyleModifier(style: AutomaticSliderStyle())
    }
}
