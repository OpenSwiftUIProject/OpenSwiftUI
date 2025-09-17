//
//  ResolvedTextContainer.swift
//  OpenSwiftUICore

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
