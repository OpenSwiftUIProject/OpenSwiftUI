//
//  Feature.swift
//  OpenSwiftUI
//
//  Created by Kyle on 2023/9/23.
//  Lastest Version: iOS 15.5
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
