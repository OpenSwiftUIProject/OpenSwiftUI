//
//  ButtonStyleConvertible.swift
//  OpenSwiftUI
//
//  Audited for iOS 15.5
//  Status: Complete

internal protocol ButtonStyleConvertible {
    associatedtype ButtonStyleRepresentation: ButtonStyle
    
    var buttonStyleRepresentation: ButtonStyleRepresentation { get }
}
