//
//  AllowsWindowActivationEventsResponder.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: WIP
//  ID: 302179F1EB9AE99B83C6A183C0B4143E (?)

@_spi(ForOpenSwiftUIOnly)
public import OpenSwiftUICore

// MARK: - View + allowsWindowActivationEvents [TBA]

@available(OpenSwiftUI_v6_0, *)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
extension View {
    nonisolated public func allowsWindowActivationEvents(_ value: Bool? = true) -> some View {
        _openSwiftUIUnimplementedWarning()
        return self
    }
}

#if os(macOS)
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
