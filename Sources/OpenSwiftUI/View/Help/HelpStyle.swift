//
//  HelpStyle.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: 2E9CED02B61F68F209568461F8033B51 (SwiftUI)

public import OpenSwiftUICore

// MARK: - HelpStyle

@_spi(UIFrameworks)
@available(OpenSwiftUI_v4_0, *)
@preconcurrency
@MainActor
public protocol HelpStyle {
    associatedtype Body: View

    @ViewBuilder
    func makeBody(configuration: Configuration) -> Body

    typealias Configuration = HelpStyleConfiguration
}

// MARK: - HelpStyleConfiguration

@_spi(UIFrameworks)
@available(OpenSwiftUI_v4_0, *)
public struct HelpStyleConfiguration {
    public struct Content: ViewAlias {
        public typealias Body = Never

        nonisolated package init() {
            _openSwiftUIEmptyStub()
        }
    }

    public let content: Content = .init()
    public let text: Text
}

@_spi(UIFrameworks)
@available(*, unavailable)
extension HelpStyleConfiguration.Content: Sendable {}

@_spi(UIFrameworks)
@available(*, unavailable)
extension HelpStyleConfiguration: Sendable {}

// MARK: - HelpView

struct HelpView<Content>: View where Content: View {
    var content: Content
    var text: Text

    init(content: Content, text: Text) {
        self.content = content
        self.text = text
    }

    var body: some View {
        ResolvedHelpStyle(configuration: .init(text: text))
            .viewAlias(HelpStyleConfiguration.Content.self) {
                content
            }
    }
}

// MARK: - ResolvedHelpStyle

private struct ResolvedHelpStyle: StyleableView {
    var configuration: HelpStyleConfiguration

    static var defaultStyleModifier: HelpStyleModifier<DefaultHelpStyle> {
        .init(style: DefaultHelpStyle())
    }

    var body: some View {
        HelpView(content: configuration.content, text: configuration.text)
            .accessibility(AccessibilityProperties.HintsKey.self, [configuration.text])
    }
}

// MARK: - EmptyHelpStyle

private struct EmptyHelpStyle: HelpStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.content
    }
}

// MARK: - TooltipHelpStyle

private struct TooltipHelpStyle: HelpStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.content
            .modifier(TooltipModifier(text: configuration.text))
    }
}

// MARK: - DefaultHelpStyle

struct DefaultHelpStyle: HelpStyle, AnyDefaultStyle {
    func makeBody(configuration: Configuration) -> some View {
        HelpView(content: configuration.content, text: configuration.text)
            .helpStyle(TooltipHelpStyle())
            .helpStyle(EmptyHelpStyle())
    }
}

// MARK: - View + helpStyle

extension View {
    @inline(__always)
    func helpStyle<S>(_ style: S) -> some View where S: HelpStyle {
        modifier(HelpStyleModifier(style: style))
    }
}

// MARK: - HelpStyleModifier

struct HelpStyleModifier<S>: StyleModifier where S: HelpStyle {
    var style: S

    init(style: S) {
        self.style = style
    }

    func styleBody(configuration: HelpStyleConfiguration) -> some View {
        style.makeBody(configuration: configuration)
    }
}
