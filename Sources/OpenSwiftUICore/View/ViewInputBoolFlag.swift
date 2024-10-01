//
//  ViewInputBoolFlag.swift
//  OpenSwiftUICore
//
//  Audited for RELEASE_2024
//  Status: WIP

// FIXME
package protocol ViewInputBoolFlag: GraphInput /*ViewInput, ViewInputFlag where Value == Bool*/ {}

extension ViewInputBoolFlag {
    @inlinable
    static var defaultValue: Bool { false }
    
    @inlinable
    static var value: Bool { true }
}
