//
//  Enabled.swift
//  OpenSwiftUICore
//
//  Status: Complete
//  ID: 09CE35833F3876FE3A3A46977D61FC64 (SwiftUICore)

package import OpenAttributeGraphShims

// MARK: - EnabledKey [6.5.4]

private struct EnabledKey: EnvironmentKey {
    static let defaultValue: Bool = true
}

@available(OpenSwiftUI_v1_0, *)
extension EnvironmentValues {
    /// A Boolean value that indicates whether the view associated with this
    /// environment allows user interaction.
    ///
    /// The default value is `true`.
    public var isEnabled: Bool {
        get { self[EnabledKey.self] }
        set { self[EnabledKey.self] = newValue }
    }
}

extension View {
    /// Adds a condition that controls whether users can interact with this
    /// view.
    ///
    /// The higher views in a view hierarchy can override the value you set on
    /// this view. In the following example, the button isn't interactive
    /// because the outer `disabled(_:)` modifier overrides the inner one:
    ///
    ///     HStack {
    ///         Button(Text("Press")) {}
    ///         .disabled(false)
    ///     }
    ///     .disabled(true)
    ///
    /// - Parameter disabled: A Boolean value that determines whether users can
    ///   interact with this view.
    ///
    /// - Returns: A view that controls whether users can interact with this
    ///   view.
    @inlinable
    nonisolated public func disabled(_ disabled: Bool) -> some View {
        modifier(
            _EnvironmentKeyTransformModifier(
                keyPath: \.isEnabled
            ) { $0 = $0 && !disabled }
        )
    }

    package func _disabled(_ disabled: Bool) -> ModifiedContent<Self, _EnvironmentKeyTransformModifier<Bool>> {
        modifier(
            _EnvironmentKeyTransformModifier(
                keyPath: \.isEnabled
            ) { $0 = $0 && !disabled }
        )
    }
}

// MARK: - EnabledKey + CachedEnvironment [6.4.41]

extension CachedEnvironment.ID {
    static let isEnabled: CachedEnvironment.ID = .init()
}

extension _GraphInputs {
    package var isEnabled: Attribute<Bool> {
        mapEnvironment(id: .isEnabled) { $0.isEnabled }
    }
}

extension _ViewInputs {
    package var isEnabled: Attribute<Bool> {
        mapEnvironment(id: .isEnabled) { $0.isEnabled }
    }
}
