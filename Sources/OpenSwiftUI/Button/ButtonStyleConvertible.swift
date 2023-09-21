//
//  ButtonStyleConvertible.swift
//  OpenSwiftUI
//
//  Created by Kyle on 2023/9/21.
//  Lastest Version: iOS 15.5
//  Status: Complete

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
internal protocol ButtonStyleConvertible {
    associatedtype ButtonStyleRepresentation: ButtonStyle
    
    var buttonStyleRepresentation: ButtonStyleRepresentation { get }
}
