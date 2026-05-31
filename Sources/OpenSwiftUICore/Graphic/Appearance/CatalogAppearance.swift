//
//  CatalogAppearance.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: WIP

#if os(macOS) && OPENSWIFTUI_LINK_COREUI
import CoreUI

// FIXME
struct CatalogAppearance: _ResolvedAppearance, Hashable {
    let renderer: OpaquePointer
    let catalog: CUICatalog
    let name: String
    let bundle: Bundle
    let defaultBlendMode: BlendMode

    func asset<K>(
        for key: K,
        accentColor: @autoclosure () -> Color.Resolved
    ) -> K.AssetType? where K: AppearanceAssetKey {
        _openSwiftUIUnimplementedWarning()
        return nil
    }
    
    func isEqual(to other: any _ResolvedAppearance) -> Bool {
        guard let other = other as? CatalogAppearance else {
            return false
        }
        return self == other
    }

    static func == (lhs: CatalogAppearance, rhs: CatalogAppearance) -> Bool {
        lhs.name == rhs.name && lhs.bundle == rhs.bundle
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
        hasher.combine(bundle)
    }
}
#endif
