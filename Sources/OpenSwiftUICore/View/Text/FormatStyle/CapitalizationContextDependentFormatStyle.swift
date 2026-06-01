//
//  CapitalizationContextDependentFormatStyle.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete (Blocked by SystemFormatStyle)
//  ID: B2C9C13C743DF2F6E22ED614C39E3A5D (SwiftUICore)

public import Foundation

protocol CapitalizationContextDependentFormatStyle: FormatStyle {
    func capitalizationContext(_ context: FormatStyleCapitalizationContext) -> Self
}

extension EnvironmentValues {
    enum CapitalizationContext {
        case resolved(FormatStyleCapitalizationContext)
        case lazy(() -> FormatStyleCapitalizationContext)

        @inline(__always)
        var resolved: FormatStyleCapitalizationContext {
            switch self {
            case let .resolved(context):
                context
            case let .lazy(resolve):
                resolve()
            }
        }
    }

    private struct Key: EnvironmentKey {
        static let defaultValue: EnvironmentValues.CapitalizationContext = .resolved(.standalone)
    }

    var capitalizationContext: CapitalizationContext {
        get { self[Key.self] }
        set { self[Key.self] = newValue }
    }
}

// TODO: Add conformance
// SystemFormatStyle.DateReference
// Date.AnchoredRelativeFormatStyle
// Date.FormatStyle
// ...
