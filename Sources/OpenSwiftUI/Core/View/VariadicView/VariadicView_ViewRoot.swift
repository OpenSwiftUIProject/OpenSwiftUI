//
//  VariadicView_ImplicitRoot.swift
//  OpenSwiftUI
//
//  Audited for RELEASE_2021
//  Status: WIP
//  ID: 00F12C0E37A19C593ECA0DBD3BE26541

internal import OpenGraphShims

/// A type of root that creates a `View` when its result builder is invoked with
///  `View`.
/// - SeeAlso: _VariadicView.ViewRoot.
/// - Note: Requirements mirror `View`'s.
public protocol _VariadicView_ViewRoot: _VariadicView_Root {
    associatedtype Body: View

    static func _makeView(
        root: _GraphValue<Self>,
        inputs: _ViewInputs,
        body: (_Graph, _ViewInputs) -> _ViewListOutputs
    ) -> _ViewOutputs
    
    static func _makeViewList(
        root: _GraphValue<Self>,
        inputs: _ViewListInputs,
        body: @escaping (_Graph, _ViewListInputs) -> _ViewListOutputs
    ) -> _ViewListOutputs
    
    static func _viewListCount(
        inputs: _ViewListCountInputs,
        body: (_ViewListCountInputs) -> Int?
    ) -> Int?
    
    @ViewBuilder
    func body(children: _VariadicView.Children) -> Body
}

extension _VariadicView_ViewRoot {
    public static func _makeView(
        root: _GraphValue<Self>,
        inputs: _ViewInputs,
        body: (_Graph, _ViewInputs) -> _ViewListOutputs
    ) -> _ViewOutputs {
        fatalError("TODO")
    }
    
    public static func _makeViewList(
        root: _GraphValue<Self>,
        inputs: _ViewListInputs,
        body: @escaping (_Graph, _ViewListInputs) -> _ViewListOutputs
    ) -> _ViewListOutputs {
        fatalError("TODO")
    }
    
    public static func _viewListCount(inputs: _ViewListCountInputs) -> Int? {
        Body._viewListCount(inputs: inputs)
    }
}


// MARK: - ViewRootBody

private struct ViewRootBody<Root> {
    @Attribute var root: Root
    @Attribute var list: ViewList
    let contentSubgraph: OGSubgraph
}

extension _ViewInputs {
    private struct ImplicitRootType: ViewInput {
        static let defaultValue: _VariadicView_AnyImplicitRoot.Type = _VStackLayout.self
    }
}

extension View {
    static func makeImplicitRoot(view: _GraphValue<Self>, inputs: _ViewInputs) -> _ViewOutputs {
        // TODO
        return .init()
    }
}

// TODO: ViewModifier
