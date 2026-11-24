//
//  AppearanceWidgetArtworkKey.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete

#if os(macOS) && OPENSWIFTUI_LINK_COREUI

// MARK: - AnyAppearanceWidgetArtworkKey

protocol AnyAppearanceWidgetArtworkKey {
    func artwork(in provider: any AppearanceWidgetArtworkProviding) -> Image?
    func hasDefinition(in provider: any AppearanceWidgetArtworkProviding) -> Bool
}

// MARK: - AppearanceWidgetArtworkProviding

protocol AppearanceWidgetArtworkProviding {
    func artwork<W>(for key: AppearanceWidgetArtworkKey<W>) -> Image?
    func containsDefinition<W>(for key: AppearanceWidgetArtworkKey<W>) -> Bool
}

// MARK: - AppearanceWidgetArtworkKey

struct AppearanceWidgetArtworkKey<W: AppearanceWidgetDefinition>: AppearanceAssetKey, AnyAppearanceWidgetArtworkKey {
    typealias AssetType = Image

    var widget: W

    init(_ widget: W) {
        self.widget = widget
    }

    func artwork(in provider: any AppearanceWidgetArtworkProviding) -> Image? {
        provider.artwork(for: self)
    }

    func hasDefinition(in provider: any AppearanceWidgetArtworkProviding) -> Bool {
        provider.containsDefinition(for: self)
    }
}

#endif
