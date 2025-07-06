//
//  DefaultPadding.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: WIP
//  ID: 47C1BD8C61550BB60F4F3D12F752D53D (SwiftUICore)

private struct DefaultPaddingKey: EnvironmentKey {
    static let defaultValue: EdgeInsets = .init(_all: 16.0)
}

@available(OpenSwiftUI_v3_0, *)
extension EnvironmentValues {
    @_spi(_)
    public var defaultPadding: EdgeInsets {
        get { self[DefaultPaddingKey.self] }
        set { self[DefaultPaddingKey.self] = newValue }
    }
}

@available(OpenSwiftUI_v2_0, *)
extension View {
    /// For use by children in containers to disable the automatic padding that
    /// those containers apply.
    public func _ignoresAutomaticPadding(_ ignoresPadding: Bool) -> some View {
        _openSwiftUIUnimplementedFailure()
    }

    /// Applies explicit padding to a view that allows being disabled by that
    /// view using `_ignoresAutomaticPadding`.
    public func _automaticPadding(_ edgeInsets: EdgeInsets? = nil) -> some View {
        _openSwiftUIUnimplementedFailure()
    }
}
