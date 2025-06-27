//
//  EventBinding.swift
//  OpenSwiftUICore
//
//  Status: Complete

// MARK: - EventBinding [6.5.4]

@_spi(ForOpenSwiftUIOnly)
@available(OpenSwiftUI_v6_0, *)
public struct EventBinding: Equatable {
    package var responder: ResponderNode

    package init(responder: ResponderNode) {
        self.responder = responder
    }

    public static func == (lhs: EventBinding, rhs: EventBinding) -> Bool {
        lhs.responder === rhs.responder
    }
}

@_spi(ForOpenSwiftUIOnly)
@available(*, unavailable)
extension EventBinding: Sendable {}
