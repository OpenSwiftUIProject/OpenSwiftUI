//
//  Edge.swift
//  OpenSwiftUI
//
//  Created by Kyle on 2023/10/8.
//  Lastest Version: iOS 15.5
//  Status: Complete

// MARK: - Edge

@frozen
public enum Edge: Int8, CaseIterable {
    case top, leading, bottom, trailing
    @frozen
    public struct Set: OptionSet {
        public typealias Element = Set

        public let rawValue: Int8

        @inline(__always)
        public init(rawValue: Int8) { self.rawValue = rawValue }

        public static let top = Set(.top)
        public static let leading = Set(.leading)
        public static let bottom = Set(.bottom)
        public static let trailing = Set(.trailing)
        public static let all: Set = [.top, .leading, .bottom, .trailing]
        public static let horizontal: Set = [.leading, .trailing]
        public static let vertical: Set = [.top, .bottom]

        @inline(__always)
        public init(_ e: Edge) { self.init(rawValue: 1 << e.rawValue) }

        @inline(__always)
        func contains(_ edge: Edge) -> Bool {
            contains(.init(edge))
        }
    }
}

// MARK: Edge + CodableByProxy

extension Edge: CodableByProxy {
    var codingProxy: Int8 { rawValue }

    static func unwrap(codingProxy: Int8) -> Edge {
        Edge(rawValue: codingProxy) ?? .top
    }
}

// MARK: - HorizontalEdge and VerticalEdge

@frozen
public enum HorizontalEdge: Int8, CaseIterable, Codable {
    case leading
    case trailing
    @frozen public struct Set: OptionSet {
        public typealias Element = Set
        public let rawValue: Int8
        public init(rawValue: Int8) { self.rawValue = rawValue }
        public static let leading = Set(.leading)
        public static let trailing = Set(.trailing)
        public static let all: Set = [.leading, .trailing]

        public init(_ e: HorizontalEdge) { self.init(rawValue: 1 << e.rawValue) }

        @inline(__always)
        func contains(_ edge: HorizontalEdge) -> Bool { contains(.init(edge)) }
    }
}

@frozen
public enum VerticalEdge: Int8, CaseIterable, Codable {
    case top
    case bottom
    @frozen public struct Set: OptionSet {
        public typealias Element = Set
        public let rawValue: Int8
        public init(rawValue: Int8) { self.rawValue = rawValue }
        public static let top = Set(.top)
        public static let bottom = Set(.bottom)
        public static let all: Set = [.top, .bottom]

        public init(_ e: VerticalEdge) { self.init(rawValue: 1 << e.rawValue) }

        @inline(__always)
        func contains(_ edge: VerticalEdge) -> Bool { contains(.init(edge)) }
    }
}

extension Edge {
    @_alwaysEmitIntoClient
    init(vertical edge: VerticalEdge) {
        self = Edge(rawValue: edge.rawValue << 1).unsafelyUnwrapped
    }

    @_alwaysEmitIntoClient
    init(horizontal edge: HorizontalEdge) {
        self = Edge(rawValue: 1 &+ (edge.rawValue << 1)).unsafelyUnwrapped
    }
}

// MARK: - Sendable

extension Edge: Sendable {}
extension Edge.Set: Sendable {}
extension HorizontalEdge: Sendable {}
extension HorizontalEdge.Set: Sendable {}
extension VerticalEdge: Sendable {}
extension VerticalEdge.Set: Sendable {}
