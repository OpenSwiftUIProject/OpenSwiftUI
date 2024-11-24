//
//  ShapeRole.swift
//  OpenSwiftUICore
//
//  Audited for iOS 18.0
//  Status: Complete

/// Ways of styling a shape.
public enum ShapeRole: Sendable {
    /// Indicates to the shape's style that OpenSwiftUI fills the shape.
    case fill
    
    /// Indicates to the shape's style that OpenSwiftUI applies a stroke to
    /// the shape's path.
    case stroke
    
    /// Indicates to the shape's style that OpenSwiftUI uses the shape as a
    /// separator.
    case separator
}
