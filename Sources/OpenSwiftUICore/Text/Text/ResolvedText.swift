//
//  ResolvedText.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: WIP
//  ID: 7AFAB46D18FA6D189589CFA78D8B2B2E (SwiftUICore)

package import Foundation

package protocol ResolvedTextContainer {
    var style: Text.Style { get set }

    var idiom: AnyInterfaceIdiom? { get }

    mutating func append<S>(
        _ string: S,
        in env: EnvironmentValues,
        with options: Text.ResolveOptions,
        isUniqueSizeVariant: Bool
    ) where S: StringProtocol

    mutating func append(
        _ attributedString: NSAttributedString,
        in env: EnvironmentValues,
        with options: Text.ResolveOptions,
        isUniqueSizeVariant: Bool
    )

//    mutating func append(
//        _ image: Image.Resolved,
//        in environment: EnvironmentValues,
//        with options: Text.ResolveOptions
//    )
//
//    mutating func append(
//        _ namedImage: Image.NamedResolved,
//        in environment: EnvironmentValues,
//        with options: Text.ResolveOptions
//    )
//
//    mutating func append<R>(
//        resolvable: R,
//        in environment: EnvironmentValues,
//        with options: Text.ResolveOptions,
//        transition: ContentTransition?
//    ) where R: ResolvableStringAttribute
}

extension ResolvedTextContainer {
    mutating func append<S>(
        _ string: S,
        in env: EnvironmentValues,
        with options: Text.ResolveOptions,
    ) where S: StringProtocol {
        _openSwiftUIUnimplementedFailure()
    }

    mutating func append(
        _ attributedString: NSAttributedString,
        in env: EnvironmentValues,
        with options: Text.ResolveOptions,
    ) {
        _openSwiftUIUnimplementedFailure()
    }
}

extension Text {
    package struct Resolved: ResolvedTextContainer {
        package var style: Text.Style = .init()

        package var attributedString: NSMutableAttributedString?

        package var includeDefaultAttributes: Bool = true

        package var idiom: AnyInterfaceIdiom?

        package var properties: Text.ResolvedProperties = .init()

        package init() {
            _openSwiftUIEmptyStub()
        }

        package mutating func append<S>(
            _ string: S,
            in env: EnvironmentValues,
            with options: Text.ResolveOptions,
            isUniqueSizeVariant: Bool
        ) where S: StringProtocol {
            _openSwiftUIUnimplementedFailure()
        }

        package mutating func append(
            _ attributedString: NSAttributedString,
            in env: EnvironmentValues,
            with options: Text.ResolveOptions,
            isUniqueSizeVariant: Bool
        ) {
            _openSwiftUIUnimplementedFailure()
        }

//        package mutating func append(
//            _ image: Image.Resolved,
//            in environment: EnvironmentValues,
//            with options: Text.ResolveOptions
//        ) {
//            _openSwiftUIUnimplementedFailure()
//        }
//
//        package mutating func append(
//            _ namedImage: Image.NamedResolved,
//            in environment: EnvironmentValues,
//            with options: Text.ResolveOptions
//        ) {
//            _openSwiftUIUnimplementedFailure()
//        }
//
//        package mutating func append<R>(
//            resolvable: R,
//            in environment: EnvironmentValues,
//            with options: Text.ResolveOptions,
//            transition: ContentTransition?
//        ) where R: ResolvableStringAttribute {
//            _openSwiftUIUnimplementedFailure()
//        }
//
//        package func nsAttributes(
//            content: (() -> String)?,
//            in environment: EnvironmentValues,
//            with options: Text.ResolveOptions,
//            properties: inout Text.ResolvedProperties
//        ) -> [NSAttributedString.Key: Any] {
//            _openSwiftUIUnimplementedFailure()
//        }
    }

    // TODO
    package struct Style {}

