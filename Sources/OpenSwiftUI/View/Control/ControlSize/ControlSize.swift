//
//  ControlSize.swift
//  OpenSwiftUI
//
//  Audited for RELEASE_2023
//  Status: Complete

/// The size classes, like regular or small, that you can apply to controls
/// within a view.
@available(tvOS, unavailable)
public enum ControlSize: CaseIterable, Sendable {
    /// A control version that is minimally sized.
    case mini

    /// A control version that is proportionally smaller size for space-constrained views.
    case small

    /// A control version that is the default size.
    case regular

    /// A control version that is prominently sized.
    case large

    case extraLarge
}

extension ControlSize: Hashable {}
