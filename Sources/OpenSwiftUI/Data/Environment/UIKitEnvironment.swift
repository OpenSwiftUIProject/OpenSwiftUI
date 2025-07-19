//
//  UIKitEnvironment.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: WIP
//  ID: 005A2BB2D44F4D559B7E508DC5B95FFB (SwiftUI)

#if canImport(UIKit)

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
            // TODO
            _openSwiftUIUnimplementedWarning()
        }
    }
}

@objc(SwiftUIEnvironmentWrapper)
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

struct InheritedTraitCollectionKey: EnvironmentKey {
    static var defaultValue: UITraitCollection? { nil }
}

#endif
