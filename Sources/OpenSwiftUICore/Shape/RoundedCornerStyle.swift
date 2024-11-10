//
//  ShapeRole.swift
//  OpenSwiftUI
//
//  Audited for iOS 15.5
//  Status: Complete

/// Defines the shape of a rounded rectangle's corners.
public enum RoundedCornerStyle: Sendable {
    /// Quarter-circle rounded rect corners.
    case circular

    /// Continuous curvature rounded rect corners.
    case continuous
}

extension RoundedCornerStyle: Equatable {}
extension RoundedCornerStyle: Hashable {}
