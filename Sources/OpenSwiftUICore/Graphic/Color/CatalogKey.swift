//
//  CatalogKey.swift
//  OpenSwiftUICore
//
//  Audited for iOS 18.0
//  Status: Complete

package struct CatalogKey: Hashable {
    package var colorScheme: ColorScheme

    package var contrast: ColorSchemeContrast

    package init(colorScheme: ColorScheme, contrast: ColorSchemeContrast) {
        self.colorScheme = colorScheme
        self.contrast = contrast
    }

    package init(_ environment: EnvironmentValues) {
        colorScheme = environment.colorScheme
        contrast = environment.colorSchemeContrast
    }
}
