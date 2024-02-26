//
//  PrimitiveButtonStyle.swift
//  OpenSwiftUI
//
//  Audited for RELEASE_2021
//  Status: Complete

public protocol PrimitiveButtonStyle {
    associatedtype Body: View

    @ViewBuilder
    func makeBody(configuration: Configuration) -> Self.Body

    typealias Configuration = PrimitiveButtonStyleConfiguration
}
