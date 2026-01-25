//
//  UIKitMainMenuController.swift
//  OpenSwiftUI

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
}

#endif
