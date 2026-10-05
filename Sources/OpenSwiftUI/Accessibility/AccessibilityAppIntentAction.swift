//
//  AccessibilityAppIntentAction.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: FF4B74ECD76D5B0E580D510DA1FEC43C (SwiftUI)

import OpenSwiftUICore

// MARK: - CodableAccessibilityAction

struct CodableAccessibilityAction: Codable {
    enum ActionKind: Codable {
        case `default`
        case escape
        case magicTap
        case delete
        case showMenu
        case custom(AccessibilityText)
    }

    let kind: ActionKind
    let intent: AppIntentAction
}

// MARK: - CodableAccessibilityActionList

struct CodableAccessibilityActionList: DynamicProperty, Codable {
    @Environment(\.appIntentExecutor) var appIntentExecutor
    var storage: [CodableAccessibilityAction]

    enum CodingKeys: String, CodingKey {
        case storage
    }

    var actions: [AnyAccessibilityAction] {
        storage.map { AnyAccessibilityAction($0, appIntentExecutor: appIntentExecutor) }
    }
}

// MARK: - AnyAccessibilityAction + CodableAccessibilityAction

extension AnyAccessibilityAction {
    init(_ action: CodableAccessibilityAction, appIntentExecutor: AppIntentExecutor?) {
        let kind: AccessibilityActionKind.ActionKind
        switch action.kind {
        case .default: kind = .default
        case .escape: kind = .escape
        case .magicTap: kind = .magicTap
        case .delete: kind = .delete
        case .showMenu: kind = .showMenu
        case let .custom(text): kind = .custom(text.text)
        }
        self.init(
            action: AccessibilityVoidAction(kind: AccessibilityActionKind(kind: kind)),
            label: nil,
            image: nil,
            handler: { _ in
                MainActor.assumeIsolatedIfLinkedOnOrAfter(.v7) {
                    if let appIntentExecutor {
                        appIntentExecutor.perform(action.intent.lnAction)
                    } else {
                        action.intent.defaultExecutor()
                    }
                    return .success
                }
            },
            bridged: false
        )
    }
}
