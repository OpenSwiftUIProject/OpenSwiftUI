//
//  ControlTintedColor.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: EC06E65D3EE8D18E3FBCB8910A79AF01 (SwiftUICore)

// MARK: - Color + TintAdjustment

extension Color {
    package func tintAdjustmentMode(_ mode: TintAdjustmentMode) -> Color {
        switch mode {
        case .normal:
            self
        case .desaturated:
            Color(provider: DesaturatedColor(base: self))
        }
    }

    package var tintAdjusted: Color {
        Color(provider: TintAdjustmentProvider(base: self))
    }

    private struct TintAdjustmentProvider: ColorProvider {
        var base: Color

        func resolve(in environment: EnvironmentValues) -> Color.Resolved {
            base.tintAdjustmentMode(environment.effectiveTintAdjustmentMode)
                .resolve(in: environment)
        }
    }

    private struct DesaturatedColor: ColorProvider, CustomStringConvertible {
        var base: Color

        func resolve(in environment: EnvironmentValues) -> Color.Resolved {
            let resolved = base.resolve(in: environment)
            return Color.Resolved(
                linearWhite: resolved.linearWhite,
                opacity: resolved.opacity * 0.8
            )
        }

        var description: String {
            "Desaturated(\(base))"
        }
    }
}

// MARK: - View + TintAdjustmentMode

extension View {
    package func tintAdjustmentMode(_ tintAdjustmentMode: TintAdjustmentMode?) -> some View {
        environment(\.tintAdjustmentMode, tintAdjustmentMode)
    }
}

// MARK: - EnvironmentValues + TintAdjustmentMode

extension EnvironmentValues {
    package var tintAdjustmentMode: TintAdjustmentMode? {
        get { self[TintAdjustmentModeKey.self] }
        set { self[TintAdjustmentModeKey.self] = newValue }
    }

    package var effectiveTintAdjustmentMode: TintAdjustmentMode {
        tintAdjustmentMode ?? (isEnabled ? .normal : .desaturated)
    }
}

private struct TintAdjustmentModeKey: EnvironmentKey {
    static var defaultValue: TintAdjustmentMode? { nil }
}

// MARK: - TintAdjustmentMode

package enum TintAdjustmentMode: Equatable, Hashable {
    case normal
    case desaturated
}
