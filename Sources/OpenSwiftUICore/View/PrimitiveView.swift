//
//  PrimitiveView.swift
//  OpenSwiftUI
//
//  Audited for iOS 15.5
//  Status: Complete

package protocol PrimitiveView: View where Body == Never {}

extension PrimitiveView {
    public var body: Never {
        bodyError()
    }
}
