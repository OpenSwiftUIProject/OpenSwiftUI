//
//  BarAppearanceBridge+AppKit.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: WIP
//  ID: 954D3D19B40AE32D17FE9A5322249E92 (SwiftUI)

#if os(macOS)
import AppKit
@_spi(Private)
import OpenSwiftUICore

// MARK: - BarAppearanceBridge + AppKit [TBA]

extension BarAppearanceBridge {
    struct PlatformStorage {
        var defaultWindowTitleVisibility: Visibility = .automatic
        var windowTitleBarIsTransparentByDefault: Bool = false
    }

    struct UpdateContext {
        var target: NSView
        // TODO: windowInfo: AppWindowsController.WindowInfo?.
        // TODO: customPlacements: [ToolbarPlacement.Role].
    }

    func updateWindowTitle(preferences: PreferenceValues) {
        guard let window = updateContext?.target.window,
              window.contentView === updateContext?.target,
              let title = lastNavigationTitleStorage?.title ?? defaultTitle else {
            return
        }
        let resolvedTitle = title.resolveString(in: lastEnvironment)
        if window.title != resolvedTitle {
            window.title = resolvedTitle
        }
        // TODO: Document titles, subtitles, title visibility, and toolbar labels.
    }
}
#endif
