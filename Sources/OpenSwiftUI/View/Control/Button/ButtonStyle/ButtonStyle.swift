//
//  ButtonStyle.swift
//  OpenSwiftUI
//
//  Audited for iOS 15.5
//  Status: Complete

public protocol ButtonStyle {
    associatedtype Body: View
    
    @ViewBuilder
    func makeBody(configuration: Configuration) -> Self.Body
    
    typealias Configuration = ButtonStyleConfiguration
}
