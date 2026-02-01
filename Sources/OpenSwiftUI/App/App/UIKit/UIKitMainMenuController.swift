//
//  UIKitMainMenuController.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: WIP
//  ID: B619265B3CBBC7F42E2392FC185432F2 (SwiftUI)

#if os(iOS) || os(visionOS)
import UIKit

// TODO
class UIKitMainMenuController {
    func buildMenu(with: any UIMenuBuilder) {
        _openSwiftUIUnimplementedWarning()
    }

    func validate(_ command: UICommand) {
        _openSwiftUIUnimplementedWarning()
    }

    func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        _openSwiftUIUnimplementedWarning()
        return true
    }

    func _performMainMenuShortcutKeyCommand(_ keyCommand: UIKeyCommand) {
        _openSwiftUIUnimplementedWarning()
    }

    private func documentCommands() -> PlatformItemList {
        _openSwiftUIUnimplementedWarning()
        return PlatformItemList(items: [])
    }

    @inline(__always)
    func updateEnvironment(_ env: inout EnvironmentValues) {
        env.documentCommands = documentCommands()
    }
}
#endif
