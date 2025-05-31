//
//  Direction.swift
//  OpenSwiftUICore
//
//  Status: Complete

// MARK: - HorizontalDirection [6.4.41]

/// A direction on the horizontal axis.
@frozen
public enum HorizontalDirection: Int8, CaseIterable, Codable {
    /// The leading direction.
    case leading

    /// The trailing direction.
    case trailing

    /// An efficient set of horizontal directions.
    @frozen
    public struct Set: OptionSet, Equatable, Hashable {
        public let rawValue: Int8

        public init(rawValue: Int8) {
            self.rawValue = rawValue
        }

        /// A set containing only the leading horizontal direction.
        public static let leading: HorizontalDirection.Set = .init(.leading)

        /// A set containing only the trailing horizontal direction.
        public static let trailing: HorizontalDirection.Set = .init(.trailing)

        /// A set containing the leading and trailing horizontal directions.
        public static let all: HorizontalDirection.Set = [.leading, .trailing]

        /// Creates a set of directions containing only the specified direction.
        public init(_ direction: HorizontalDirection) {
            rawValue = 1 << direction.rawValue
        }
    }
}

// MARK: - VerticalDirection [6.4.41]

/// A direction on the vertical axis.
@frozen
public enum VerticalDirection: Int8, CaseIterable, Codable {
    /// The upward direction.
    case up

    /// The downward direction.
    case down

    /// An efficient set of vertical directions.
    @frozen
    public struct Set: OptionSet {
        public let rawValue: Int8

        public init(rawValue: Int8) {
            self.rawValue = rawValue
        }

        /// A set containing only the upward vertical direction.
        public static let up: VerticalDirection.Set = .init(.up)

        /// A set containing only the downward vertical direction.
        public static let down: VerticalDirection.Set = .init(.down)

        /// A set containing the upward and downward vertical directions.
        public static let all: VerticalDirection.Set = [.up, .down]

        /// Creates a set of directions containing only the specified direction.
        public init(_ direction: VerticalDirection) {
            rawValue = 1 << direction.rawValue
        }
    }
}
