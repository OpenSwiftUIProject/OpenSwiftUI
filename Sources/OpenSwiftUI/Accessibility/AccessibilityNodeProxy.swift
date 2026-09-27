//
//  AccessibilityNodeProxy.swift
//  OpenSwiftUI

@_spi(Ultraviolet)
@available(OpenSwiftUI_v3_0, *)
public struct AccessibilityNodeProxy: Equatable, Hashable, Identifiable, Codable {
    public var id: Int

    // TODO

    static func makeProxyForIdentifiedView(
        with list: AccessibilityNodeList?,
        environment: EnvironmentValues
    ) -> AccessibilityNodeProxy? {
        nil
    }
}
