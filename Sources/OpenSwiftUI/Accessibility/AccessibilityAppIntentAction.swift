//
//  AccessibilityAppIntentAction.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: FF4B74ECD76D5B0E580D510DA1FEC43C (SwiftUI)

import OpenSwiftUICore

// MARK: - AccessibilityAppIntentAction

struct AccessibilityAppIntentAction: AccessibilityAction, AccessibilityKindActionProvider {
    typealias Value = Void

    let kind: AccessibilityActionKind
    let intent: AppIntentAction

    func impliedRole(for traits: AccessibilityTraitStorage) -> AccessibilityRole? {
        AccessibilityVoidAction(kind: kind).impliedRole(for: traits)
    }

    func asCodableAction(in environment: EnvironmentValues) -> CodableAccessibilityAction? {
        let codableKind: CodableAccessibilityAction.ActionKind
        switch kind.kind {
        case .default: codableKind = .default
        case .escape: codableKind = .escape
        case .magicTap: codableKind = .magicTap
        case .delete: codableKind = .delete
        case .showMenu: codableKind = .showMenu
        case let .custom(text):
            guard let text = AccessibilityText(text, environment: environment, idiom: nil) else { return nil }
            codableKind = .custom(text)
        }
        return CodableAccessibilityAction(kind: codableKind, intent: intent)
    }

    func matches<Other>(_ other: Other) -> Bool where Other: AccessibilityAction {
        if let other = other as? AccessibilityVoidAction {
            return other.kind == kind
        }
        return (other as? Self) == self
    }

    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.kind == rhs.kind && lhs.intent.lnAction == rhs.intent.lnAction
    }
}

// MARK: - AccessibilityAppIntentHandler

struct AccessibilityAppIntentHandler: AccessibilityActionHandler {
    typealias Value = Void

    var action: AccessibilityAppIntentAction
    var category: AccessibilityActionCategory?
    var label: Text?
    var image: Image?
    var supportsEncoding: Bool

    func perform(value: Void) -> AccessibilityActionResult {
        action.intent.perform()
        return .success
    }

    func asCustomAction(category: AccessibilityActionCategory?) -> AnyAccessibilityAction? {
        let kind: AccessibilityActionKind
        if case .custom = action.kind.kind {
            kind = action.kind
        } else if let label {
            kind = AccessibilityActionKind(named: label)
        } else {
            return nil
        }
        return AnyAccessibilityAction(Self(
            action: AccessibilityAppIntentAction(kind: kind, intent: action.intent),
            category: category,
            label: nil,
            image: image,
            supportsEncoding: true
        ), bridged: true)
    }

    func asCombinedAction(name: Text, properties: AccessibilityProperties, child: AccessibilityNode) -> AnyAccessibilityAction? {
        AnyAccessibilityAction(Self(
            action: AccessibilityAppIntentAction(kind: AccessibilityActionKind(named: name), intent: action.intent),
            category: category,
            label: nil,
            image: image ?? properties.images.first,
            supportsEncoding: true
        ), bridged: true)
    }

    func asCodableAction(in environment: EnvironmentValues) -> CodableAccessibilityAction? {
        supportsEncoding ? action.asCodableAction(in: environment) : nil
    }

    func matches<Other>(_ other: Other) -> Bool where Other: AccessibilityAction {
        action.matches(other)
    }
}

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
