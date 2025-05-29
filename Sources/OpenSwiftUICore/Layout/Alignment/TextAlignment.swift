//
//  TextAlignment.swift
//  OpenSwiftUICore
//
//  Status: Complete

package import Foundation

// MARK: - TextAlignment [6.0.87]

/// An alignment position for text along the horizontal axis.
@frozen
public enum TextAlignment: Hashable, CaseIterable {
    case leading
    case center
    case trailing
    
    package var value: CGFloat {
        switch self {
            case .leading: 0.0
            case .center: 0.5
            case .trailing: 1.0
        }
    }
}

extension TextAlignment: ProtobufEnum {
    package var protobufValue: UInt {
        switch self {
            case .leading: 1
            case .center: 2
            case .trailing: 3
        }
    }
    
    package init?(protobufValue: UInt) {
        switch protobufValue {
            case 1: self = .leading
            case 2: self = .center
            case 3: self = .trailing
            default: return nil
        }
    }
}
