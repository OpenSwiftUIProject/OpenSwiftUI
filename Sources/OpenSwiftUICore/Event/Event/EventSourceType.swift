//
//  EventSourceType.swift
//  OpenSwiftUICore
//
//  Status: Complete

// MARK: - EventSourceType [6.5.4]

@_spi(ForOpenSwiftUIOnly)
@available(OpenSwiftUI_v6_0, *)
public enum EventSourceType: CaseIterable {
    case platformGestureRecognizer

    @available(iOS, unavailable)
    @available(tvOS, unavailable)
    @available(watchOS, unavailable)
    @available(visionOS, unavailable)
    case platformHostingView
    
    @available(macOS, unavailable)
    @available(tvOS, unavailable)
    @available(watchOS, unavailable)
    case hoverGestureRecognizer
    
    @available(iOS, unavailable)
    @available(macOS, unavailable)
    @available(watchOS, unavailable)
    @available(visionOS, unavailable)
    case selectGestureRecognizer

    public static var allCases: [EventSourceType] {
        var cases: [EventSourceType] = []
        cases.append(.platformGestureRecognizer)
        #if !os(iOS) && !os(tvOS) && !os(watchOS) && !os(visionOS)
        cases.append(.platformHostingView)
        #endif
        #if !os(macOS) && !os(tvOS) && !os(watchOS)
        cases.append(.hoverGestureRecognizer)
        #endif
        #if !os(iOS) && !os(macOS) && !os(watchOS) && !os(visionOS)
        cases.append(.selectGestureRecognizer)
        #endif
        return cases
    }
}

@_spi(ForOpenSwiftUIOnly)
@available(*, unavailable)
extension EventSourceType: Sendable {}
