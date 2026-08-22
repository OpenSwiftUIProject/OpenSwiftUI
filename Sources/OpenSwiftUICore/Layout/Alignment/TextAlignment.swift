//
//  TextAlignment.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete

package import Foundation

// MARK: - TextAlignment

/// An alignment position for text along the horizontal axis.
@available(OpenSwiftUI_v1_0, *)
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

// MARK: - CodableByProxy

extension TextAlignment: CodableByProxy {
    package typealias CodingProxy = UInt8

    package var codingProxy: UInt8 {
        switch self {
        case .leading: 0
        case .center: 1
        case .trailing: 2
        }
    }

    package static func unwrap(codingProxy: UInt8) -> TextAlignment {
        switch codingProxy {
        case 1: .center
        case 2: .trailing
        default: .leading
        }
    }
}
