//
//  LegibilityWeight.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete

/// The Accessibility Bold Text user setting options.
///
/// The app can't override the user's choice before iOS 16, tvOS 16 or
/// watchOS 9.0.
@available(OpenSwiftUI_v1_0, *)
public enum LegibilityWeight: Hashable, Sendable {

    /// Use regular font weight (no Accessibility Bold).
    case regular

    /// Use heavier font weight (force Accessibility Bold).
    case bold
}
