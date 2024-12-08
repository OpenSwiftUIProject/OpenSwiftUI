//
//  VAlignment.swift
//  OpenSwiftUICore
//
//  Audited for iOS 18.0
//  Status: Complete

package import Foundation

/// An alignment in the vertical axis.
@frozen
public enum _VAlignment {
    case top
    case center
    case bottom
    
    package var value: CGFloat {
        switch self {
            case .top: 0.0
            case .center: 0.5
            case .bottom: 1.0
        }
    }
}
