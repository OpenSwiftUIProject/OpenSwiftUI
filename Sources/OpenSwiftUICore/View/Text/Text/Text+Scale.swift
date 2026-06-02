//
//  Text+Scale.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete

@available(OpenSwiftUI_v1_0, *)
extension Text {

    /// Defines text scales
    ///
    /// Text scale provides a way to pick a logical text scale
    /// relative to the base font which is used.
    @available(OpenSwiftUI_v5_0, *)
    public struct Scale: Sendable, Hashable {
        package enum Storage: UInt8, Hashable, Sendable {
            case `default`
            case secondary
        }

        package var storage: Text.Scale.Storage

        package init(storage: Text.Scale.Storage) {
            self.storage = storage
        }

        /// Defines default text scale
        ///
        /// When specified uses the default text scale.
        public static let `default`: Text.Scale = .init(storage: .default)

        /// Defines secondary text scale
        ///
        /// When specified a uses a secondary text scale.
        public static let secondary: Text.Scale = .init(storage: .secondary)
    }
}

extension Text.Scale {
    package init?(_ string: String) {
        guard string == "NSTextScaleSecondary" else {
            return nil
        }
        self = .secondary
    }
}

// MARK: - Text + textScale

@available(OpenSwiftUI_v1_0, *)
extension Text {

    /// Applies a text scale to the text.
    ///
    /// - Parameters:
    ///   - scale: The text scale to apply.
    ///   - isEnabled: If true the text scale is applied; otherwise text scale
    ///     is unchanged.
    /// - Returns: Text with the specified scale applied.
    @available(OpenSwiftUI_v5_0, *)
    public func textScale(_ scale: Text.Scale, isEnabled: Bool = true) -> Text {
        modified(with: .anyTextModifier(TextScaleModifier(scale: scale, isEnabled: isEnabled)))
    }
}

// MARK: - TextScaleModifier

final class TextScaleModifier: AnyTextModifier {
    var isEnabled: Bool

    var scale: Text.Scale

    package init(scale: Text.Scale, isEnabled: Bool) {
        self.isEnabled = isEnabled
        self.scale = scale
    }

    override func modify(style: inout Text.Style, environment: EnvironmentValues) {
        guard isEnabled else {
            return
        }
        style.scale = scale
    }

    override func isEqual(to other: AnyTextModifier) -> Bool {
        guard let other = other as? TextScaleModifier else {
            return false
        }
        return scale == other.scale
    }
}

// MARK: - View + textScale

@available(OpenSwiftUI_v1_0, *)
extension View {

    /// Applies a text scale to text in the view.
    ///
    /// - Parameters:
    ///   - scale: The text scale to apply.
    ///   - isEnabled: If true the text scale is applied; otherwise text scale
    ///     is unchanged.
    /// - Returns: A view with the specified text scale applied.
    @available(OpenSwiftUI_v5_0, *)
    nonisolated public func textScale(
        _ scale: Text.Scale,
        isEnabled: Bool = true
    ) -> some View {
        transformEnvironment(\.textScale) {
            if isEnabled {
                $0 = scale
            }
        }
    }
}

// MARK: - TextScaleKey

struct TextScaleKey: EnvironmentKey {
    static var defaultValue: Text.Scale? { nil }
}

extension EnvironmentValues {
    var textScale: Text.Scale? {
        get { self[TextScaleKey.self] }
        set { self[TextScaleKey.self] = newValue }
    }
}
