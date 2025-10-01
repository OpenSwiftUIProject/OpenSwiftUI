//
//  CodableProxy.swift
//  OpenSwiftUICore
//
//  Audited for 6.0.87
//  Status: WIP

package protocol CodableByProxy {
    associatedtype CodingProxy: Codable
    var codingProxy: CodingProxy { get }

    static func unwrap(codingProxy: CodingProxy) -> Self
}

package protocol CodableProxy: Codable {
    associatedtype Base
    var base: Base { get }
}

extension CodableByProxy where Self == CodingProxy.Base, CodingProxy: CodableProxy {
    package static func unwrap(codingProxy: CodingProxy) -> Self {
        codingProxy.base
    }
}
