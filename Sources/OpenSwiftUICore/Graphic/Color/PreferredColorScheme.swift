//
//  PreferredColorScheme.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: E52508E85535897B9A366B470195B29D (SwiftUICore)

import OpenAttributeGraphShims

// MARK: - PreferredColorSchemeKey

/// A preference key for the preferred color scheme.
@available(OpenSwiftUI_v1_0, *)
public struct PreferredColorSchemeKey: PreferenceKey {

    public typealias Value = ColorScheme?

    public static func reduce(value: inout ColorScheme?, nextValue: () -> ColorScheme?) {
        value = value ?? nextValue()
    }
}

@available(*, unavailable)
extension PreferredColorSchemeKey: Sendable {}

// MARK: - PreferredColorSchemeKey + HostPreferenceKey

@_spi(Private)
@available(OpenSwiftUI_v1_0, *)
extension PreferredColorSchemeKey: HostPreferenceKey {

    public static var _isReadableByHost: Bool {
        true
    }
}

// MARK: - View + preferredColorScheme

extension View {

    /// Sets the preferred color scheme for this presentation.
    ///
    /// Use one of the values in ``ColorScheme`` with this modifier to set a
    /// preferred color scheme for the nearest enclosing presentation, like a
    /// popover, a sheet, or a window. The value that you set overrides the
    /// user's Dark Mode selection for that presentation. In the example
    /// below, the ``Toggle`` controls whether the sheet appears when
    /// activated by the user:
    ///
    ///     @State private var isPresented = false
    ///     @State private var isDarkMode = true
    ///
    ///     var body: some View {
    ///         Button("Show Sheet") {
    ///             isPresented = true
    ///         }
    ///         .sheet(isPresented: $isPresented) {
    ///             Toggle("Dark Mode", isOn: $isDarkMode)
    ///                 .padding()
    ///                 .preferredColorScheme(isDarkMode ? .dark : .light)
    ///         }
    ///     }
    ///
    /// If you set this value on a presentation that isn't displaying yet,
    /// OpenSwiftUI applies the color scheme to the first appearance of the view.
    /// If you apply the modifier to a view that's already visible, OpenSwiftUI
    /// applies the color scheme change immediately.
    ///
    /// If you want to modify the ``EnvironmentValues/colorScheme`` of a
    /// specific view, you should use ``View/colorScheme(_:)`` instead.
    ///
    /// - Parameter colorScheme: The preferred color scheme for this view.
    ///
    /// - Returns: A view that sets the color scheme.
    @inlinable
    nonisolated public func preferredColorScheme(_ colorScheme: ColorScheme?) -> some View {
        preference(key: PreferredColorSchemeKey.self, value: colorScheme)
    }
}

extension _PreferenceWritingModifier where Key == PreferredColorSchemeKey {

    nonisolated static func makePreviewColorSchemeList(
        modifier: _GraphValue<Self>,
        inputs: _ViewListInputs,
        body: (_Graph, _ViewListInputs) -> _ViewListOutputs
    ) -> _ViewListOutputs {
        var inputs = inputs
        inputs.traits = Attribute(
            ColorSchemeTrait(
                modifier: modifier.value,
                traits: inputs._traits
            )
        )
        inputs.traitKeys?.insert(PreviewColorSchemeTraitKey.self)
        inputs.base.environment = Attribute(
            ColorSchemeEnv(
                modifier: modifier.value,
                environment: inputs.base.environment
            )
        )
        return body(_Graph(), inputs)
    }

    private struct ColorSchemeEnv: Rule {
        @Attribute var modifier: _PreferenceWritingModifier
        @Attribute var environment: EnvironmentValues

        var value: EnvironmentValues {
            var environemnt = environment
            modifier.value.map { environemnt.colorScheme = $0 }
            return environemnt
        }
    }

    private struct ColorSchemeTrait: Rule {
        @Attribute var modifier: _PreferenceWritingModifier
        @OptionalAttribute var traits: ViewTraitCollection?

        var value: ViewTraitCollection {
            var traits = traits ?? .init()
            traits[PreviewColorSchemeTraitKey.self] = modifier.value
            return traits
        }
    }
}
