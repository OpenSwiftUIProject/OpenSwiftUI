//
//  ViewListInputs.swift
//  OpenSwiftUI
//
//  Audited for RELEASE_2021
//  Status: WIP

internal import OpenGraphShims

public struct _ViewListInputs {
    var base: _GraphInputs
    var implicitID: Int
    var options: _ViewListInputs.Options
    @OptionalAttribute
    var traits: ViewTraitCollection?
    var traitKeys: ViewTraitKeys?
    
    struct Options: OptionSet {
        let rawValue: Int
    }
}
