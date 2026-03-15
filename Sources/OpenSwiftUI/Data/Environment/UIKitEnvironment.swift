//
//  UIKitEnvironment.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: WIP
//  ID: 005A2BB2D44F4D559B7E508DC5B95FFB (SwiftUI)

#if canImport(UIKit)
import COpenSwiftUI
@_spi(ClarityBoard)
@_spi(Private)
package import OpenSwiftUICore
package import UIKit

private struct BridgedEnvironmentKeysKey: EnvironmentKey {
    static let defaultValue: [any UITraitBridgedEnvironmentKey.Type] = []
}

extension EnvironmentValues {
    @inline(__always)
    var bridgedEnvironmentKeys: [any UITraitBridgedEnvironmentKey.Type] {
        get { self[BridgedEnvironmentKeysKey.self] }
        set { self[BridgedEnvironmentKeysKey.self] = newValue }
    }
}

extension UITraitCollection {
    package func byOverriding(with environment: EnvironmentValues, viewPhase: ViewPhase, focusedValues: FocusedValues) -> UITraitCollection {
        let wrapper = EnvironmentWrapper(environment: environment, phase: viewPhase, focusedValues: focusedValues)
        return resolvedTraitCollection(with: environment, wrapper: wrapper)
    }

    @inline(__always)
    package func resolvedImageAssetOnlyTraitCollection(environment: EnvironmentValues) -> UITraitCollection {
        resolvedTraitCollection(
            with: environment,
            wrapper: unsafeBitCast(_environmentWrapper, to: EnvironmentWrapper?.self),
            forImageAssetsOnly: true
        )
    }

    private func resolvedTraitCollection(
        with environment: EnvironmentValues,
        wrapper: EnvironmentWrapper?,
        forImageAssetsOnly: Bool = false
    ) -> UITraitCollection {
        _modifyingTraits(environmentWrapper: wrapper) { mutableTraits in
            func copyValueToMutableTraits<K>(for key: K.Type) where K: UITraitBridgedEnvironmentKey {
                K.write(to: &mutableTraits, value: environment[key])
            }
            for bridgedKey in environment.bridgedEnvironmentKeys {
                copyValueToMutableTraits(for: bridgedKey)
            }
            let layoutDirection = UITraitEnvironmentLayoutDirection(environment.layoutDirection)
            if layoutDirection != mutableTraits.layoutDirection {
                mutableTraits.layoutDirection = layoutDirection
            }
            let displayScale = environment.displayScale
            if displayScale != mutableTraits.displayScale {
                mutableTraits.displayScale = displayScale
            }
            let sizeCategory = UIContentSizeCategory(dynamicTypeSize: environment.dynamicTypeSize)
            if sizeCategory != mutableTraits.preferredContentSizeCategory {
                mutableTraits.preferredContentSizeCategory = sizeCategory
            }
            let userInterfaceStyle = UIUserInterfaceStyle(environment.colorScheme)
            if userInterfaceStyle != mutableTraits.userInterfaceStyle {
                mutableTraits.userInterfaceStyle = userInterfaceStyle
            }
            let displayGamut = UIDisplayGamut(rawValue: environment.displayGamut.rawValue)!
            if displayGamut != mutableTraits.displayGamut {
                mutableTraits.displayGamut = displayGamut
            }
            if _SemanticFeature_v5.isEnabled, environment.backgroundMaterial != nil {
                if mutableTraits._vibrancy == .vibrant || mutableTraits._vibrancy == .none {
                    mutableTraits._vibrancy = .vibrant
                }
            }
            let accessibilityContrast = UIAccessibilityContrast(environment._colorSchemeContrast)
            if accessibilityContrast != mutableTraits.accessibilityContrast {
                mutableTraits.accessibilityContrast = accessibilityContrast
            }
            let horizontalSizeClass = UIUserInterfaceSizeClass(environment.horizontalSizeClass)
            if horizontalSizeClass != mutableTraits.horizontalSizeClass {
                mutableTraits.horizontalSizeClass = horizontalSizeClass
            }
            let verticalSizeClass = UIUserInterfaceSizeClass(environment.verticalSizeClass)
            if verticalSizeClass != mutableTraits.verticalSizeClass {
                mutableTraits.verticalSizeClass = verticalSizeClass
            }
            if !forImageAssetsOnly {
                let userInterfaceLevel = UIUserInterfaceLevel(rawValue: environment.backgroundInfo.layer)!
                if userInterfaceLevel != mutableTraits.userInterfaceLevel {
                    mutableTraits.userInterfaceLevel = userInterfaceLevel
                }
            }
            TypesettingConfigurationKey.write(to: &mutableTraits, value: environment.typesettingConfiguration)
            let activeAppearance = UIUserInterfaceActiveAppearance(rawValue: environment.appearsActive ? 1 : 0)!
            mutableTraits.activeAppearance = activeAppearance
        }
    }

