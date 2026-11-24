//
//  DefaultGroupBoxStyle.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: 8BD69E28E99EC8876BD2292361C4AA8C (SwiftUI)

public import OpenSwiftUICore

// MARK: - GroupBoxStyle + DefaultGroupBoxStyle

@available(OpenSwiftUI_v2_0, *)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
extension GroupBoxStyle where Self == DefaultGroupBoxStyle {
    /// The default style for a group box.
    @_alwaysEmitIntoClient
    @MainActor
    @preconcurrency
    public static var automatic: DefaultGroupBoxStyle { .init() }
}

// MARK: - DefaultGroupBoxStyle

/// The platform's default group box style.
@available(OpenSwiftUI_v2_0, *)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
public struct DefaultGroupBoxStyle: GroupBoxStyle {
    public init() {
        _openSwiftUIEmptyStub()
    }

    public func makeBody(configuration: Configuration) -> some View {
        GroupBox {
            configuration.content.groupBoxStyle(self)
        } label: {
            configuration.label
        }
        #if os(macOS)
        .groupBoxStyle(MacIdiomGroupBoxStyle())
        #else
        .groupBoxStyle(PhoneIdiomGroupBoxStyle())
        #endif
    }
}

@available(*, unavailable)
extension DefaultGroupBoxStyle: Sendable {}

// MARK: - FormBorderlessSectionTraitKey

struct FormBorderlessSectionTraitKey: _ViewTraitKey {
    static var defaultValue: Bool { false }
}

// MARK: - View + disableGroupBoxPadding

#if os(macOS)
@available(OpenSwiftUI_v3_0, *)
#else
@available(OpenSwiftUI_v4_0, *)
#endif
@available(tvOS, unavailable)
@available(watchOS, unavailable)
extension View {
    @_spi(Private)
    nonisolated public func disableGroupBoxPadding(_ disable: Bool = true) -> some View {
        environment(\.disableGroupBoxPadding, disable)
    }
}

// MARK: - DisableGroupBoxPaddingKey

private struct DisableGroupBoxPaddingKey: EnvironmentKey {
    static let defaultValue = false
}

// MARK: - EnvironmentValues + disableGroupBoxPadding

extension EnvironmentValues {
    var disableGroupBoxPadding: Bool {
        get { self[DisableGroupBoxPaddingKey.self] }
        set { self[DisableGroupBoxPaddingKey.self] = newValue }
    }
}
