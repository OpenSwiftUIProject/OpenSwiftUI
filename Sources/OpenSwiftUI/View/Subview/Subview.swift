//
//  Subview.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete

@_spi(ForOpenSwiftUIOnly) public import OpenSwiftUICore

@_spi(DoNotImportVariadicView)
extension Subview {
    @available(*, deprecated, renamed: "containerValues")
    public var traits: TraitValues {
        TraitValues(base: base.traits)
    }
}
