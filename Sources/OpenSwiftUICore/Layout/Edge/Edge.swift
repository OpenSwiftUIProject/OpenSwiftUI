//
//  Edge.swift
//  OpenSwiftUICore
//
//  Audited for 6.0.87
//  Status: Complete

// MARK: - Edge

/// An enumeration to indicate one edge of a rectangle.
@frozen
public enum Edge: Int8, CaseIterable {
    case top, leading, bottom, trailing

    /// An efficient set of Edges.
    @frozen
    public struct Set: OptionSet {
        public typealias Element = Set

        public let rawValue: Int8

        public init(rawValue: Int8) {
            self.rawValue = rawValue
        }

        public static let top: Set = .init(.top)

        public static let leading: Set = .init(.leading)

        public static let bottom: Set = .init(.bottom)

        public static let trailing: Set = .init(.trailing)

        public static let all: Set = [.top, .leading, .bottom, .trailing]

        public static let horizontal: Set = [.leading, .trailing]

        public static let vertical: Set = [.top, .bottom]

        /// Creates an instance containing just e
        public init(_ e: Edge) {
            rawValue = 1 << e.rawValue
        }

        package func contains(_ edge: Edge) -> Bool {
            contains(.init(edge))
        }
    }
}

// MARK: - Edge + Extension

extension Edge {
    @_alwaysEmitIntoClient
    init(vertical edge: VerticalEdge) {
        self = Edge(rawValue: edge.rawValue << 1).unsafelyUnwrapped
    }

    package init(_vertical edge: VerticalEdge) {
        self.init(vertical: edge)
    }

    @_alwaysEmitIntoClient
    init(horizontal edge: HorizontalEdge) {
        self = Edge(rawValue: 1 &+ (edge.rawValue << 1)).unsafelyUnwrapped
    }

    package init(_horizontal edge: HorizontalEdge) {
        self.init(horizontal: edge)
    }
}

extension Edge {
    package var opposite: Edge {
        switch self {
        case .top: .bottom
        case .leading: .trailing
        case .bottom: .top
        case .trailing: .leading
        }
    }
}

extension Edge.Set {
    package init(_ axes: Axis.Set) {
        var set = Edge.Set()
        if axes.contains(.horizontal) {
            set.insert(.horizontal)
        }
        if axes.contains(.vertical) {
            set.insert(.vertical)
        }
        self = set
    }
}

// MARK: - HorizontalEdge

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
        public let rawValue: Int8

        public init(rawValue: Int8) { self.rawValue = rawValue }

        /// A set containing only the leading horizontal edge.
        public static let leading = Set(.leading)

        /// A set containing only the trailing horizontal edge.
        public static let trailing = Set(.trailing)

        /// A set containing the leading and trailing horizontal edges.
        public static let all: Set = [.leading, .trailing]

        /// Creates a set of edges containing only the specified horizontal edge.
        public init(_ edge: HorizontalEdge) { self.init(rawValue: 1 << edge.rawValue) }

        @inline(__always)
        package func contains(_ edge: HorizontalEdge) -> Bool { contains(.init(edge)) }
    }
}

// MARK: - VerticalEdge

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
        public let rawValue: Int8

        public init(rawValue: Int8) { self.rawValue = rawValue }
        
        /// A set containing only the top vertical edge.
        public static let top = Set(.top)

        /// A set containing only the bottom vertical edge.
        public static let bottom = Set(.bottom)

        /// A set containing the top and bottom vertical edges.
        public static let all: Set = [.top, .bottom]

        /// Creates a set of edges containing only the specified vertical edge.
        public init(_ e: VerticalEdge) { self.init(rawValue: 1 << e.rawValue) }

        @inline(__always)
        package func contains(_ e: VerticalEdge) -> Bool { contains(.init(e)) }
    }
}

// MARK: - CustomViewDebugValueConvertible

extension Edge.Set: CustomViewDebugValueConvertible {
    package var viewDebugValue: Any {
        var value: [Edge] = []
        if contains(.top) { value.append(.top) }
        if contains(.leading) { value.append(.leading) }
        if contains(.bottom) { value.append(.bottom) }
        if contains(.trailing) { value.append(.trailing) }
        return value
    }
}
