//
//  PlatformViewRepresentableLayoutOptions.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete

/// Options for defining how a platform representable interacts with the
/// bridging implementation.
@available(OpenSwiftUI_v4_1, *)
public struct _PlatformViewRepresentableLayoutOptions: OptionSet {
    public let rawValue: Int

    @_spi(Private)
    @available(OpenSwiftUI_v5_0, *)
    public static let propagatesSafeArea: _PlatformViewRepresentableLayoutOptions = .init(rawValue: 1 << 2)

    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
}

@available(*, unavailable)
extension _PlatformViewRepresentableLayoutOptions: Sendable {}
