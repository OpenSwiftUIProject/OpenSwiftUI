//
//  NSHostingSizingOptions.swift
//  OpenSwiftUI
//
//  Audited for macOS 15.0
//  Status: Complete

#if os(macOS)

@available(iOS, unavailable)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
@available(visionOS, unavailable)
public struct NSHostingSizingOptions: OptionSet, Sendable {
    public let rawValue: Int
    public init(rawValue: Int) { self.rawValue = rawValue }
    public static let minSize: NSHostingSizingOptions = .init(rawValue: 1 << 0)
    public static let intrinsicContentSize: NSHostingSizingOptions = .init(rawValue: 1 << 1)
    public static let maxSize: NSHostingSizingOptions = .init(rawValue: 1 << 2)
    public static let preferredContentSize: NSHostingSizingOptions = .init(rawValue: 1 << 3)
    public static let standardBounds: NSHostingSizingOptions = [.minSize, .intrinsicContentSize, .maxSize]
}

#endif
