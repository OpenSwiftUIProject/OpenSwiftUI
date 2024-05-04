//
//  Feature.swift
//  OpenSwiftUI
//
//  Audited for RELEASE_2021
//  Status: Complete

protocol Feature: ViewInputBoolFlag {
    static var isEnable: Bool { get }
}

extension Feature {
    static var defaultValue: Bool { isEnable }
}
