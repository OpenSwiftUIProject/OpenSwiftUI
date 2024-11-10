//
//  AbsoluteEdge.swift
//  OpenSwiftUICore
//
//  Audited for iOS 18.0
//  Status: Complete

package enum AbsoluteEdge: Int8, CaseIterable, Hashable {
    case top, left, bottom, right
    
    package struct Set: OptionSet {
        package let rawValue: Int8
        package init(rawValue: Int8) { self.rawValue = rawValue }
        package static let top: AbsoluteEdge.Set = .init(.top)
        package static let left: AbsoluteEdge.Set = .init(.left)
        package static let bottom: AbsoluteEdge.Set = .init(.bottom)
        package static let right: AbsoluteEdge.Set = .init(.right)
        package static let all: AbsoluteEdge.Set = [.top, .left, .bottom, .right]
        package static let horizontal: AbsoluteEdge.Set = [.left, .right]
        package static let vertical: AbsoluteEdge.Set = [.top, .bottom]
        package init(_ e: AbsoluteEdge) {
            self.init(rawValue: 1 << e.rawValue)
        }
        package func contains(_ e: AbsoluteEdge) -> Bool {
            self.contains(.init(e))
        }
    }
}

extension AbsoluteEdge.Set {
    package init(_ edges: Edge.Set, layoutDirection: LayoutDirection) {
        var result: AbsoluteEdge.Set = []
        if edges.contains(.top) {
            result.insert(.top)
        }
        if edges.contains(.leading) {
            switch layoutDirection {
            case .leftToRight: result.insert(.left)
            case .rightToLeft: result.insert(.right)
            }
        }
        if edges.contains(.bottom) {
            result.insert(.bottom)
        }
        if edges.contains(.trailing) {
            switch layoutDirection {
            case .leftToRight: result.insert(.right)
            case .rightToLeft: result.insert(.left)
            }
        }
        self = result
    }
}

extension AbsoluteEdge {
    package var horizontal: Bool {
        self == .left || self == .right
    }
    
    package var opposite: AbsoluteEdge {
        switch self {
        case .top: .bottom
        case .left: .right
        case .bottom: .top
        case .right: .left
        }
    }
}
