//
//  UIKitHostContainerFocusItemInput.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: WIP
//  ID: 10718FCC504A33B6994038B6E6E29C50 (SwiftUI?)

#if os(iOS) || os(visionOS)
import OpenAttributeGraphShims
@_spi(ForOpenSwiftUIOnly)
import OpenSwiftUICore
import UIKit

// MARK: - UIKitHostContainerFocusItemInput

struct UIKitHostContainerFocusItemInput: ViewInput {
    static let defaultValue: OptionalAttribute<WeakBox<UIView>> = .init()
}
#endif
