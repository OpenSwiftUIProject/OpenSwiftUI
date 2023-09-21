//
//  ButtonStyleConvertible.swift
//  OpenSwiftUI
//
//  Created by Kyle on 2023/9/21.
//  Lastest Version: iOS 15.5
//  Status: Complete

internal protocol ButtonStyleConvertible {
    associatedtype ButtonStyleRepresentation: ButtonStyle
    
    var buttonStyleRepresentation: ButtonStyleRepresentation { get }
}
