//
//  TypesettingConfiguration.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete

// MARK: - TypesettingConfiguration

package struct TypesettingConfiguration: Equatable {
    package var language: TypesettingLanguage

    package var languageAwareLineHeightRatio: TypesettingLanguageAwareLineHeightRatio

    package init(
        language: TypesettingLanguage = .automatic,
        languageAwareLineHeightRatio: TypesettingLanguageAwareLineHeightRatio = .automatic
    ) {
        self.language = language
        self.languageAwareLineHeightRatio = languageAwareLineHeightRatio
    }
}

package struct TypesettingConfigurationKey: EnvironmentKey {
    package static let defaultValue: TypesettingConfiguration = .init()
}

extension EnvironmentValues {
    package var typesettingConfiguration: TypesettingConfiguration {
        get { self[TypesettingConfigurationKey.self] }
        set { self[TypesettingConfigurationKey.self] = newValue }
    }
}
