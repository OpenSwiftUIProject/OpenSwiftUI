//
//  Axis.swift
//  OpenSwiftUICore
//
//  Audited for 6.0.87
//  Status: Complete

package import Foundation

/// The horizontal or vertical dimension in a 2D coordinate system.
@frozen
public enum Axis: Int8, CaseIterable {
    /// The horizontal dimension.
    case horizontal
    
    /// The vertical dimension.
    case vertical
    
    package init(edge: Edge) {
        switch edge {
            case .leading, .trailing: self = .horizontal
            case .top, .bottom: self = .vertical
        }
    }
    
    @inlinable
    package var otherAxis: Axis {
        self == .horizontal ? .vertical : .horizontal
    }
    
    @inlinable
    package var perpendicularEdges: (min: Edge, max: Edge) {
        self == .vertical ? (.top, .bottom) : (.leading, .trailing)
    }
    
    /// An efficient set of axes.
    @frozen
    public struct Set: OptionSet {
        public let rawValue: Int8

        public init(rawValue: Int8) {
            self.rawValue = rawValue
        }

        public static let horizontal: Axis.Set = Set(.horizontal)
        public static let vertical: Axis.Set = Set(.vertical)
        package static let both: Axis.Set = [.horizontal, .vertical]
        
        package init(_ a: Axis) {
            self.init(rawValue: 1 << a.rawValue)
        }
        
        package func contains(_ a: Axis) -> Bool {
            contains(Axis.Set(a))
        }
        
        package func isOrthogonal(to other: Axis.Set) -> Bool {
            symmetricDifference(other) == .both
        }
    }
}

extension Axis {
    package enum Alignment: CGFloat {
        case min = 0.0
        case center = 0.5
        case max = 1.0
        
        package init(_ y: _VAlignment) {
            switch y {
                case .top: self = .min
                case .center: self = .center
                case .bottom: self = .max
            }
        }
        
        package init(_ x: TextAlignment) {
            switch x {
                case .leading: self = .min
                case .center: self = .center
                case .trailing: self = .max
            }
        }
    }
}

extension Axis: CustomStringConvertible {
    public var description: String { self == .horizontal ? "horizontal" : "vertical" }
}
