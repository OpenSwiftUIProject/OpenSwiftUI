//
//  ButtonStyleConvertible.swift
//  OpenSwiftUI
//
//  Audited for RELEASE_2021
//  Status: Complete

internal protocol ButtonStyleConvertible {
    associatedtype ButtonStyleRepresentation: ButtonStyle
    
    var buttonStyleRepresentation: ButtonStyleRepresentation { get }
}
