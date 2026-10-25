//
//  BarAppearanceBridge.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: WIP
//  ID: 6C1D64F000BEDAC8A453E0E2D82A1069 (SwiftUI)

#if canImport(Darwin)
import Foundation
@_spi(ForOpenSwiftUIOnly)
@_spi(Private)
import OpenSwiftUICore

// MARK: - BarAppearanceBridge [TBA]

class BarAppearanceBridge: NSObject {
    var platformStorage = PlatformStorage()
    var updateContext: UpdateContext?
    // TODO: allowedBars: Set<ToolbarPlacement.Role>.
    var lastEnvironment = EnvironmentValues()
    // TODO: lastBarUpdates: [ToolbarPlacement.Role: PlatformBarUpdates].
    var lastNavigationTitleStorage: NavigationTitleStorage?
    // TODO: lastToolbarInputContent, barBackgroundViewModels, barConfigurations,
    // toUpdateBars, and seedTracker.
    var pendingUpdates: Updates = []

    #if os(macOS)
    // TODO: Obtain the default title from AppWindowsController.WindowInfo.
    var defaultTitle: Text?
    #endif

    func update(environment: inout EnvironmentValues) {
        // TODO: Apply platform toolbar overrides and the primary bar view model.
        lastEnvironment = environment
    }

    func addPreferences(to viewGraph: ViewGraph) {
        viewGraph.addPreference(NavigationTitleKey.self)
        // TODO: Register ToolbarRoleKey and NavigationBarBackButtonHiddenKey.
        #if os(macOS)
        // TODO: Register NavigationSubtitleKey.
        #endif
        // TODO: Track the registered preference seeds. On UIKit, also track
        // ToolbarKey and SearchKey without registering them here.
    }

    @discardableResult
    func preferencesDidChange(
        _ preferences: PreferenceValues,
        updateContext: UpdateContext
    ) -> Updates {
        self.updateContext = updateContext
        defer {
            self.updateContext = nil
            pendingUpdates = []
        }
        // TODO: Gate preference processing on seed changes and set update bit 0x2.
        lastNavigationTitleStorage = preferences[NavigationTitleKey.self].value
        #if os(macOS)
        updateWindowTitle(preferences: preferences)
        #else
        // TODO: updateNavigationBar(updating:preferences:).
        #endif
        updateConfigurations(preferences)
        updateBarsToConfiguration()
        let updates = pendingUpdates
        // TODO: Update the tracked preference seeds.
        #if os(iOS) || os(visionOS)
        if pendingUpdates.rawValue & 0x2 != 0 {
            platformUpdateNavigationAdaptor()
        }
        #endif
        return updates
    }

    func willAppear(animated: Bool, updateContext: UpdateContext) {
        self.updateContext = updateContext
        defer {
            self.updateContext = nil
            pendingUpdates = []
        }
        // TODO: Set each bar configuration's animation and enqueue its role.
        updateBarsToConfiguration()
        #if os(iOS) || os(visionOS)
        if pendingUpdates.rawValue & 0x2 != 0 {
            platformUpdateNavigationAdaptor()
        }
        #endif
    }

    private func updateConfigurations(_ preferences: PreferenceValues) {
        // TODO
    }

    private func updateBarsToConfiguration() {
        // TODO
    }

    struct Updates: OptionSet {
        let rawValue: Int
    }
}
#endif
