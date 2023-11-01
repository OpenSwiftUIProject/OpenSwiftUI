//
//  CodableProxy.swift
//  OpenSwiftUI
//
//  Created by Kyle on 2023/10/8.
//  Lastest Version: iOS 15.5
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
