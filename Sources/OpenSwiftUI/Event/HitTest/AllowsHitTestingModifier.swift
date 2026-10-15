//
//  AllowsHitTestingModifier.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: WIP
//  ID: 9EE920A99C667C354EEDF67A755D6AA8 (SwiftUI)

public import Foundation
public import OpenSwiftUICore

// TODO: - _AllowsHitTestingModifier

// MARK: - View + allowsHitTesting

@available(OpenSwiftUI_v1_0, *)
extension View {
    /// Configures whether this view participates in hit test operations.
    @inlinable
    nonisolated public func allowsHitTesting(_ enabled: Bool) -> some View {
        self
    }
}