    package struct ResolvedProperties {
        package var insets: EdgeInsets

        package var features: Text.ResolvedProperties.Features

        package var styles: [_ShapeStyle_Pack.Style]

        package var transitions: [Text.ResolvedProperties.Transition]

        // package var suffix: ResolvedTextSuffix

        package struct CustomAttachments {
            package var characterIndices: [Int]

            package init(characterIndices: [Int] = []) {
                _openSwiftUIUnimplementedFailure()
            }

            package var isEmpty: Bool {
                _openSwiftUIUnimplementedFailure()
            }
        }

        package var customAttachments: Text.ResolvedProperties.CustomAttachments

        package init() {
            _openSwiftUIUnimplementedFailure()
        }

        package mutating func registerCustomAttachment(at offset: Int) {
            _openSwiftUIUnimplementedFailure()
        }

        package struct Features: OptionSet {
            package let rawValue: UInt16

            package init(rawValue: UInt16) {
                _openSwiftUIUnimplementedFailure()
            }

            package static let keyColor: Text.ResolvedProperties.Features = .init(rawValue: 1 << 0)

            package static let attachments: Text.ResolvedProperties.Features = .init(rawValue: 1 << 1)

            package static let sensitive: Text.ResolvedProperties.Features = .init(rawValue: 1 << 2)

            package static let customRenderer: Text.ResolvedProperties.Features = .init(rawValue: 1 << 3)

            package static let useTextLayoutManager: Text.ResolvedProperties.Features = .init(rawValue: 1 << 4)

            package static let useTextSuffix: Text.ResolvedProperties.Features = .init(rawValue: 1 << 5)

            package static let produceTextLayout: Text.ResolvedProperties.Features = .init(rawValue: 1 << 6)

            package static let checkInterpolationStrategy: Text.ResolvedProperties.Features = .init(rawValue: 1 << 8)

            package static let isUniqueSizeVariant: Text.ResolvedProperties.Features = .init(rawValue: 1 << 8)
        }

        package struct Transition: Equatable {
            package var transition: ContentTransition

            package init(transition: ContentTransition) {
                self.transition = transition
            }
        }

        package struct Paragraph {
            // package var compositionLanguage: NSCompositionLanguage
        }

        package var paragraph: Text.ResolvedProperties.Paragraph

        package mutating func addColor(_ c: Color.Resolved) {
            _openSwiftUIUnimplementedFailure()
        }

        package mutating func addAttachment() {
            _openSwiftUIUnimplementedFailure()
        }

        package mutating func addSensitive() {
            _openSwiftUIUnimplementedFailure()
        }

        package mutating func addCustomStyle(_ style: _ShapeStyle_Pack.Style) -> Color.Resolved {
            _openSwiftUIUnimplementedFailure()
        }
    }
}

extension Text {
    struct ResolvedString: ResolvedTextContainer {
        var style: Text.Style = .init()
        var idiom: AnyInterfaceIdiom?
        var string: String = ""
        var hasResolvableAttributes: Bool = false

        init() {}

        mutating func append<S>(
            _ string: S,
            in env: EnvironmentValues,
            with options: Text.ResolveOptions,
            isUniqueSizeVariant: Bool
        ) where S: StringProtocol {
            var s = String(string).caseConvertedIfNeeded(env)
            if env.shouldRedactContent {
                s = String(repeating: "􀮷", count: s.count)
            }
            self.string.append(s)
        }

        mutating func append(
            _ attributedString: NSAttributedString,
            in env: EnvironmentValues,
            with options: Text.ResolveOptions,
            isUniqueSizeVariant: Bool
        ) {
            append(
                attributedString.string,
                in: env,
                with: options,
                isUniqueSizeVariant: isUniqueSizeVariant
            )
        }
    }
}

extension EnvironmentValues {
    private struct DisableLinkColorKey: EnvironmentKey {
        static var defaultValue: Bool { false }
    }

    package var disableLinkColor: Bool {
        get { self[DisableLinkColorKey.self] }
        set { self[DisableLinkColorKey.self] = newValue }
    }
}
