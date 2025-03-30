//
//  NSHostingSizingOptions.swift
//  OpenSwiftUI
//
//  Audited for macOS 15.0
//  Status: Complete

#if os(macOS)

/// Options for how hosting views and controllers reflect their
/// content's size into Auto Layout constraints.
@available(iOS, unavailable)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
@available(visionOS, unavailable)
public struct NSHostingSizingOptions: OptionSet, Sendable {

    /// The raw value.
    public let rawValue: Int

    /// Creates a new options from a raw value.
    public init(rawValue: Int) { self.rawValue = rawValue }

    /// The hosting view creates and updates constraints that represent its
    /// content's minimum size.
    ///
    /// The constraints reflect the size that fits a proposal of
    /// `width: 0, height: 0`.
    public static let minSize: NSHostingSizingOptions = .init(rawValue: 1 << 0)

    /// The hosting view creates and updates constraints that represent its
    /// content's ideal size. These constraints in turn influence the hosting
    /// view's `intrinsicContentSize`.
    ///
    /// The constraints reflect the size that fits a proposal of
    /// `.unspecified`.
    public static let intrinsicContentSize: NSHostingSizingOptions = .init(rawValue: 1 << 1)

    /// The hosting view creates and updates constraints that represent its
    /// content's maximum size.
    ///
    /// The constraints reflect the size that fits a proposal of
    /// `width: infinity, height: infinity`.
    public static let maxSize: NSHostingSizingOptions = .init(rawValue: 1 << 2)

    /// The hosting controller creates and updates constraints that represent
    /// its content's ideal size. These constraints in turn influence the
    /// hosting controller's `preferredContentSize`.
    ///
    /// The constraints reflect the size that fits a proposal of
    /// `.unspecified`.
    ///
    /// > Note: this option has no effect when used with an `NSHostingView`
    ///   directly.
    public static let preferredContentSize: NSHostingSizingOptions = .init(rawValue: 1 << 3)

    /// The hosting view creates constraints for its minimum, ideal, and maximum
    /// sizes.
    public static let standardBounds: NSHostingSizingOptions = [.minSize, .intrinsicContentSize, .maxSize]
}

#endif
