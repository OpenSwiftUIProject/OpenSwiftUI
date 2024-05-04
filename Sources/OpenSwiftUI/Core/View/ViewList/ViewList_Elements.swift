//
//  ViewList_Elements.swift
//  OpenSwiftUI
//
//  Audited for RELEASE_2021
//  Status: WIP

protocol _ViewList_Elements {
    var count: Int { get }
    func makeElements(
        from: inout Int,
        inputs: _ViewInputs,
        indirectMap: _ViewList_IndirectMap?,
        body: (_ViewInputs, (_ViewInputs) -> _ViewOutputs) -> (_ViewOutputs?, Bool)
    ) -> (_ViewOutputs?, Bool)
    func tryToReuseElement(at: Int, by: _ViewList_Elements, at: Int, indirectMap: _ViewList_IndirectMap, testOnly: Bool) -> Bool
    func retain() -> () -> Void
}
