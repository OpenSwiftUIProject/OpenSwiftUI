//
//  AppKitViewEnvironment.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: TBA

#if os(macOS)
import AppKit
import COpenSwiftUI
import OpenSwiftUICore

extension NSView {
    func adoptEnvironment(_ environment: EnvironmentValues, hostedSubview: NSView) {
        let appearance = NSAppearance.appearance(from: environment, allowsVibrantBlending: nil)
        if self.appearance != appearance {
            self.appearance = appearance
        }
        let layoutDirection: NSUserInterfaceLayoutDirection = environment.layoutDirection == .rightToLeft
            ? .rightToLeft : .leftToRight
        if userInterfaceLayoutDirection != layoutDirection {
            userInterfaceLayoutDirection = layoutDirection
        }
        if !_userInterfaceLayoutDirectionPropagatesToDescendants() {
            _setUserInterfaceLayoutDirectionPropagates(toDescendants: true)
        }
        // TODO: GroupedFormStyle and sidebar cell semantic context
        _setVibrantBlendingStyle(forSubtree: environment.backgroundMaterial == nil ? 1 : 2)
        if UnifiedHitTestingFeature.isEnabled, !ResponderBasedHitTesting.isEnabled,
           let view = self as? any RecursiveIgnoreHitTestCustomizing,
           view.recursiveIgnoreHitTest == environment.isEnabled {
            view.recursiveIgnoreHitTest = !environment.isEnabled
        }
        if let control = hostedSubview as? NSControl {
            if control.isEnabled != environment.isEnabled {
                control.isEnabled = environment.isEnabled
            }
            let size: NSControl.ControlSize = environment.controlSize == .extraLarge
                ? .large : NSControl.ControlSize(environment.controlSize)
            if control.controlSize != size {
                control.controlSize = size
            }
            // TODO: NSControl.updateFontForControlSize(in:) for clients linked before v2_3
        }
    }
}
#endif
