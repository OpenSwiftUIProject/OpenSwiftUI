//
//  ShapeStyleName.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete

package enum _ShapeStyle_Name: UInt8, Equatable, Comparable {
    case foreground
    case background
    case multicolor
    
    package static func < (lhs: _ShapeStyle_Name, rhs: _ShapeStyle_Name) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }
}
