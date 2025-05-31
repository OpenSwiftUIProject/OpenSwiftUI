//
//  GeometryReader.swift
//  OpenSwiftUICore
//
//  Status: WIP

extension UnaryLayout where Self.PlacementContextType == _PositionAwarePlacementContext {
    package static func makeViewImpl(
        modifier: _GraphValue<Self>,
        inputs: _ViewInputs,
        body: @escaping (_Graph, _ViewInputs) -> _ViewOutputs
    ) -> _ViewOutputs {
        preconditionFailure("TODO")
    }
}

extension UnaryLayout where Self.PlacementContextType == PlacementContext {
    package static func makeViewImpl(
        modifier: _GraphValue<Self>,
        inputs: _ViewInputs,
        body: @escaping (_Graph, _ViewInputs) -> _ViewOutputs
    ) -> _ViewOutputs {
        preconditionFailure("TODO")
    }
}
