//
//  TypesettingLanguageAwareLineHeightRatio.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete

// MARK: - TypesettingLanguageAwareLineHeightRatio

@_spi(Private)
@available(OpenSwiftUI_v5_0, *)
public struct TypesettingLanguageAwareLineHeightRatio: Sendable, Equatable {
    enum Storage: Equatable {
        case custom(Double)
        case automatic
        case disable
        case legacy
    }

    var storage: TypesettingLanguageAwareLineHeightRatio.Storage

    public static let automatic: TypesettingLanguageAwareLineHeightRatio = .init(storage: .automatic)

    public static let disable: TypesettingLanguageAwareLineHeightRatio = .init(storage: .disable)

    public static let legacy: TypesettingLanguageAwareLineHeightRatio = .init(storage: .legacy)

    public static func custom(_ ratio: Double) -> TypesettingLanguageAwareLineHeightRatio {
        .init(storage: .custom(ratio.clamp(min: 0.0, max: 1.0)))
    }
}

// MARK: - View + typesettingLanguageAwareLineHeightRatio

@available(OpenSwiftUI_v1_0, *)
extension View {
    @_spi(Private)
    @available(OpenSwiftUI_v5_0, *)
    nonisolated public func typesettingLanguageAwareLineHeightRatio(
        _ ratio: TypesettingLanguageAwareLineHeightRatio,
        isEnabled: Bool = true
    ) -> some View {
        transformEnvironment(\.typesettingConfiguration) {
            if isEnabled {
                $0.languageAwareLineHeightRatio = ratio
            }
        }
    }
}

// MARK: - LanguageAwareLineHeightRatioTextModifier

class LanguageAwareLineHeightRatioTextModifier: AnyTextModifier {
    let ratio: TypesettingLanguageAwareLineHeightRatio

    init(ratio: TypesettingLanguageAwareLineHeightRatio) {
        self.ratio = ratio
    }

    override func modify(style: inout Text.Style, environment: EnvironmentValues) {
        style.typesettingConfiguration.languageAwareLineHeightRatio = ratio
    }

    override func isEqual(to other: AnyTextModifier) -> Bool {
        guard let other = other as? LanguageAwareLineHeightRatioTextModifier else {
            return false
        }
        return ratio == other.ratio
    }
}

// MARK: - Text + typesettingLanguageAwareLineHeightRatio

@available(OpenSwiftUI_v1_0, *)
extension Text {
    @_spi(Private)
    @available(OpenSwiftUI_v5_0, *)
    public func typesettingLanguageAwareLineHeightRatio(
        _ ratio: TypesettingLanguageAwareLineHeightRatio,
        isEnabled: Bool = true
    ) -> Text {
        guard isEnabled else {
            return self
        }
        return modified(with: .anyTextModifier(LanguageAwareLineHeightRatioTextModifier(ratio: ratio)))
    }
}
