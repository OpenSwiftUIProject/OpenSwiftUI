//
//  ProviderBackedResolvableStringAttribute.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete

import OpenSwiftUI_SPI

protocol ProviderBackedResolvableStringAttribute: ConfigurationBasedResolvableStringAttribute {
    var provider: BaseDateProvider? { get }
}

extension ProviderBackedResolvableStringAttribute {
    package var invalidationConfiguration: ResolvableAttributeConfiguration {
        provider?.updateConfiguration ?? .none
    }
}
