//
//  PrimitiveView.swift
//  OpenSwiftUI
//
//  Audited for RELEASE_2021
//  Status: Complete

protocol PrimitiveView: View where Body == Never {}

extension PrimitiveView {
    public var body: Never {
        bodyError()
    }
}
