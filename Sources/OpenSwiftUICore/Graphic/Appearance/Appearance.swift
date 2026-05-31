//
//  Appearance.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete (Blocked by CatalogAppearance)
//  ID: 1A9A53F98573644BA5D4D23074F52071 (SwiftUICore)

#if os(macOS)

import Foundation

// MARK: - Appearance

package struct Appearance: Hashable {
    private var provider: any AppearanceBoxBase

    package init<P>(provider: P) where P: AppearanceProvider {
        self.provider = AppearanceBox(provider)
    }

    package func resolve(in environment: EnvironmentValues) -> any _ResolvedAppearance {
        provider.resolve(in: environment)
    }

    package func hash(into hasher: inout Hasher) {
        provider.hash(into: &hasher)
    }

    package static func == (lhs: Appearance, rhs: Appearance) -> Bool {
        lhs.provider.isEqual(to: rhs.provider)
    }
}

package protocol AppearanceProvider: Hashable {
    func resolve(in environment: EnvironmentValues) -> any _ResolvedAppearance
}

private protocol AppearanceBoxBase: AnyObject {
    func resolve(in environment: EnvironmentValues) -> any _ResolvedAppearance

    func hash(into hasher: inout Hasher)

    func isEqual(to other: any AppearanceBoxBase) -> Bool
}

private final class AppearanceBox<P>: AppearanceBoxBase where P: AppearanceProvider {
    let provider: P

    init(_ provider: P) {
        self.provider = provider
    }

    func resolve(in environment: EnvironmentValues) -> any _ResolvedAppearance {
        provider.resolve(in: environment)
    }

    func hash(into hasher: inout Hasher) {
        provider.hash(into: &hasher)
    }

    func isEqual(to other: any AppearanceBoxBase) -> Bool {
        guard let other = other as? AppearanceBox<P> else {
            return false
        }
        return provider == other.provider
    }
}

// MARK: - _ResolvedAppearance

package protocol _ResolvedAppearance {
    func asset<K>(
        for key: K,
        accentColor: @autoclosure () -> Color.Resolved
    ) -> K.AssetType? where K: AppearanceAssetKey

    func containsAsset<K>(for key: K) -> Bool where K: AppearanceAssetKey

    func isEqual(to other: any _ResolvedAppearance) -> Bool

    func hash(into hasher: inout Hasher)
}

extension _ResolvedAppearance {
    package func asset<K>(for key: K) -> K.AssetType? where K: AppearanceAssetKey {
        asset(for: key, accentColor: Color.Resolved.blue)
    }

    package func containsAsset<K>(for key: K) -> Bool where K: AppearanceAssetKey {
        asset(for: key) != nil
    }
}

package protocol AppearanceAssetKey {
    associatedtype AssetType
}

extension EnvironmentValues {
    package func appearance(allowsVibrantBlending: Bool?) -> any _ResolvedAppearance {
        let allowsVibrantBlending = allowsVibrantBlending ?? self.allowsVibrantBlending
        #if OPENSWIFTUI_LINK_COREUI
        _openSwiftUIUnimplementedWarning()
        // TODO: CatalogAppearance
        return CatalogAppearance(
            renderer: unsafeBitCast(NSObject(), to: OpaquePointer.self),
            catalog: .init(),
            name: "",
            bundle: .main,
            defaultBlendMode: .multiply
        )
        #else
        _openSwiftUIPlatformUnimplementedFailure()
        #endif
    }
}

#endif
