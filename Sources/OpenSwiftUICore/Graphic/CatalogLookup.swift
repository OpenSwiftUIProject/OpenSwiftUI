//
//  CatalogLookup.swift
//  OpenSwiftUICore
//
//  Status: Complete
//  ID: 7D88FB88100BA54A0D48F777CDF70C18 (SwiftUICore)

// MARK: - CatalogKey [6.4.41]

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

extension CatalogKey: ProtobufMessage {
    package func encode(to encoder: inout ProtobufEncoder) throws {
        encoder.enumField(1, colorScheme, defaultValue: .light)
        encoder.enumField(2, contrast, defaultValue: .standard)
    }

    package init(from decoder: inout ProtobufDecoder) throws {
        var colorScheme = ColorScheme.light
        var contrast = ColorSchemeContrast.standard
        while let field = try decoder.nextField() {
            switch field.tag {
            case 1: colorScheme = try decoder.enumField(field) ?? .light
            case 2: contrast = try decoder.enumField(field) ?? .standard
            default: try decoder.skipField(field)
            }
        }
        self.init(colorScheme: colorScheme, contrast: contrast)
    }
}

// MARK: - CatalogAssetMatchType [6.4.41]

package enum CatalogAssetMatchType: Equatable {
    case always
    case appearance
    case cuiIdiom(Int)

    package static func defaultValue(idiom: Int) -> [CatalogAssetMatchType] {
        guard idiom == 8 else {
            return [.appearance]
        }
        return [.cuiIdiom(idiom), .appearance]
    }
}

// MARK: - EnvironmentValues + CoreUI [6.4.41]

extension EnvironmentValues {
    private struct CUIAsssetIdiomKey: EnvironmentKey {
        static let defaultValue: Int = .zero
    }

    package var cuiAssetIdiom: Int {
        get { self[CUIAsssetIdiomKey.self] }
        set { self[CUIAsssetIdiomKey.self] = newValue }
    }

    private struct CUIAssetSubtypeKey: EnvironmentKey {
        static let defaultValue: Int = .zero
    }

    package var cuiAssetSubtype: Int {
        get { self[CUIAssetSubtypeKey.self] }
        set { self[CUIAssetSubtypeKey.self] = newValue }
    }

    private struct CUIAssetMatchTypesKey: EnvironmentKey {
        static let defaultValue: [CatalogAssetMatchType] = []
    }

    package var cuiAssetMatchTypes: [CatalogAssetMatchType] {
        get { self[CUIAssetMatchTypesKey.self] }
        set { self[CUIAssetMatchTypesKey.self] = newValue }
    }
}
