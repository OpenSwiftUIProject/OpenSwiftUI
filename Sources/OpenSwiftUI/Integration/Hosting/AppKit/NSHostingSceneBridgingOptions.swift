//
//  NSHostingSceneBridgingOptions.swift
//  OpenSwiftUI
//
//  Audited for macOS 15.0
//  Status: Complete

#if os(macOS)

@available(iOS, unavailable)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
@available(visionOS, unavailable)
public struct NSHostingSceneBridgingOptions: OptionSet, Sendable {
    public let rawValue: Int
    public init(rawValue: Int) { self.rawValue = rawValue }
    public static let title: NSHostingSceneBridgingOptions = .init(rawValue: 1 << 0)
    public static let toolbars: NSHostingSceneBridgingOptions = .init(rawValue: 1 << 1)
    public static let all: NSHostingSceneBridgingOptions = .init(rawValue: 1 << 2)
}

#endif
