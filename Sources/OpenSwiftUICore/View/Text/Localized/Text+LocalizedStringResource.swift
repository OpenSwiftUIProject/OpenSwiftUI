//
//  Text+LocalizedStringResource.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: 1A1BB6A07088C23EE7C52846B7BEB813 (SwiftUICore)

public import Foundation

#if canImport(Darwin)
// MARK: - Text + LocalizedStringResource

@available(OpenSwiftUI_v4_0, *)
extension Text {
    /// Creates a text view that displays a localized string resource.
    ///
    /// Use this initializer to display a localized string that is
    /// represented by a
    /// [LocalizedStringResource](https://developer.apple.com/documentation/foundation/localizedstringresource)
    ///
    ///     var object = LocalizedStringResource("pencil")
    ///     Text(object) // Localizes the resource if possible, or displays "pencil" if not.
    ///
    @available(OpenSwiftUI_v4_0, *)
    @_disfavoredOverload
    public init(_ resource: LocalizedStringResource) {
        self.init(anyTextStorage: LocalizedStringResourceStorage(resource: resource))
    }
}

// MARK: - LocalizedStringKey.StringInterpolation + LocalizedStringResource

@available(OpenSwiftUI_v4_0, *)
extension LocalizedStringKey.StringInterpolation {

    /// Appends the localized string resource to a string interpolation.
    ///
    /// Don't call this method directly; it's used by the compiler when
    /// interpreting string interpolations.
    ///
    /// - Parameters:
    ///   - value: The localized string resource to append.
    @available(OpenSwiftUI_v4_0, *)
    @_semantics("openswiftui.localized.appendInterpolation_@_specifier")
    @_semantics("swiftui.localized.appendInterpolation_@_specifier")
    public mutating func appendInterpolation(_ resource: Foundation.LocalizedStringResource) {
        let argument = LocalizedStringKey.FormatArgument(storage: .localizedStringResource(resource))
        key.append("%@")
        arguments.append(argument)
    }
}

// MARK: - LocalizedStringResourceStorage

@available(OpenSwiftUI_v4_0, *)
private final class LocalizedStringResourceStorage: AnyTextStorage, @unchecked Sendable {
    let resource: LocalizedStringResource

    init(resource: LocalizedStringResource) {
        self.resource = resource
    }

    override func resolve<T>(
        into result: inout T,
        in environment: EnvironmentValues,
        with options: Text.ResolveOptions
    ) where T: ResolvedTextContainer {
        let attributedString = resource.resolve(in: environment)
        result.append(NSAttributedString(openSwiftUIAttributedString: attributedString), in: environment, with: options)
    }

    override func isEqual(to other: AnyTextStorage) -> Bool {
        guard let other = other as? LocalizedStringResourceStorage else {
            return false
        }
        return resource == other.resource
    }

    override func isStyled(options: Text.ResolveOptions) -> Bool {
        resource.isStyled
    }

    override var localizationInfo: _LocalizationInfo {
        .localized(
            key: resource.key,
            tableName: resource.table,
            bundle: resource.bundle.openSwiftUI_resolvedBundle,
            hasFormatting: false
        )
    }
}

// MARK: - LocalizedStringResource

extension LocalizedStringResource {
    func resolve(in environment: EnvironmentValues) -> AttributedString {
        var resource = self
        resource.locale = environment.locale
        return AttributedString(localized: resource)
    }

    var isStyled: Bool {
        resolve(in: .init()).isStyled
    }
}

extension LocalizedStringResource.BundleDescription {
    var openSwiftUI_resolvedBundle: Bundle? {
        switch self {
        case .main:
            .main
        case let .atURL(url):
            Bundle(url: url)
        case let .forClass(anyClass):
            Bundle(for: anyClass)
        @unknown default:
            nil
        }
    }
}
#endif
