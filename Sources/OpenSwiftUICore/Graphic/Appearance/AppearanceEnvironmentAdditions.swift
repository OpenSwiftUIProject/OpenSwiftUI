//
//  AppearanceEnvironmentAdditions.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: 1B53C0F89ECCB35331EE688D023E3AF9 (SwiftUICore)

#if os(macOS)
import OpenAttributeGraphShims

// MARK: - AppearanceAssetReadingView

protocol AppearanceAssetReadingView: PrimitiveView, UnaryView {
    associatedtype AssetBody: View

    func body(values: AppearanceAssetValues) -> AssetBody
}

extension AppearanceAssetReadingView {
    nonisolated package static func _makeView(view: _GraphValue<Self>, inputs: _ViewInputs) -> _ViewOutputs {
        let child = AppearanceAssetReadingChild(
            view: view.value,
            appearance: inputs.base.resolvedAppearance
        )
        return AssetBody.makeDebuggableView(view: _GraphValue(child), inputs: inputs)
    }
}

// MARK: - AppearanceAssetValues

package struct AppearanceAssetValues {
    var appearance: any _ResolvedAppearance

    func asset<K: AppearanceAssetKey>(for key: K) -> K.AssetType? {
        appearance.asset(for: key)
    }
}

// MARK: - _GraphInputs + resolvedAppearance

extension CachedEnvironment.ID {
    static let resolvedAppearance: CachedEnvironment.ID = .init()
}

extension _GraphInputs {
    var resolvedAppearance: Attribute<any _ResolvedAppearance> {
        mapEnvironment(id: .resolvedAppearance) {
            $0.appearance(allowsVibrantBlending: nil)
        }
    }
}

// MARK: - AppearanceAssetReadingChild

private struct AppearanceAssetReadingChild<V: AppearanceAssetReadingView>: StatefulRule, CustomStringConvertible {
    @Attribute var view: V
    @Attribute var appearance: any _ResolvedAppearance
    var lastAppearance: (any _ResolvedAppearance)?

    typealias Value = V.AssetBody

    var description: String {
        "AppearanceAssetReading"
    }

    mutating func updateValue() {
        let (view, viewChanged) = $view.changedValue()
        let (appearance, appearanceChanged) = $appearance.changedValue()
        let needsAppearanceUpdate = appearanceChanged && lastAppearance?.isEqual(to: appearance) != true
        guard viewChanged || needsAppearanceUpdate || !hasValue else { return }
        lastAppearance = appearance
        value = view.body(values: AppearanceAssetValues(appearance: appearance))
    }
}
#endif
