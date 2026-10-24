//
//  CompositeAppearance.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: WIP
//  ID: 4AC443F5048123F20C2A54F77682C1C8 (SwiftUICore)

#if os(macOS)

package struct _ResolvedCompositeAppearance: _ResolvedAppearance {
    package var appearanceStack: [any _ResolvedAppearance]

    package init(_ appearances: [any _ResolvedAppearance]) {
        appearanceStack = appearances.flattenComposites()
    }

    package func resolvedAppearance<K>(for key: K) -> (any _ResolvedAppearance)? where K: AppearanceAssetKey {
        appearanceStack.reversed().first { $0.containsAsset(for: key) }
    }

    package func asset<K>(
        for key: K,
        accentColor: @autoclosure () -> Color.Resolved
    ) -> K.AssetType? where K: AppearanceAssetKey {
        resolvedAppearance(for: key)?.asset(for: key, accentColor: accentColor())
    }

    package func containsAsset<K>(for key: K) -> Bool where K: AppearanceAssetKey {
        resolvedAppearance(for: key) != nil
    }

    package func isEqual(to other: any _ResolvedAppearance) -> Bool {
        guard let other = other as? _ResolvedCompositeAppearance,
              appearanceStack.count == other.appearanceStack.count else {
            return false
        }
        return zip(appearanceStack, other.appearanceStack).allSatisfy { $0.isEqual(to: $1) }
    }

    package func hash(into hasher: inout Hasher) {
        for appearance in appearanceStack {
            appearance.hash(into: &hasher)
        }
    }
}

extension Collection where Element == any _ResolvedAppearance {
    fileprivate func flattenComposites() -> [any _ResolvedAppearance] {
        flatMap { appearance in
            if let composite = appearance as? _ResolvedCompositeAppearance {
                composite.appearanceStack.flattenComposites()
            } else {
                [appearance]
            }
        }
    }
}

#endif
