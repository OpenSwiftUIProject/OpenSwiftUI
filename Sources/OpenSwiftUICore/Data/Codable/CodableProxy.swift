//
//  CodableProxy.swift
//  OpenSwiftUI
//
//  Audited for RELEASE_2021
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
