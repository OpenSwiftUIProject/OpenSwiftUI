//
//  TupleView.swift
//  OpenSwiftUI
//
//  Audited for iOS 15.5
//  Status: WIP
//  ID: 79611CB2B7848ECB3D9EC1F26B13F28F

@available(OpenSwiftUI_v1_0, *)
@frozen
public struct TupleView<T>: PrimitiveView {
    public var value: T
    @inlinable public init(_ value: T) { self.value = value }

    //  public static func _makeView(view: _GraphValue<TupleView<T>>, inputs: _ViewInputs) -> _ViewOutputs
    //  public static func _makeViewList(view: _GraphValue<TupleView<T>>, inputs: _ViewListInputs) -> _ViewListOutputs
    //  public static func _viewListCount(inputs: _ViewListCountInputs) -> Int?
    public typealias Body = Never
}

extension TupleView {
    private struct CountViews {}
    private struct MakeList {}
    private struct MakeUnary {}
}

@available(*, unavailable)
extension TupleView: Sendable {}
