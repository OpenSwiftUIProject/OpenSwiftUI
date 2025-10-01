//
//  NSHostingSceneBridgingOptions.swift
//  OpenSwiftUI
//
//  Audited for 6.0.87
//  Status: Complete

#if os(macOS)

/// Options for how hosting views and controllers manage aspects of the
/// associated window.
@available(iOS, unavailable)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
@available(visionOS, unavailable)
public struct NSHostingSceneBridgingOptions: OptionSet, Sendable {

    /// The raw value.
    public let rawValue: Int

    /// Creates a new set from a raw value.
    ///
    /// - Parameter rawValue: The raw value with which to create the
    ///   hosting window options.
    public init(rawValue: Int) { self.rawValue = rawValue }

    /// The hosting view's associated window will have its title and subtitle
    /// populated with the values provided to the ``navigationTitle(_:)`` and
    /// ``navigationSubtitle(_:)`` modifiers, respectively.
    ///
    /// Title bars populated in this manner overwrite any values set using AppKit.
    public static let title: NSHostingSceneBridgingOptions = .init(rawValue: 1 << 0)

    @_spi(Private)
    @available(*, deprecated, renamed: "title")
    public static let titles: NSHostingSceneBridgingOptions = .title

    /// The hosting view's associated window will have its toolbar populated
    /// with any items provided to the ``toolbar(content:)`` modifier.
    ///
    /// Toolbars populated in this manner overwrite any toolbar set on the window using AppKit.
    public static let toolbars: NSHostingSceneBridgingOptions = .init(rawValue: 1 << 1)

    /// The hosting view's associated window will have both its title bars and
    /// toolbars populated with values from their respective modifiers.
    public static let all: NSHostingSceneBridgingOptions = .init(rawValue: 1 << 2)
}

#endif
