//
//  PlatformViewRepresentableLayoutOptions.swift
//  OpenSwiftUI
//
//  Audited for iOS 18.0
//  Status: Complete

/// Options for defining how a platform representable interacts with the
/// bridging implementation.
public struct _PlatformViewRepresentableLayoutOptions: OptionSet {
    public let rawValue: Int

    @_spi(Private)
    public static let propagatesSafeArea: _PlatformViewRepresentableLayoutOptions = .init(rawValue: 1 << 2)

    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
}

@available(*, unavailable)
extension _PlatformViewRepresentableLayoutOptions: Sendable {}
