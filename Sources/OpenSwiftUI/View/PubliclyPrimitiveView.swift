//
//  PubliclyPrimitiveView.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: 47701A835A1B253AFF3923CF965CEFD6 (SwiftUI)

import OpenAttributeGraphShims
@_spi(ForOpenSwiftUIOnly)
import OpenSwiftUICore

// MARK: - PubliclyPrimitiveView

protocol PubliclyPrimitiveView: PrimitiveView {
    associatedtype InternalBody: View

    @MainActor
    @preconcurrency
    var internalBody: InternalBody { get }
}

extension PubliclyPrimitiveView {
    nonisolated public static func _makeView(
        view: _GraphValue<Self>,
        inputs: _ViewInputs
    ) -> _ViewOutputs {
        defaultMakeView(view: view, inputs: inputs)
    }

    nonisolated static func defaultMakeView(
        view: _GraphValue<Self>,
        inputs: _ViewInputs
    ) -> _ViewOutputs {
        InternalBody._makeView(view: .init(MakeBody(view: view.value)), inputs: inputs)
    }

    nonisolated public static func _makeViewList(
        view: _GraphValue<Self>,
        inputs: _ViewListInputs
    ) -> _ViewListOutputs {
        defaultMakeViewList(view: view, inputs: inputs)
    }

    nonisolated static func defaultMakeViewList(
        view: _GraphValue<Self>,
        inputs: _ViewListInputs
    ) -> _ViewListOutputs {
        InternalBody._makeViewList(view: .init(MakeBody(view: view.value)), inputs: inputs)
    }

    nonisolated public static func _viewListCount(inputs: _ViewListCountInputs) -> Int? {
        defaultViewListCount(inputs: inputs)
    }

    nonisolated static func defaultViewListCount(inputs: _ViewListCountInputs) -> Int? {
        InternalBody._viewListCount(inputs: inputs)
    }
}

// MARK: - MakeBody

private struct MakeBody<V>: Rule where V: PubliclyPrimitiveView {
    @Attribute var view: V

    var value: V.InternalBody {
        view.internalBody
    }
}
