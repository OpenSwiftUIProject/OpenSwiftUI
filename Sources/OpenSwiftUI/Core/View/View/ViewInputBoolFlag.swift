//
//  ViewInputBoolFlag.swift
//  OpenSwiftUI
//
//  Audited for RELEASE_2021
//  Status: Empty

protocol ViewInputBoolFlag: ViewInput, ViewInputFlag where Value == Bool, Input == Self {}

extension ViewInputBoolFlag {
    static var defaultValue: Bool { false }
    static var value: Bool { true }
}
