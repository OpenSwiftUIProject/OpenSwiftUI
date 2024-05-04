//
//  ViewModifier.swift
//  OpenSwiftUI
//
//  Audited for RELEASE_2021
//  Status: WIP

public protocol ViewModifier {
    associatedtype Body: View
    
    static func _makeView(
        modifier: _GraphValue<Self>,
        inputs: _ViewInputs,
        body: @escaping (_Graph, _ViewInputs) -> _ViewOutputs
    ) -> _ViewOutputs

    static func _makeViewList(
        modifier: _GraphValue<Self>,
        inputs: _ViewListInputs,
        body: @escaping (_Graph, _ViewListInputs) -> _ViewListOutputs
    ) -> _ViewListOutputs

    static func _viewListCount(
        inputs: _ViewListCountInputs,
        body: (_ViewListCountInputs) -> Int?
    ) -> Int?
    
    typealias Content = _ViewModifier_Content<Self>
    
    @ViewBuilder
    @MainActor(unsafe)
    func body(content: Content) -> Body
}

extension ViewModifier {
    public static func _makeView(
        modifier: _GraphValue<Self>,
        inputs: _ViewInputs,
        body: @escaping (_Graph, _ViewInputs) -> _ViewOutputs
    ) -> _ViewOutputs {
        makeView(modifier: modifier, inputs: inputs, body: body)
    }
    
    public static func _makeViewList(
        modifier: _GraphValue<Self>,
        inputs: _ViewListInputs,
        body: @escaping (_Graph, _ViewListInputs) -> _ViewListOutputs
    ) -> _ViewListOutputs {
        makeViewList(modifier: modifier, inputs: inputs, body: body)
    }

    public static func _viewListCount(
        inputs: _ViewListCountInputs,
        body: (_ViewListCountInputs) -> Int?
    ) -> Int? {
        viewListCount(inputs: inputs, body: body)
    }
}

extension ViewModifier where Body == Never {
    public func body(content _: Content) -> Never {
        bodyError()
    }
    //    static func _viewListCount(inputs: _ViewListCountInputs, body: (_ViewListCountInputs) -> Int?) -> Int?
}

extension ViewModifier {
    @inline(__always)
    func bodyError() -> Never {
        fatalError("body() should not be called on \(Self.self)")
    }
}
