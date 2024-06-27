//
//  ShapeRole.swift
//  OpenSwiftUI
//
//  Audited for RELEASE_2021
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
