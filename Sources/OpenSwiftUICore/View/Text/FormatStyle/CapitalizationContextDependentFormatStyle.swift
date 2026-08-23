//
//  CapitalizationContextDependentFormatStyle.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete
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

#if canImport(Darwin)

@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
extension Date.RelativeFormatStyle: CapitalizationContextDependentFormatStyle {
    func capitalizationContext(
        _ context: FormatStyleCapitalizationContext
    ) -> Self {
        var style = self
        if capitalizationContext == .unknown {
            style.capitalizationContext = context
        }
        return style
    }
}

@available(macOS 15.0, iOS 18.0, tvOS 18.0, watchOS 11.0, *)
extension Date.AnchoredRelativeFormatStyle: CapitalizationContextDependentFormatStyle {
    func capitalizationContext(
        _ context: FormatStyleCapitalizationContext
    ) -> Self {
        var style = self
        if capitalizationContext == .unknown {
            style.capitalizationContext = context
        }
        return style
    }
}

@available(macOS 12.0, iOS 15.0, tvOS 15.0, watchOS 8.0, *)
extension Date.FormatStyle: CapitalizationContextDependentFormatStyle {
    func capitalizationContext(
        _ context: FormatStyleCapitalizationContext
    ) -> Self {
        var style = self
        if capitalizationContext == .unknown {
            style.capitalizationContext = context
        }
        return style
    }
}

@available(macOS 15.0, iOS 18.0, tvOS 18.0, watchOS 11.0, *)
extension Date.FormatStyle.Attributed: CapitalizationContextDependentFormatStyle {
    func capitalizationContext(
        _ context: FormatStyleCapitalizationContext
    ) -> Self {
        var style = self
        if style[dynamicMember: \.capitalizationContext] == .unknown {
            style[dynamicMember: \.capitalizationContext] = context
        }
        return style
    }
}

#endif
