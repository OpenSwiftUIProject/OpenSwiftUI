//
//  AllowsWindowActivationEventsResponder.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: WIP
//  ID: 302179F1EB9AE99B83C6A183C0B4143E (?)

#if os(macOS)
@_spi(ForOpenSwiftUIOnly)
import OpenSwiftUICore

// TODO: AllowsWindowActivationEventsResponder
class AllowsWindowActivationEventsResponder: DefaultLayoutViewResponder {
    var value: Bool?
}

// MARK: - AllowsWindowActivationEventsKey

private struct AllowsWindowActivationEventsKey: EnvironmentKey {
    static var defaultValue: Bool?
}

extension EnvironmentValues {
    var allowsWindowActivationEvents: Bool? {
        get { self[AllowsWindowActivationEventsKey.self] }
        set { self[AllowsWindowActivationEventsKey.self] = newValue }
    }
}
#endif
