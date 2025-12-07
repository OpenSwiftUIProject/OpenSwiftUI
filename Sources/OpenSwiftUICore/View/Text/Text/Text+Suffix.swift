//
//  Text+Suffix.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Blocked by ResolvedStyledText
//  ID: 3A0E49913D84545BECD562BC22E4DF1C (SwiftUICore)

import OpenAttributeGraphShims

// MARK: - Text.Suffix

@available(OpenSwiftUI_v5_0, *)
extension Text {
    @_spi(Private)
    @available(OpenSwiftUI_v5_0, *)
    public struct Suffix: Sendable, Equatable {
        @_spi(Private)
        package enum Storage: Equatable {
            case automatic
            case none
            case truncated(Text)
            case alwaysVisible(Text)
        }

        package var storage: Text.Suffix.Storage

        public static var automatic: Text.Suffix {
            .init(storage: .automatic)
        }

        public static var none: Text.Suffix {
            .init(storage: .none)
        }

        public static func truncated(_ suffix: Text) -> Text.Suffix {
            .init(storage: .truncated(suffix))
        }

        public static func alwaysVisible(_ suffix: Text) -> Text.Suffix {
            .init(storage: .alwaysVisible(suffix))
        }

        package var text: Text? {
            switch storage {
            case .automatic, .none: nil
            case let .truncated(text): text
            case let .alwaysVisible(text): text
            }
        }

        func resolve(text: ResolvedStyledText?) -> ResolvedTextSuffix {
            // TODO: ResolvedStyledText is not implemented yet
            _openSwiftUIUnimplementedFailure()
        }
    }
}

// MARK: - View + textSuffix

@available(OpenSwiftUI_v5_0, *)
extension View {
    @_spi(Private)
    @available(OpenSwiftUI_v5_0, *)
    nonisolated public func textSuffix(_ suffix: Text.Suffix) -> some View {
        modifier(TextSuffixModifier(suffix: suffix))
    }
}

// MARK: - ResolvedTextSuffix

package enum ResolvedTextSuffix: Equatable {
    case none
    case truncated(Text.Layout.Line, [ShapeStyle.Pack.Style])
    case alwaysVisible(Text.Layout.Line, [ShapeStyle.Pack.Style])

    package var line: Text.Layout.Line? {
        switch self {
        case .none: nil
        case let .truncated(line, _): line
        case let .alwaysVisible(line, _): line
        }
    }

    package var styles: [ShapeStyle.Pack.Style] {
        switch self {
        case .none: []
        case let .truncated(_, styles): styles
        case let .alwaysVisible(_, styles): styles
        }
    }
}

private struct TextSuffixModifier: PrimitiveViewModifier, _GraphInputsModifier {
    var suffix: Text.Suffix

    static func _makeInputs(
        modifier: _GraphValue<Self>,
        inputs: inout _GraphInputs
    ) {
        let text = Attribute(OptionalText(modifier: modifier.value))
        let referenceDate = inputs.referenceDate
        let archivedView = inputs.archivedView
        let interfaceIdiom = inputs.interfaceIdiom
        // TODO: helper
        _openSwiftUIUnimplementedFailure()
    }

    struct ChildEnvironment: Rule, AsyncAttribute {
        @Attribute var suffix: ResolvedTextSuffix
        @Attribute var environment: EnvironmentValues

        var value: EnvironmentValues {
            var env = environment
            env[TextSuffixKey.self] = suffix
            return env
        }
    }

    struct ResolvedTextSuffixFilter: Rule, AsyncAttribute {
        @Attribute var modifier: TextSuffixModifier
        @Attribute var text: ResolvedStyledText?

        var value: ResolvedTextSuffix {
            modifier.suffix.resolve(text: text)
        }
    }

    struct OptionalText: Rule, AsyncAttribute {
        @Attribute var modifier: TextSuffixModifier

        var value: Text? {
            modifier.suffix.text
        }
    }
}

// MARK: - TextSuffixKey

private struct TextSuffixKey: EnvironmentKey {
    static let defaultValue: ResolvedTextSuffix = .none
}
