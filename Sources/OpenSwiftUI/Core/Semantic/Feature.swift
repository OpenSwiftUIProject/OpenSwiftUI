//
//  Feature.swift
//  OpenSwiftUI
//
//  Audited for RELEASE_2021
//  Status: Complete

protocol Feature: ViewInputBoolFlag {
    @inline(__always)
    static var isEnable: Bool { get }
}

extension Feature {
    // FIXME: Mark inline to the protocol requirement of defaultValue
    @inline(__always)
    static var defaultValue: Bool {
        isEnable
    }
}
