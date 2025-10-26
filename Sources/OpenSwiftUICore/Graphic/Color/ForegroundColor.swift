//
//  ForegroundColor.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: C468F93725C18A8D97E53626AB610118 (SwiftUICore)

import OpenAttributeGraphShims

// MARK: - View + foregroundColor

@available(OpenSwiftUI_v1_0, *)
extension View {
    package func defaultForegroundColor(_ color: Color?) -> some View {
        environment(\.defaultForegroundColor, color)
    }

    /// Sets the color of the foreground elements displayed by this view.
    ///
    /// - Parameter color: The foreground color to use when displaying this
    ///   view. Pass `nil` to remove any custom foreground color and to allow
    ///   the system or the container to provide its own foreground color.
    ///   If a container-specific override doesn't exist, the system uses
    ///   the primary color.
    ///
    /// - Returns: A view that uses the foreground color you supply.
    @available(OpenSwiftUI_v1_0, *)
    @available(*, deprecated, renamed: "foregroundStyle(_:)")
    @inlinable
    nonisolated public func foregroundColor(_ color: Color?) -> some View {
        environment(\.foregroundColor, color)
    }
}

@available(OpenSwiftUI_v1_0, *)
extension EnvironmentValues {
    package var defaultForegroundColor: Color? {
        get {
            guard let style = defaultForegroundStyle else { return nil }
            return style.fallbackColor(in: self)
        }
        set {
            guard let newValue else { return }
            defaultForegroundStyle = .init(newValue)
        }
    }

    @usableFromInline
    package var foregroundColor: Color? {
        get {
            guard let style = foregroundStyle else { return nil }
            return style.fallbackColor(in: self)
        }
        set {
            guard let newValue else { return }
            foregroundStyle = .init(newValue)
        }
    }
}

@available(OpenSwiftUI_v3_0, *)
extension EnvironmentValues {
    package var _effectiveForegroundColor: Color? {
        let style = _effectiveForegroundStyle
        return style.fallbackColor(in: self)
    }
}

// MARK: - _ForegroundColorModifier

@available(OpenSwiftUI_v3_0, *)
@available(*, deprecated, message: "will be removed")
@frozen
public struct _ForegroundColorModifier: ViewInputsModifier, PrimitiveViewModifier {
    public var color: Color?

    @inlinable
    public init(color: Color?) {
        self.color = color
    }

    nonisolated public static func _makeViewInputs(
        modifier: _GraphValue<Self>,
        inputs: inout _ViewInputs
    ) {
        inputs.environment = Attribute(
            ChildEnvironment(
                modifier: modifier.value,
                environment: inputs.environment
            )
        )
    }

    private struct ChildEnvironment: Rule {
        @Attribute var modifier: _ForegroundColorModifier
        @Attribute var environment: EnvironmentValues

        var value: EnvironmentValues {
            var environment = environment
            environment.foregroundColor = modifier.color.flatMap {
                Color.foreground != $0 ? $0 : nil
            }
            return environment
        }
    }
}

@available(*, unavailable)
extension _ForegroundColorModifier: Sendable {}

// MARK: - Color + foreground

extension Color {
    static let foreground = Color(provider: ForegroundColorProvider())

    private struct ForegroundColorProvider: ColorProvider {
        func resolve(in environment: EnvironmentValues) -> Color.Resolved {
            let color = environment._effectiveForegroundStyle.fallbackColor(in: environment)
            return (color ?? .primary).resolve(in: environment)
        }
    }
}
