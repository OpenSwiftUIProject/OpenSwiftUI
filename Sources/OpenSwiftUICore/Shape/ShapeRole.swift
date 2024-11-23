//
//  ShapeRole.swift
//  OpenSwiftUI
//
//  Audited for iOS 18.0
//  Status: Complete

/// Ways of styling a shape.
public enum ShapeRole: Sendable {
    /// Indicates to the shape's style that SwiftUI fills the shape.
    case fill
    
    /// Indicates to the shape's style that SwiftUI applies a stroke to
    /// the shape's path.
    case stroke
    
    /// Indicates to the shape's style that SwiftUI uses the shape as a
    /// separator.
    case separator
}
