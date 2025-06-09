//
//  ViewPlatformOutputs.swift
//  OpenSwiftUICore
//
//  Audited for 6.4.41
//  Status: Complete

extension _ViewOutputs {
    package static func makePlatformRootGeometryTransform(
        inputs: _ViewInputs,
        body: (_ViewInputs) -> _ViewOutputs
    ) -> _ViewOutputs {
        body(inputs)
    }
}

extension _VariadicView.Tree where Root: _VariadicView_ViewRoot, Content: View {
    @inline(__always)
    package static func makePlatformSubstitutableView(
        view: _GraphValue<Self>,
        inputs: _ViewInputs
    ) -> _ViewOutputs {
        makeDebuggableView(view: view, inputs: inputs)
    }
}

protocol ZStackParameterSmuggle {
    static func makeParameterSmuggledZStackView<Content>(
        view: _GraphValue<_VariadicView.Tree<_ZStackLayout, Content>>,
        inputs: _ViewInputs
    ) -> _ViewOutputs where Content: View
}

extension _VariadicView.Tree where Root == _ZStackLayout, Content: View {
    @inline(__always)
    package static func makePlatformSubstitutableView(
        view: _GraphValue<Self>,
        inputs: _ViewInputs
    ) -> _ViewOutputs {
        if let conformance = Content.self as? any ZStackParameterSmuggle.Type {
            conformance.makeParameterSmuggledZStackView(
                view: view,
                inputs: inputs)
        } else {
            makeDebuggableView(view: view, inputs: inputs)
        }
    }
}

package func makePlatformSecondaryView(
    primaryInputs: _ViewInputs,
    primaryOutputs: _ViewOutputs,
    secondaryInputs: _ViewInputs,
    flipOrder: Bool,
    body: @escaping (_Graph, _ViewInputs) -> _ViewOutputs
) -> _ViewOutputs {
    body(_Graph(), secondaryInputs)
}
