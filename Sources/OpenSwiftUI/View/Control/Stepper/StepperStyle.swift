//
//  StepperStyle.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete

@_spi(ForOpenSwiftUIOnly)
public import OpenSwiftUICore

// MARK: - StepperStyle

@_spi(UIFrameworks)
@available(OpenSwiftUI_v4_0, *)
@available(tvOS, unavailable)
@preconcurrency
@MainActor
public protocol StepperStyle {
    associatedtype Body: View

    @ViewBuilder
    func makeBody(configuration: Configuration) -> Body

    typealias Configuration = StepperStyleConfiguration
}

// MARK: - StepperStyleConfiguration

@_spi(UIFrameworks)
@available(OpenSwiftUI_v4_0, *)
@available(tvOS, unavailable)
public struct StepperStyleConfiguration {
    public struct Label: ViewAlias {
        init() {
            _openSwiftUIEmptyStub()
        }
    }

    public var label: Label { Label() }

    var currentValueField: CurrentValueField?

    public let onIncrement: (() -> Void)?

    public let onDecrement: (() -> Void)?

    public let onEditingChanged: (Bool) -> Void

    struct CurrentValueField: View {
        var base: AnyView

        var body: some View { base }
    }
}

@_spi(UIFrameworks)
@available(*, unavailable)
extension StepperStyleConfiguration.Label: Sendable {}

@_spi(UIFrameworks)
@available(*, unavailable)
extension StepperStyleConfiguration: Sendable {}

// MARK: - StepperBody

struct StepperBody: StyleableView {
    var configuration: StepperStyleConfiguration

    static var defaultStyleModifier: StepperStyleModifier<DefaultStepperStyle> {
        StepperStyleModifier(style: DefaultStepperStyle())
    }
}

// MARK: - StepperStyleModifier

struct StepperStyleModifier<Style>: StyleModifier where Style: StepperStyle {
    var style: Style

    init(style: Style) {
        self.style = style
    }

    func styleBody(configuration: StepperStyleConfiguration) -> Style.Body {
        style.makeBody(configuration: configuration)
    }
}
