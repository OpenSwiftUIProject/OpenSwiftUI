//
//  ButtonStyle.swift
//  OpenSwiftUI
//
//  Created by Kyle on 2023/9/21.
//  Lastest Version: iOS 15.5
//  Status: Complete

public protocol ButtonStyle {
    associatedtype Body: View
    
    @ViewBuilder
    func makeBody(configuration: Configuration) -> Self.Body
    
    typealias Configuration = ButtonStyleConfiguration
}
