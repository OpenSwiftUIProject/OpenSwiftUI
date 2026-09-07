//
//  EventPhase.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete

// MARK: - EventPhase

@_spi(ForOpenSwiftUIOnly)
@available(OpenSwiftUI_v6_0, *)
public enum EventPhase: Hashable {
    case began
    case active
    case ended
    case failed
}

@available(*, unavailable)
extension EventPhase: Sendable {}

extension EventPhase {
    package var isTerminal: Bool {
        switch self {
        case .began, .active: false
        case .ended, .failed: true
        }
    }
}
