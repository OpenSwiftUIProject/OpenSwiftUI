//
//  BodyAccessor.swift
//  OpenSwiftUI
//
//  Audited for RELEASE_2021
//  Status: Complete

protocol BodyAccessor<Container, Body> {
    associatedtype Container
    associatedtype Body
    func updateBody(of: Container, changed: Bool)
}
