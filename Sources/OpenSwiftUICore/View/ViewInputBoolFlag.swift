//
//  ViewInputBoolFlag.swift
//  OpenSwiftUICore
//
//  Audited for iOS 18.0
//  Status: WIP

// FIXME
package protocol ViewInputBoolFlag: GraphInput /*ViewInput, ViewInputFlag where Value == Bool*/ {}

extension ViewInputBoolFlag {
    @inlinable
    static var defaultValue: Bool { false }
    
    @inlinable
    static var value: Bool { true }
}
