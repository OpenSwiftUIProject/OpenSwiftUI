//
//  Edge.swift
//  OpenSwiftUI
//
//  Audited for iOS 15.5
//  Status: Complete

// MARK: - Edge

/// An enumeration to indicate one edge of a rectangle.
@frozen
public enum Edge: Int8, CaseIterable {
    case top
    case leading
    case bottom
    case trailing

    /// An efficient set of Edges.
    @frozen
    public struct Set: OptionSet {
        public typealias Element = Set

        public let rawValue: Int8

        public init(rawValue: Int8) {
            self.rawValue = rawValue
        }

        public static let top = Set(.top)
        public static let leading = Set(.leading)
        public static let bottom = Set(.bottom)
        public static let trailing = Set(.trailing)
        public static let all: Set = [.top, .leading, .bottom, .trailing]
        public static let horizontal: Set = [.leading, .trailing]
        public static let vertical: Set = [.top, .bottom]

        /// Creates an instance containing just e
        public init(_ e: Edge) { self.init(rawValue: 1 << e.rawValue) }

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

/// An edge on the horizontal axis.
///
/// Use a horizontal edge for tasks like setting a swipe action with the
/// ``View/swipeActions(edge:allowsFullSwipe:content:)``
/// view modifier. The positions of the leading and trailing edges
/// depend on the locale chosen by the user.
@frozen
public enum HorizontalEdge: Int8, CaseIterable, Codable {
    /// The leading edge.
    case leading

    /// The trailing edge.
    case trailing

    /// An efficient set of `HorizontalEdge`s.
    @frozen
    public struct Set: OptionSet {
        public typealias Element = Set
        public let rawValue: Int8
        public init(rawValue: Int8) { self.rawValue = rawValue }

        /// A set containing only the leading horizontal edge.
        public static let leading = Set(.leading)

        /// A set containing only the trailing horizontal edge.
        public static let trailing = Set(.trailing)

        /// A set containing the leading and trailing horizontal edges.
        public static let all: Set = [.leading, .trailing]

        /// Creates an instance containing just `e`.
        public init(_ e: HorizontalEdge) { self.init(rawValue: 1 << e.rawValue) }

        @inline(__always)
        func contains(_ edge: HorizontalEdge) -> Bool { contains(.init(edge)) }
    }
}

/// An edge on the vertical axis.
@frozen
public enum VerticalEdge: Int8, CaseIterable, Codable {
    /// The top edge.
    case top

    /// The bottom edge.
    case bottom

    /// An efficient set of `VerticalEdge`s.
    @frozen
    public struct Set: OptionSet {
        public typealias Element = Set
        public let rawValue: Int8
        public init(rawValue: Int8) { self.rawValue = rawValue }
        
        /// A set containing only the top vertical edge.
        public static let top = Set(.top)

        /// A set containing only the bottom vertical edge.
        public static let bottom = Set(.bottom)

        /// A set containing the top and bottom vertical edges.
        public static let all: Set = [.top, .bottom]

        /// Creates an instance containing just `e`
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
