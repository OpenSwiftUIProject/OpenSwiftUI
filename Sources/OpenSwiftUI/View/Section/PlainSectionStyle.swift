//
//  PlainSectionStyle.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: 4F6C9EDF4B4BD8C3129AFB2C853C1F78 (SwiftUI)

import OpenAttributeGraphShims
@_spi(ForOpenSwiftUIOnly)
import OpenSwiftUICore

// MARK: - SectionContainer

private struct SectionContainer: _VariadicView.MultiViewRoot {
    var parent: SectionStyleConfiguration.Header
    var footer: SectionStyleConfiguration.Footer

    nonisolated static func _makeViewList(
        root: _GraphValue<Self>,
        inputs: _ViewListInputs,
        body: @escaping (_Graph, _ViewListInputs) -> _ViewListOutputs
    ) -> _ViewListOutputs {
        .groupViewList(
            parent: root[offset: { .of(&$0.parent) }],
            footer: root[offset: { .of(&$0.footer) }].value,
            inputs: inputs,
            body: body
        )
    }
}

// MARK: - PlainSectionStyle

struct PlainSectionStyle: SectionStyle {
    func makeBody(configuration: Configuration) -> some View {
        StyledView(configuration: configuration)
    }
}

// MARK: - StyledView

private struct StyledView: PrimitiveView, MultiView {
    var configuration: SectionStyleConfiguration

    nonisolated static func _makeViewList(
        view: _GraphValue<Self>,
        inputs: _ViewListInputs
    ) -> _ViewListOutputs {
        SectionBody.Value._makeViewList(
            view: .init(SectionBody(view: view.value)),
            inputs: inputs
        )
    }

    nonisolated static func _viewListCount(inputs: _ViewListCountInputs) -> Int? {
        _ViewListOutputs.groupViewListCount(
            inputs: inputs,
            contentType: _ConditionalContent<SectionStyleConfiguration.RawContent, EmptyView>.self,
            headerType: SectionStyleConfiguration.Header.self,
            footerType: SectionStyleConfiguration.Footer.self
        )
    }
}

// MARK: - SectionBody

private struct SectionBody: Rule {
    @Attribute var view: StyledView

    var value: some View {
        _VariadicView.Tree(
            SectionContainer(parent: view.configuration.header, footer: view.configuration.footer)
        ) {
            view.configuration.content
        }
    }
}
