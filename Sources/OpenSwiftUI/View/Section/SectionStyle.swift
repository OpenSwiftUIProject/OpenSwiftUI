//
//  SectionStyle.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete

import OpenSwiftUICore

// MARK: - SectionStyle

protocol SectionStyle {
    associatedtype Body: View

    @ViewBuilder
    func makeBody(configuration: Configuration) -> Body

    typealias Configuration = SectionStyleConfiguration
}

extension View {
    nonisolated func sectionStyle<S>(_ style: S) -> some View where S: SectionStyle {
        modifier(SectionStyleModifier(style: style))
    }

    nonisolated func sectionStyle<S, C>(_ style: S, in context: C) -> some View where S: SectionStyle, C: StyleContext {
        modifier(SectionStyleModifier(style: style).requiring(C.self))
    }
}

// MARK: - SectionStyleConfiguration

struct SectionStyleConfiguration {
    struct Header: ViewAlias {}
    struct Footer: ViewAlias {}
    struct Actions: ViewAlias {}
    struct RawContent: ViewAlias {}

    let header: Header = .init()
    let footer: Footer = .init()
    var actions: Actions = .init()
    let rawContent: RawContent = .init()
    var isExpanded: Binding<Bool>?

    @ViewBuilder
    var content: some View {
        if isExpanded?.wrappedValue ?? true {
            rawContent
        }
    }
}

// MARK: - ResolvedSectionStyle

struct ResolvedSectionStyle: StyleableView {
    var configuration: SectionStyleConfiguration

    static var defaultStyleModifier: SectionStyleModifier<DefaultSectionStyle> {
        .init(style: DefaultSectionStyle())
    }
}

// MARK: - SectionStyleModifier

struct SectionStyleModifier<S>: StyleModifier where S: SectionStyle {
    var style: S

    init(style: S) {
        self.style = style
    }

    func styleBody(configuration: SectionStyleConfiguration) -> some View {
        style.makeBody(configuration: configuration)
            ._trait(IsExpandedTraitKey.self, configuration.isExpanded)
    }
}
