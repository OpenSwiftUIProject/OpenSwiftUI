//
//  TouchType.swift
//  OpenSwiftUICore
//
//  Status: Complete

// MARK: - TouchType [6.5.4]

@_spi(_)
@available(OpenSwiftUI_v5_0, *)
public enum TouchType: Hashable {
    case direct

    case indirect

    @available(macOS, obsoleted: 14.0)
    case pencil

    @available(macOS, obsoleted: 14.0)
    case indirectPointer
}

@_spi(_)
@available(*, unavailable)
extension TouchType: Sendable {}

@_spi(_)
extension TouchType {
    #if os(macOS)
    package static let allTypes: Set<TouchType> = [
        .direct, .indirect,
    ]
    #else
    package static let allTypes: Set<TouchType> = [
        .direct, .indirect,
        .pencil, .indirectPointer,
    ]
    #endif
}
