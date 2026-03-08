//
//  WatchEnvironment.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: 1DA60AC25654F83E54CB649774D3C2D4 (SwiftUICore)

@available(iOS, unavailable)
@available(macOS, unavailable)
@available(tvOS, unavailable)
@available(watchOS, deprecated, introduced: 6.0, renamed: "WatchDisplayVariant")
@available(visionOS, unavailable)
public enum _DeviceVariant: Equatable {
    case compact
    case regular
    case h394
    case h448
}

@available(*, unavailable)
extension _DeviceVariant: Sendable {}

@available(iOS, unavailable)
@available(macOS, unavailable)
@available(tvOS, unavailable)
@available(visionOS, unavailable)
private struct DeviceVariantKey: EnvironmentKey {
    static var defaultValue: _DeviceVariant { .regular }
}

@available(iOS, unavailable)
@available(macOS, unavailable)
@available(tvOS, unavailable)
@available(watchOS, introduced: 6.0, deprecated: 8.0, renamed: "watchDisplayVariant")
@available(visionOS, unavailable)
extension EnvironmentValues {
    @available(iOS, unavailable)
    @available(macOS, unavailable)
    @available(tvOS, unavailable)
    @available(visionOS, unavailable)
    public var _deviceVariant: _DeviceVariant {
        get { self[DeviceVariantKey.self] }
        set { self[DeviceVariantKey.self] = newValue }
    }
}

@_spi(Private)
@available(OpenSwiftUI_v6_0, *)
public enum WatchDisplayVariant {
    case h340

    case h390

    case h394

    case h448

    case h430

    case h484

    case h502

    case h446

    case h496

    public var isH430Compatible: Bool {
        switch self {
        case .h430, .h446: true
        default: false
        }
    }

    public var isH484Compatible: Bool {
        switch self {
        case .h484, .h496: true
        default: false
        }
    }

}

@_spi(Private)
@available(*, unavailable)
extension WatchDisplayVariant: Sendable {}

@_spi(Private)
@available(OpenSwiftUI_v6_0, *)
extension EnvironmentValues {
    struct WatchDisplayVariantKey: EnvironmentKey {
        static var defaultValue: WatchDisplayVariant { .h390 }
    }

    public var watchDisplayVariant: WatchDisplayVariant {
        get { self[WatchDisplayVariantKey.self] }
        set { self[WatchDisplayVariantKey.self] = newValue }
    }
}
