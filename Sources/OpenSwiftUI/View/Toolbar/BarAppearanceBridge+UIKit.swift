//
//  BarAppearanceBridge+UIKit.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: WIP
//  ID: BF747AB022DCE7FC5B6AD0F035BC8E0D (SwiftUI)

#if os(iOS) || os(visionOS)
import UIKit

// MARK: - BarAppearanceBridge + UIKit [TBA]

extension BarAppearanceBridge {
    struct PlatformStorage {
        var uiShouldUpdateNavigationController: Bool = true
        var uiIsHidingBackButton: Bool = false
        var uiHasNavigationContent: Bool?
        var uiHasBottomBarContent: Bool?
        weak var uiTargetController: UIViewController?
        var uiShouldUpdateNavigationTitle: Bool = true
    }

    struct UpdateContext {
        var targetController: UIViewController
        var containingController: UINavigationController?
        // TODO: overrides: HostingControllerOverrides.
        // TODO: navigationAdaptor: UINavigationItemAdaptorStorage.
        // TODO: customPlacements: [ToolbarPlacement.Role].
        // TODO: init(hostingController:) and the hosting-controller entry points.
    }

    func platformUpdateNavigationAdaptor() {
        // TODO: Forward the pending update to the context's navigation adaptor.
    }
}
#endif
