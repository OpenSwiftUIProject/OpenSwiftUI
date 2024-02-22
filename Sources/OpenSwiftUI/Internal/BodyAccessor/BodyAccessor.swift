//
//  BodyAccessor.swift
//  OpenSwiftUI
//
//  Created by Kyle on 2024/2/21.
//  Lastest Version: iOS 15.5
//  Status: Complete

protocol BodyAccessor<Container, Body> {
    associatedtype Container
    associatedtype Body
    func updateBody(of: Container, changed: Bool)
}
