//
//  ViewPlatformOutputs.swift
//  OpenSwiftUICore
//
//  Audited for 6.4.41
//  Status: WIP

extension _ViewOutputs {
    package static func makePlatformRootGeometryTransform(
        inputs: _ViewInputs,
        bodys: (_ViewInputs) -> _ViewOutputs
    ) -> _ViewOutputs {
        preconditionFailure("TODO")
    }
}

extension _VariadicView.Tree where Root: _VariadicView_ViewRoot, Content: View {
    @inline(__always)
    package static func makePlatformSubstitutableView(
        view: _GraphValue<_VariadicView.Tree<Root, Content>>,
        inputs: _ViewInputs
    ) -> _ViewOutputs {
        preconditionFailure("TODO")
    }
}

package func makePlatformSecondaryView(
    primaryInputs: _ViewInputs,
    primaryOutputs: _ViewOutputs,
    secondaryInputs: _ViewInputs,
    flipOrder: Bool,
    body: @escaping (_Graph, _ViewInputs) -> _ViewOutputs
) -> _ViewOutputs {
    preconditionFailure("TODO")
}
