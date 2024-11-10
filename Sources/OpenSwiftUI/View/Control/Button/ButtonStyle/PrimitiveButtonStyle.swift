//
//  PrimitiveButtonStyle.swift
//  OpenSwiftUI
//
//  Audited for iOS 15.5
//  Status: Complete

public protocol PrimitiveButtonStyle {
    associatedtype Body: View

    @ViewBuilder
    func makeBody(configuration: Configuration) -> Self.Body

    typealias Configuration = PrimitiveButtonStyleConfiguration
}