    @inline(__always)
    package var environment: EnvironmentValues {
        if let wrapper = _environmentWrapper,
           let wrapper = wrapper as? EnvironmentWrapper {
            return wrapper.environment
        } else {
            var environment = EnvironmentValues()
            environment.configureForRoot()
            environment.configureForPlatform(traitCollection: self)
            return environment
        }
    }

    func resolvedEnvironment(base environment: EnvironmentValues) -> EnvironmentValues {
        var result = environment
        if !result.bridgedEnvironmentKeys.isEmpty {
            result.bridgedEnvironmentKeys = []
        }
        result.inheritedTraitCollection = _traitCollectionByRemovingEnvironmentWrapper
        if let layoutDirection = LayoutDirection(layoutDirection) {
            result.layoutDirection = layoutDirection
        }
        if let dynamicTypeSize = DynamicTypeSize(uiSizeCategory: preferredContentSizeCategory) {
            result.dynamicTypeSize = dynamicTypeSize
        }
        if let legibilityWeight = LegibilityWeight(legibilityWeight) {
            result.legibilityWeight = legibilityWeight
        }
        if let gamut = DisplayGamut(rawValue: displayGamut.rawValue) {
            result.displayGamut = gamut
        }
        let backlightLuminance = _backlightLuminance
        result.isLuminanceReduced = backlightLuminance == .reduced
        if backlightLuminance == .reduced {
            result.redactionReasons.insert(.privacy)
        }
        #if OPENSWIFTUI_LINK_BACKLIGHTSERVICES
        result.updateFidelity = _updateFidelity
        #endif
        if let colorSchemeContrast = ColorSchemeContrast(accessibilityContrast) {
            result._colorSchemeContrast = colorSchemeContrast
        }
        _openSwiftUIUnimplementedWarning()
        return result
    }

    var viewPhase: ViewPhase {
        if let wrapper = _environmentWrapper,
           let wrapper = wrapper as? EnvironmentWrapper {
            wrapper.phase
        } else {
            .init()
        }
    }
}

@objc(OpenSwiftUIEnvironmentWrapper)
private final class EnvironmentWrapper: NSObject, NSSecureCoding {
    let environment: EnvironmentValues
    let phase: ViewPhase
    let focusedValues: FocusedValues

    init(environment: EnvironmentValues, phase: ViewPhase, focusedValues: FocusedValues) {
        self.environment = environment
        self.phase = phase
        self.focusedValues = focusedValues
        super.init()
    }

    init?(coder: NSCoder) {
        return nil
    }

    func encode(with coder: NSCoder) {}

    override func isEqual(_ object: Any?) -> Bool {
        guard let object,
              let otherWrapper = object as? EnvironmentWrapper else {
            return false
        }
        return phase == otherWrapper.phase &&
                !environment.plist.mayNotBeEqual(to: otherWrapper.environment.plist) &&
                !focusedValues.plist.mayNotBeEqual(to: otherWrapper.focusedValues.plist)
    }

    static var supportsSecureCoding: Bool { true }
}

extension UITraitCollection {
    @_silgen_name("$sSo17UITraitCollectionC5UIKitE16_modifyingTraits18environmentWrapper9mutationsABSo8NSObjectCSg_yAC09UIMutableE0_pzXEtF")
    func _modifyingTraits(
        environmentWrapper: NSObject?,
        mutations: (inout UIMutableTraits) -> ()
    ) -> UITraitCollection
}

extension UIMutableTraits {
    var _vibrancy: _UIUserInterfaceVibrancy {
        @_silgen_name("$s5UIKit15UIMutableTraitsPAAE9_vibrancySo24_UIUserInterfaceVibrancyVvg")
        get
        @_silgen_name("$s5UIKit15UIMutableTraitsPAAE9_vibrancySo24_UIUserInterfaceVibrancyVvs")
        set
    }
}

struct InheritedTraitCollectionKey: EnvironmentKey {
    static var defaultValue: UITraitCollection? { nil }
}

extension EnvironmentValues {
    var inheritedTraitCollection: UITraitCollection? {
        get { self[InheritedTraitCollectionKey.self] }
        set { self[InheritedTraitCollectionKey.self] = newValue }
    }
}

#endif
