//
//  ViewRenderingPhase.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete

package enum ViewRenderingPhase {
    case none
    case rendering
    case renderingAsync
}

@available(*, unavailable)
extension ViewRenderingPhase: Sendable {}
