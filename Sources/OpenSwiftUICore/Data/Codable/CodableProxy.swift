//
//  CodableProxy.swift
//  OpenSwiftUI
//
//  Audited for iOS 15.5
//  Status: Complete

protocol CodableProxy: Codable {
    associatedtype Base
    var base: Base { get }
}

protocol CodableByProxy {
    associatedtype CodingProxy: Codable
    var codingProxy: CodingProxy { get }

    static func unwrap(codingProxy: CodingProxy) -> Self
}
