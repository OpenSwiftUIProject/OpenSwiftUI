//
//  ViewListInputs.swift
//  OpenSwiftUI
//
//  Audited for RELEASE_2021
//  Status: WIP

internal import OpenGraphShims

public struct _ViewListInputs {
    private var base: _GraphInputs
    var implicitID: Int
    var options: _ViewListInputs.Options
    @OptionalAttribute
    var traits: ViewTraitCollection?
    var traitKeys: ViewTraitKeys?
    
    struct Options: OptionSet {
        let rawValue: Int
    }
    
    // MARK: - base
    
    @inline(__always)
    mutating func withMutateGraphInputs<R>(_ body: (inout _GraphInputs) -> R) -> R {
        body(&base)
    }
}
