//
//  FunctionalAppearanceAssetView.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete

#if os(macOS) && OPENSWIFTUI_LINK_COREUI

// MARK: - FunctionalAppearanceAssetView

package struct FunctionalAppearanceAssetView<AssetKey, Content>: AppearanceAssetReadingView where AssetKey: AppearanceAssetKey, Content: View {
    package var assetKey: AssetKey
    package var content: (AssetKey.AssetType?) -> Content

    package init(assetKey: AssetKey, content: @escaping (AssetKey.AssetType?) -> Content) {
        self.assetKey = assetKey
        self.content = content
    }

    package func body(values: AppearanceAssetValues) -> Content {
        content(values.asset(for: assetKey))
    }
}

// MARK: - EnvironmentValues + asset

extension EnvironmentValues {
    package static func asset<K, V>(
        for key: K,
        _ content: @escaping (K.AssetType?) -> V
    ) -> FunctionalAppearanceAssetView<K, V> where K: AppearanceAssetKey, V: View {
        FunctionalAppearanceAssetView(assetKey: key, content: content)
    }
}
#endif
