//
//  ContentTransition.swift
//  OpenSwiftUICore

// TODO

@available(OpenSwiftUI_v4_0, *)
public struct ContentTransition: Equatable, Sendable {
    package enum Storage: Equatable, @unchecked Sendable {
        case named(ContentTransition.NamedTransition)
//        case custom(ContentTransition.CustomTransition)
//        case symbolReplace(_SymbolEffect.ReplaceConfiguration)
    }

    @_spi(Private)
    public struct Style: Hashable, Sendable/*, Codable*/ {
        package enum Storage: Hashable, Sendable {
            case `default`

            case sessionWidget

            case animatedWidget
        }

        package var storage: ContentTransition.Style.Storage

        package init(_ storage: ContentTransition.Style.Storage) {
            self.storage = storage
        }

        public static let `default`: ContentTransition.Style = .init(.default)

        public static let sessionWidget: ContentTransition.Style = .init(.sessionWidget)

        @available(OpenSwiftUI_v5_0, *)
        public static let animatedWidget: ContentTransition.Style = .init(.animatedWidget)
    }

    package var storage: ContentTransition.Storage

    package var isReplaceable: Bool

    package init(storage: ContentTransition.Storage) {
        _openSwiftUIUnimplementedFailure()
    }

    package struct NamedTransition: Hashable, Sendable {
        package enum Name: Hashable {
            case `default`
            case identity
            case opacity
            case diff
            case fadeIfDifferent
            case text(different: Bool)
            // case numericText(ContentTransition.NumericTextConfiguration)
        }

        package var name: ContentTransition.NamedTransition.Name
        package var layoutDirection: LayoutDirection?
        package var style: ContentTransition.Style?

        package init(
            name: ContentTransition.NamedTransition.Name = .default,
            layoutDirection: LayoutDirection? = nil,
            style: ContentTransition.Style? = nil
        ) {
            self.name = name
            self.layoutDirection = layoutDirection
            self.style = style
        }
    }

    // TODO: NumericTextConfiguration

    // TODO
    package enum Effect {}

    package enum State {}
}
