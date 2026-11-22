//
//  AnchoredPlane.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: 4AB633214A9802FE6627643001F45966 (SwiftUICore)

#if os(visionOS)
// MARK: - AnchoredPlane

@_spi(_)
@available(OpenSwiftUI_v5_0, *)
@available(iOS, unavailable)
@available(macOS, unavailable)
@available(watchOS, unavailable)
@available(tvOS, unavailable)
public enum AnchoredPlane: Hashable, Sendable {
    case horizontal
    case vertical
}

// MARK: - EnvironmentValues + AnchoredPlane

@_spi(_)
@available(OpenSwiftUI_v5_0, *)
@available(iOS, unavailable)
@available(macOS, unavailable)
@available(watchOS, unavailable)
@available(tvOS, unavailable)
extension EnvironmentValues {
    public var anchoredPlane: AnchoredPlane? { _anchoredPlane }
}

extension EnvironmentValues {
    package var _anchoredPlane: AnchoredPlane? {
        get { self[AnchoredPlaneKey.self] }
        set { self[AnchoredPlaneKey.self] = newValue }
    }

    private struct AnchoredPlaneKey: EnvironmentKey {
        static let defaultValue: AnchoredPlane? = nil
    }
}
#endif
