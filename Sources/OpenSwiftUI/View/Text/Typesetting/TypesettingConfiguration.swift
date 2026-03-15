//
//  TypesettingConfiguration.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete

#if canImport(UIKit)
package import UIKit

// MARK: - TypesettingConfigurationKey + UITraitBridgedEnvironmentKey

extension TypesettingConfigurationKey: UITraitBridgedEnvironmentKey {
    package static func read(from traitCollection: UITraitCollection) -> TypesettingConfiguration {
        if let language = traitCollection.typesettingLanguage {
            TypesettingConfiguration(language: .explicit(language))
        } else {
            TypesettingConfiguration(language: .automatic)
        }
    }

    package static func write(to mutableTraits: inout any UIMutableTraits, value: TypesettingConfiguration) {
        switch value.language.storage {
        case .explicit(let language, _):
            mutableTraits.typesettingLanguage = language
        case .automatic, .contentAware:
            mutableTraits.typesettingLanguage = nil
        @unknown default:
            _openSwiftUIUnreachableCode()
        }
    }
}
#endif
