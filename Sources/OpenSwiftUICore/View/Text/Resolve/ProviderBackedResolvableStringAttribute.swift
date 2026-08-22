//
//  ProviderBackedResolvableStringAttribute.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete

#if canImport(Darwin)
import OpenSwiftUI_SPI

protocol ProviderBackedResolvableStringAttribute: ConfigurationBasedResolvableStringAttribute {
    var provider: BaseDateProvider? { get }
}

extension ProviderBackedResolvableStringAttribute {
    package var invalidationConfiguration: ResolvableAttributeConfiguration {
        provider?.updateConfiguration ?? .none
    }
}
#endif
