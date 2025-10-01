//
//  ButtonStyleConvertible.swift
//  OpenSwiftUI
//
//  Audited for 3.5.2
//  Status: Complete

internal protocol ButtonStyleConvertible {
    associatedtype ButtonStyleRepresentation: ButtonStyle
    
    var buttonStyleRepresentation: ButtonStyleRepresentation { get }
}
