//
//  RedactionReasons.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Blocked by Image
//  ID: 18671928047E57F039DC339288B6FAFB (SwiftUICore)

// MARK: - RedactionReasons

/// The reasons to apply a redaction to data displayed on screen.
@available(OpenSwiftUI_v2_0, *)
public struct RedactionReasons: OptionSet, Sendable {
    public let rawValue: Int

    public init(rawValue: Int) {
        self.rawValue = rawValue
    }

    /// Displayed data should appear as generic placeholders.
    ///
    /// Text and images will be automatically masked to appear as
    /// generic placeholders, though maintaining their original size and shape.
    /// Use this to create a placeholder UI without directly exposing
    /// placeholder data to users.
    public static let placeholder: RedactionReasons = .init(rawValue: 1 << 0)

    /// Displayed data should be obscured to protect private information.
    ///
    /// Views marked with `privacySensitive` will be automatically redacted
    /// using a standard styling. To apply a custom treatment the redaction
    /// reason can be read out of the environment.
    ///
    ///     struct BankingContentView: View {
    ///         @Environment(\.redactionReasons) var redactionReasons
    ///
    ///         var body: some View {
    ///             if redactionReasons.contains(.privacy) {
    ///                 FullAppCover()
    ///             } else {
    ///                 AppContent()
    ///             }
    ///         }
    ///     }
    @available(OpenSwiftUI_v3_0, *)
    public static let privacy: RedactionReasons = .init(rawValue: 1 << 1)

    /// Displayed data should appear as invalidated and pending a new update.
    ///
    /// Views marked with `invalidatableContent` will be automatically
    /// redacted with a standard styling indicating the content is invalidated
    /// and new content will be available soon.
    @available(OpenSwiftUI_v5_0, *)
    public static let invalidated: RedactionReasons = .init(rawValue: 1 << 2)

    @_spi(Private)
    @available(OpenSwiftUI_v6_0, *)
    public static let screencaptureProhibited: RedactionReasons = .init(rawValue: 1 << 3)
}

// MARK: - View + redacted

@available(OpenSwiftUI_v2_0, *)
extension View {

    /// Adds a reason to apply a redaction to this view hierarchy.
    ///
    /// Adding a redaction is an additive process: any redaction
    /// provided will be added to the reasons provided by the parent.
    nonisolated public func redacted(reason: RedactionReasons) -> some View {
        transformEnvironment(\.redactionReasons) {
            $0.insert(reason)
        }
    }

    /// Removes any reason to apply a redaction to this view hierarchy.
    nonisolated public func unredacted() -> some View {
        environment(\.redactionReasons, [])
    }
}

// MARK: - EnvironmentValues + RedactionReasons

private struct RedactionReasonsKey: EnvironmentKey {
    static let defaultValue: RedactionReasons = []
}

private struct ShouldRedactContentKey: DerivedEnvironmentKey {
    static func value(in environment: EnvironmentValues) -> Bool {
        let redactionReasons = environment.redactionReasons
        if redactionReasons.contains(.placeholder) {
            return true
        } else if redactionReasons.contains(.privacy) {
            return environment.sensitiveContent
        } else {
            return false
        }
    }
}

private struct UnredactSymbolImage: EnvironmentKey {
    static let defaultValue: Bool = false
}

private struct ShouldRedactSymbolImagesKey: DerivedEnvironmentKey {
    static func value(in environment: EnvironmentValues) -> Bool {
        guard environment.shouldRedactContent else {
            return false
        }
        return !environment.unredactSymbolImage
    }
}

extension EnvironmentValues {
    package var shouldRedactContent: Bool {
        self[ShouldRedactContentKey.self]
    }
}

@_spi(Private)
@available(OpenSwiftUI_v6_0, *)
extension EnvironmentValues {

    public var unredactSymbolImage: Bool {
        get { self[UnredactSymbolImage.self] }
        set { self[UnredactSymbolImage.self] = newValue }
    }

    package var shouldRedactSymbolImages: Bool {
        self[ShouldRedactSymbolImagesKey.self]
    }
}

@available(OpenSwiftUI_v2_0, *)
extension EnvironmentValues {

    /// The current redaction reasons applied to the view hierarchy.
    public var redactionReasons: RedactionReasons {
        get { self[RedactionReasonsKey.self] }
        set { self[RedactionReasonsKey.self] = newValue }
    }
}

// MARK: - Image + redacted [TODO]

extension GraphicsImage {
    package mutating func redact(in environment: EnvironmentValues) {
        _openSwiftUIUnimplementedFailure()
    }
}

extension Image {
    package static let redacted: Image = {
        _openSwiftUIUnimplementedFailure()
    }()
}
