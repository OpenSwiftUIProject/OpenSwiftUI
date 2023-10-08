//
//  PrimitiveView.swift
//  OpenSwiftUI
//
//  Created by Kyle on 2023/9/21.
//  Lastest Version: iOS 15.5
//  Status: Complete

protocol PrimitiveView: View where Body == Never {}

extension PrimitiveView {
    public var body: Never {
        bodyError()
    }
}
