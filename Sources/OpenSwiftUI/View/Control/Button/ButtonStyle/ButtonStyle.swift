//
//  ButtonStyle.swift
//  OpenSwiftUI
//
//  Audited for 3.5.2
//  Status: Complete

public protocol ButtonStyle {
    associatedtype Body: View
    
    @ViewBuilder
    func makeBody(configuration: Configuration) -> Self.Body
    
    typealias Configuration = ButtonStyleConfiguration
}
