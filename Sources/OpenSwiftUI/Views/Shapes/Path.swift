//
//  Path.swift
//  OpenSwiftUI
//
//  Created by Kyle on 2023/10/10.
//  Lastest Version: iOS 15.5
//  Status: WIP
//  ID: 31FD92B70C320DDD253E93C7417D779A

// MARK: - Path[Empty]

/// The outline of a 2D shape.
public struct Path {}

// MARK: - CodablePath[WIP]

struct CodablePath: CodableProxy {
    var base: Path

    private enum Error: Swift.Error {
        case invalidPath
    }

    private enum CodingKind: UInt8, Codable {
        case empty
        case rect
        case ellipse
        case roundedRect
        case stroked
        case trimmed
        case data
    }

    private enum CodingKeys: Hashable, CodingKey {
        case kind
        case value
    }

    // TODO:
    func encode(to _: Encoder) throws {}

    // TODO:
    init(from _: Decoder) throws {
        base = Path()
    }

    @inline(__always)
    init(base: Path) {
        self.base = base
    }
}

// MARK: - Path + CodableByProxy

extension Path: CodableByProxy {
    var codingProxy: CodablePath { CodablePath(base: self) }

    static func unwrap(codingProxy: CodablePath) -> Path { codingProxy.base }
}
