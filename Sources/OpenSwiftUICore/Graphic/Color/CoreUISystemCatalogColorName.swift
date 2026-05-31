//
//  CoreUISystemCatalogColorName.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete

#if os(macOS)

// MARK: - CoreUISystemCatalogColorName

package struct CoreUISystemCatalogColorName: AppearanceAssetKey, RawRepresentable, Hashable, ExpressibleByStringLiteral {
    package typealias AssetType = (Color.Resolved, BlendMode)

    package var rawValue: String

    package init(rawValue: String) {
        self.rawValue = rawValue
    }

    package init(stringLiteral value: StringLiteralType) {
        self.init(rawValue: value)
    }

    package static let keySelectionText: CoreUISystemCatalogColorName = "alternateSelectedControlTextColor"
    package static let controlText: CoreUISystemCatalogColorName = "controlTextColor"
    package static let label: CoreUISystemCatalogColorName = "labelColor"
    package static let secondaryLabel: CoreUISystemCatalogColorName = "secondaryLabelColor"
    package static let tertiaryLabel: CoreUISystemCatalogColorName = "tertiaryLabelColor"
    package static let quaternaryLabel: CoreUISystemCatalogColorName = "quaternaryLabelColor"
    package static let quinaryLabel: CoreUISystemCatalogColorName = "quinaryLabelColor"
}

// MARK: - AppearanceCatalogShapeStyle

package struct AppearanceCatalogShapeStyle: ShapeStyle, PrimitiveShapeStyle {
    package var catalogName: String

    package init(catalogName: String) {
        self.catalogName = catalogName
    }

    package func _apply(to shape: inout _ShapeStyle_Shape) {
        let name = CoreUISystemCatalogColorName(rawValue: catalogName)
        let environment = shape.environment
        let accentColor = Color.accentColor.resolve(in: environment)
        let asset = environment
            .appearance(allowsVibrantBlending: nil)
            .asset(
                for: name,
                accentColor: accentColor
            ) ?? (.clear, .normal)

        switch shape.operation {
        case .fallbackColor:
            let color = fallbackColor(asset: asset, name: name, environment: environment)
            shape.result = .color(Color(color))
        default:
            let (color, blendMode) = asset
            _BlendModeShapeStyle(style: color, blendMode: blendMode)._apply(to: &shape)
        }
    }

    @inline(__always)
    private func fallbackColor(
        asset: CoreUISystemCatalogColorName.AssetType,
        name: CoreUISystemCatalogColorName,
        environment: EnvironmentValues
    ) -> Color.Resolved {
        let (color, blendMode) = asset
        guard blendMode != .normal else {
            return color
        }
        var environment = environment
        environment.allowsVibrantBlending = false
        let accentColor = Color.accentColor.resolve(in: environment)
        return environment
            .appearance(allowsVibrantBlending: nil)
            .asset(
                for: name,
                accentColor: accentColor
            )?
            .0 ?? color
    }
}

// MARK: - Color + CoreUISystemCatalogColorName

extension Color {
    package init(appearanceName: CoreUISystemCatalogColorName) {
        self.init(provider: AppearanceColorProvider(name: appearanceName))
    }

    package struct AppearanceColorProvider: ColorProvider {
        package var name: CoreUISystemCatalogColorName

        package init(name: CoreUISystemCatalogColorName) {
            self.name = name
        }

        package func resolve(in environment: EnvironmentValues) -> Color.Resolved {
            environment
                .appearance(allowsVibrantBlending: nil)
                .asset(
                    for: name,
                    accentColor: Color.accentColor.resolve(in: environment)
                )?
                .0 ?? .clear
        }

        package var colorDescription: String {
            String(describing: name)
        }
    }
}

#endif
