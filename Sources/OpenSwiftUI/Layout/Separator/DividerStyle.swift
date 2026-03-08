//
//  DividerStyle.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete

public import OpenSwiftUICore

// MARK: - DividerStyle

@_spi(Private)
@available(OpenSwiftUI_v3_0, *)
@MainActor
@preconcurrency
public protocol DividerStyle {
    associatedtype Body: View

    @ViewBuilder
    func makeBody(configuration: Configuration) -> Body

    typealias Configuration = DividerStyleConfiguration
}

// MARK: - DividerStyleConfiguration

@_spi(Private)
@available(OpenSwiftUI_v3_0, *)
public struct DividerStyleConfiguration {
    public var orientation: Axis
}

@_spi(Private)
@available(*, unavailable)
extension DividerStyleConfiguration: Sendable {}

// MARK: - ResolvedDivider

struct ResolvedDivider: StyleableView {
    static var defaultStyleModifier: DividerStyleModifier = .init(style: .default)

    var configuration: DividerStyleConfiguration
}

// MARK: - DividerStyleModifier

@_spi(Private)
@available(OpenSwiftUI_v3_0, *)
extension View {
    nonisolated public func dividerStyle<S>(_ style: S) -> some View where S: DividerStyle {
        modifier(DividerStyleModifier(style: style))
    }
}

struct DividerStyleModifier<S>: StyleModifier where S: DividerStyle {
    var style: S

    init(style: S) {
        self.style = style
    }

    func styleBody(configuration: DividerStyleConfiguration) -> some View {
        style.makeBody(configuration: configuration)
    }
}
