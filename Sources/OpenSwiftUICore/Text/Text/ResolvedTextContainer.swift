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

extension Text {
    // TODO
    package struct Style {}
}

extension ResolvedTextContainer {
    // TODO
    mutating func append<S>(
        _ string: S,
        in env: EnvironmentValues,
        with options: Text.ResolveOptions,
    ) where S: StringProtocol {
        _openSwiftUIUnimplementedFailure()
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
