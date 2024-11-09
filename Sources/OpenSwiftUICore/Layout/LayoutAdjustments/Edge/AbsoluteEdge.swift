//
//  AbsoluteEdge.swift
//  OpenSwiftUI
//
//  Audited for RELEASE_2024
//  Status: Complete

// MARK: - AbsoluteEdge

@frozen
public enum AbsoluteEdge: Int8, CaseIterable {
    case top
    case left
    case bottom
    case right

    var horizontal: Bool {
        self == .left || self == .right
    }

    var opposite: AbsoluteEdge {
        switch self {
        case .top: return .bottom
        case .left: return .right
        case .bottom: return .top
        case .right: return .left
        }
    }

    /// An efficient set of AbsoluteEdges.
    @frozen
    public struct Set: OptionSet {

        public let rawValue: Int8

        public init(rawValue: Int8) {
            self.rawValue = rawValue
        }

        public static let top = Set(.top)
        public static let left = Set(.left)
        public static let bottom = Set(.bottom)
        public static let right = Set(.right)
        public static let all: Set = [.top, .left, .bottom, .right]
        public static let horizontal: Set = [.left, .right]
        public static let vertical: Set = [.top, .bottom]

        public init(_ edge: AbsoluteEdge) { self.init(rawValue: 1 << edge.rawValue) }

        func contains(_ edge: AbsoluteEdge) -> Bool {
            contains(.init(edge))
        }

        init(_ edgeSet: Edge.Set, layoutDirection: LayoutDirection) {
            var set: Set = []
            if edgeSet.contains(.leading) {
                if layoutDirection == .leftToRight {
                    set.insert(.left)
                } else {
                    set.insert(.right)
                }
            }
            if edgeSet.contains(.trailing) {
                if layoutDirection == .leftToRight {
                    set.insert(.right)
                } else {
                    set.insert(.left)
                }
            }
            if edgeSet.contains(.top) {
                set.insert(.top)
            }
            if edgeSet.contains(.bottom) {
                set.insert(.bottom)
            }
            self = set
        }
    }
}