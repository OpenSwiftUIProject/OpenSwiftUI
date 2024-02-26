//
//  ButtonStyle.swift
//  OpenSwiftUI
//
//  Audited for RELEASE_2021
//  Status: Complete

public protocol ButtonStyle {
    associatedtype Body: View
    
    @ViewBuilder
    func makeBody(configuration: Configuration) -> Self.Body
    
    typealias Configuration = ButtonStyleConfiguration
}
