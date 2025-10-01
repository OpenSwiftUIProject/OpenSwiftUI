//
//  ShapeStyle_Name.swift
//  OpenSwiftUICore
//
//  Audited for 6.0.87
//  Status: Complete

package enum _ShapeStyle_Name: UInt8, Equatable, Comparable {
    case foreground
    case background
    case multicolor
    
    package static func < (lhs: _ShapeStyle_Name, rhs: _ShapeStyle_Name) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }
}
