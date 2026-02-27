//
//  Image+NamedImage.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: 8E7DCD4CEB1ACDE07B249BFF4CBC75C0 (SwiftUICore)

public import Foundation

// MARK: - Image named initializers

@available(OpenSwiftUI_v1_0, *)
extension Image {
    /// Creates a named image.
    ///
    /// Use this initializer to load an image stored in your app's asset
    /// catalog by name. OpenSwiftUI treats the image as accessory-level by
    /// default.
    ///
    /// Use the ``Image/init(_:bundle:label:)`` initializer instead if you
    /// want to provide accessibility information about the image.
    ///
    /// - Parameters:
    ///   - name: The name of the image resource to look up.
    ///   - bundle: The bundle in which to search for the image resource. If
    ///     you don't indicate a bundle, the initializer looks in your app's
    ///     main bundle by default.
    public init(_ name: String, bundle: Bundle? = nil) {
        self.init(
            NamedImageProvider(
                name: name,
                location: .bundle(bundle ?? Bundle.main),
                label: AccessibilityImageLabel(name),
                decorative: false
            )
        )
    }

    /// Creates a labeled named image.
    ///
    /// Creates an image by looking for a named resource in the specified
    /// bundle. The system uses the provided label text for accessibility.
    ///
    /// - Parameters:
    ///   - name: The name of the image resource to look up.
    ///   - bundle: The bundle in which to search for the image resource.
    ///     If you don't indicate a bundle, the initializer looks in your app's
    ///     main bundle by default.
    ///   - label: The label text to use for accessibility.
    public init(_ name: String, bundle: Bundle? = nil, label: Text) {
        self.init(
            NamedImageProvider(
                name: name,
                location: .bundle(bundle ?? Bundle.main),
                label: AccessibilityImageLabel(label),
                decorative: false
            )
        )
    }

    /// Creates a decorative named image.
    ///
    /// Creates an image by looking for a named resource in the specified
    /// bundle. The accessibility system ignores decorative images.
    ///
    /// - Parameters:
    ///   - name: The name of the image resource to look up.
    ///   - bundle: The bundle in which to search for the image resource.
    ///     If you don't indicate a bundle, the initializer looks in your app's
    ///     main bundle by default.
    public init(decorative name: String, bundle: Bundle? = nil) {
        self.init(
            NamedImageProvider(
                name: name,
                location: .bundle(bundle ?? Bundle.main),
                label: nil,
                decorative: true
            )
        )
    }

    /// Creates a system symbol image.
    ///
    /// Use this initializer to load an SF Symbols image by name.
    ///
    /// - Parameter systemName: The name of the system symbol image.
    @available(macOS, introduced: 11.0)
    public init(systemName: String) {
        self.init(
            NamedImageProvider(
                name: systemName,
                location: .system,
                label: .systemSymbol(systemName),
                decorative: false
            )
        )
    }

    /// Creates a system symbol image for internal use.
    ///
    /// - Parameter systemName: The name of the system symbol image.
    @available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *)
    public init(_internalSystemName systemName: String) {
        self.init(
            NamedImageProvider(
                name: systemName,
                location: .system,
                label: .systemSymbol(systemName),
                decorative: false,
                backupLocation: .privateSystem
            )
        )
    }
}

// MARK: - Image named initializers with variableValue

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
extension Image {
    /// Creates a named image with a variable value.
    ///
    /// This initializer creates an image using a named image resource, with
    /// an optional variable value that some symbol images use to customize
    /// their appearance.
    ///
    /// - Parameters:
    ///   - name: The name of the image resource to look up.
    ///   - variableValue: An optional value between `0.0` and `1.0` that
    ///     the rendered image can use to customize its appearance, if
    ///     specified. If the symbol doesn't support variable colors, this
    ///     parameter has no effect. Use the SF Symbols app to look up which
    ///     symbols support variable colors.
    ///   - bundle: The bundle in which to search for the image resource.
    ///     If you don't indicate a bundle, the initializer looks in your app's
    ///     main bundle by default.
    public init(_ name: String, variableValue: Double?, bundle: Bundle? = nil) {
        self.init(
            NamedImageProvider(
                name: name,
                value: variableValue.map { Float($0) },
                location: .bundle(bundle ?? Bundle.main),
                label: AccessibilityImageLabel(name),
                decorative: false
            )
        )
    }

    /// Creates a labeled named image with a variable value.
    ///
    /// - Parameters:
    ///   - name: The name of the image resource to look up.
    ///   - variableValue: An optional value between `0.0` and `1.0` that
    ///     the rendered image can use to customize its appearance.
    ///   - bundle: The bundle in which to search for the image resource.
    ///     If you don't indicate a bundle, the initializer looks in your app's
    ///     main bundle by default.
    ///   - label: The label text to use for accessibility.
    public init(_ name: String, variableValue: Double?, bundle: Bundle? = nil, label: Text) {
        self.init(
            NamedImageProvider(
                name: name,
                value: variableValue.map { Float($0) },
                location: .bundle(bundle ?? Bundle.main),
                label: AccessibilityImageLabel(label),
                decorative: false
            )
        )
    }

    /// Creates a decorative named image with a variable value.
    ///
    /// - Parameters:
    ///   - name: The name of the image resource to look up.
    ///   - variableValue: An optional value between `0.0` and `1.0` that
    ///     the rendered image can use to customize its appearance.
    ///   - bundle: The bundle in which to search for the image resource.
    ///     If you don't indicate a bundle, the initializer looks in your app's
    ///     main bundle by default.
    public init(decorative name: String, variableValue: Double?, bundle: Bundle? = nil) {
        self.init(
            NamedImageProvider(
                name: name,
                value: variableValue.map { Float($0) },
                location: .bundle(bundle ?? Bundle.main),
                label: nil,
                decorative: true
            )
        )
    }

    /// Creates a system symbol image with a variable value.
    ///
    /// - Parameters:
    ///   - systemName: The name of the system symbol image.
    ///   - variableValue: An optional value between `0.0` and `1.0` that
    ///     the rendered image can use to customize its appearance.
    public init(systemName: String, variableValue: Double?) {
        self.init(
            NamedImageProvider(
                name: systemName,
                value: variableValue.map { Float($0) },
                location: .system,
                label: .systemSymbol(systemName),
                decorative: false
            )
        )
    }

    /// Creates a system symbol image with a variable value for internal use.
    ///
    /// - Parameters:
    ///   - systemName: The name of the system symbol image.
    ///   - variableValue: An optional value between `0.0` and `1.0` that
    ///     the rendered image can use to customize its appearance.
    public init(_internalSystemName systemName: String, variableValue: Double?) {
        self.init(
            NamedImageProvider(
                name: systemName,
                value: variableValue.map { Float($0) },
                location: .system,
                label: .systemSymbol(systemName),
                decorative: false,
                backupLocation: .privateSystem
            )
        )
    }
}
