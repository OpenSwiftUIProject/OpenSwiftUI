//
//  AppearanceGlyphEffect.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete

#if os(macOS)
import Foundation
import QuartzCore_Private
#if OPENSWIFTUI_LINK_COREUI
import CoreUI
#endif

// MARK: - AppearanceStyleEffectConfiguration

package struct AppearanceStyleEffectConfiguration: Hashable {
    package enum Value: Hashable {
        case off, on, mixed
    }

    package enum PresentationState: Hashable {
        case active, inactive, activeMain
    }

    package enum StateType: Hashable {
        case normal, rollover, pressed, disabled, deeplyPressed
    }

    package enum BackgroundType: Hashable {
        case normal, borderless, sourceList, emphasized
    }

    package enum SelectionType: Hashable {
        case primary, secondary, tertiary, quaternary, quinary
    }

    package let state: StateType
    package let backgroundType: BackgroundType
    package var presentationState: PresentationState
    package let value: Value
    package let effectScale: CGFloat
    package let selectionType: SelectionType?
    package let useSimplifiedEffect: Bool?
    package var foregroundColorShouldTintEffects: Bool?
    package let brightnessMultiplier: Double?
    package let colorTemperature: UInt?

    package init(
        state: StateType = .normal,
        backgroundType: BackgroundType = .normal,
        presentationState: PresentationState = .active,
        value: Value = .off,
        selectionType: SelectionType? = nil,
        effectScale: CGFloat,
        useSimplifiedEffect: Bool? = nil
    ) {
        self.state = state
        self.backgroundType = backgroundType
        self.presentationState = presentationState
        self.value = value
        self.effectScale = effectScale
        self.selectionType = selectionType
        self.useSimplifiedEffect = useSimplifiedEffect
        self.brightnessMultiplier = nil
        self.colorTemperature = nil
    }
}

#if OPENSWIFTUI_LINK_COREUI
extension AppearanceStyleEffectConfiguration {
    var coreUIConfiguration: CUIStyleEffectConfiguration {
        let configuration = CUIBackgroundStyleEffectConfiguration()
        configuration.shouldRespectOutputBlending = false
        configuration.state = switch state {
        case .normal: .normal
        case .rollover: .rollover
        case .pressed: .pressed
        case .disabled: .disabled
        case .deeplyPressed: .deeplyPressed
        }
        configuration.presentationState = switch presentationState {
        case .active: .active
        case .inactive: .inactive
        case .activeMain: .activeMain
        }
        configuration.value = switch value {
        case .off: .off
        case .on: .on
        case .mixed: .mixed
        }
        configuration.effectScale = effectScale
        configuration.backgroundType = switch backgroundType {
        case .normal: (state == .pressed ? kCUIBackgroundTypeDark : kCUIBackgroundTypeLight) as String
        case .borderless: kCUIBackgroundTypeBorderless as String
        case .sourceList: kCUIBackgroundTypeSourceList as String
        case .emphasized: kCUIBackgroundTypeSelection as String
        }
        if let useSimplifiedEffect {
            configuration.useSimplifiedEffect = useSimplifiedEffect
        }
        if let foregroundColorShouldTintEffects {
            configuration.foregroundColorShouldTintEffects = foregroundColorShouldTintEffects
        }
        if let brightnessMultiplier {
            configuration.brightnessMultiplier = brightnessMultiplier
        }
        if let colorTemperature {
            configuration.colorTemperature = UInt(Int(colorTemperature))
        }
        if let selectionType {
            let index = switch selectionType {
            case .primary: 0
            case .secondary: 1
            case .tertiary: 2
            case .quaternary: 3
            case .quinary: 4
            }
            configuration.setSelectionType(index)
        }
        return configuration
    }
}
#endif

// MARK: - AppearanceGlyphEffect

package struct AppearanceGlyphEffect {
    package var foregroundColor: Color.Resolved
    package let filter: AnyObject?

    package var blendMode: GraphicsBlendMode {
        guard let filter = filter as? CAFilter else { return .normal }
        let mode = CACompositingFilterGetORBBlendMode(filter.type).rawValue
        return mode >= 0 ? .blendMode(.init(rawValue: mode)) : .caFilter(filter)
    }
}

package protocol ContentEffectingWidgetDefinition {
    var glyphEffectDefinition: AppearanceStyleEffectConfiguration { get }
}

// MARK: - AppearanceGlyphEffectKey

package struct AppearanceGlyphEffectKey: AppearanceAssetKey {
    package typealias AssetType = AppearanceGlyphEffect

    package var configuration: AppearanceStyleEffectConfiguration

    package init(configuration: AppearanceStyleEffectConfiguration) {
        self.configuration = configuration
    }

    package init(widget: any ContentEffectingWidgetDefinition) {
        self.configuration = widget.glyphEffectDefinition
    }
}

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
