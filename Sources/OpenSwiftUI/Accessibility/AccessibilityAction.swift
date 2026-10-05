//
//  AccessibilityAction.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: E60060FB22010C6B882B053FD088F4E3 (SwiftUI)

import Foundation
import OpenSwiftUICore
#if os(iOS) || os(visionOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

// MARK: - AccessibilityAction

protocol AccessibilityAction: Equatable {
    associatedtype Value

    func impliedRole(for traits: AccessibilityTraitStorage) -> AccessibilityRole?

    func matches<Other>(_ other: Other) -> Bool where Other: AccessibilityAction
}

extension AccessibilityAction {
    func matches<Other>(_ other: Other) -> Bool where Other: AccessibilityAction {
        (other as? Self) == self
    }
}

// MARK: - AccessibilityActionResult

@_spi(Private)
@available(OpenSwiftUI_v5_0, *)
public enum AccessibilityActionResult: Sendable {
    case failure(Bool)
    case success
    case passive
}

@_spi(Private)
@available(OpenSwiftUI_v5_0, *)
extension AccessibilityActionResult: ExpressibleByBooleanLiteral {
    public init(booleanLiteral value: Bool) {
        self = value ? .success : .failure(true)
    }
}

// MARK: - AccessibilityKindActionProvider

protocol AccessibilityKindActionProvider {
    var kind: AccessibilityActionKind { get }
}

// MARK: - AccessibilityActionHandler

protocol AccessibilityActionHandler: AccessibilityAction {
    associatedtype Action: AccessibilityAction

    var action: Action { get }

    var category: AccessibilityActionCategory? { get }

    var label: Text? { get }

    var image: Image? { get }

    func perform(value: Value) -> AccessibilityActionResult

    func asCustomAction(category: AccessibilityActionCategory?) -> AnyAccessibilityAction?

    func asCombinedAction(
        name: Text,
        properties: AccessibilityProperties,
        child: AccessibilityNode
    ) -> AnyAccessibilityAction?

    func asCodableAction(in environment: EnvironmentValues) -> CodableAccessibilityAction?
}

extension AccessibilityActionHandler {
    func impliedRole(for traits: AccessibilityTraitStorage) -> AccessibilityRole? {
        action.impliedRole(for: traits)
    }

    var name: Text? {
        guard let provider = action as? AccessibilityKindActionProvider else {
            return label
        }
        guard case let .custom(text) = provider.kind.kind else {
            return nil
        }
        return label ?? text
    }

    func asCodableAction(in environment: EnvironmentValues) -> CodableAccessibilityAction? {
        nil
    }

    func asCombinedAction(
        name: Text,
        properties: AccessibilityProperties,
        child: AccessibilityNode
    ) -> AnyAccessibilityAction? {
        nil
    }
}

// MARK: - AbstractAnyAccessibilityAction

private protocol AbstractAnyAccessibilityAction {
    var name: Text? { get }
    var image: Image? { get }
    var category: AccessibilityActionCategory? { get }
    func perform(value: Any) -> AccessibilityActionResult
    func perform<A>(action: A, value: A.Value) -> AccessibilityActionResult where A: AccessibilityAction
    func impliedRole(for traits: AccessibilityTraitStorage) -> AccessibilityRole?
    func asReference(for node: AccessibilityNode) -> AnyAccessibilityAction
    func asCustomAction(category: AccessibilityActionCategory?) -> AnyAccessibilityAction?
    func asCombinedAction(
        name: Text,
        properties: AccessibilityProperties,
        child: AccessibilityNode
    ) -> AnyAccessibilityAction?
    func matches<A>(_ action: A) -> Bool where A: AccessibilityAction
    func isEqual(to other: any AbstractAnyAccessibilityAction) -> Bool
    func asCodableAction(in environment: EnvironmentValues) -> CodableAccessibilityAction?
}

// MARK: - AnyAccessibilityAction

struct AnyAccessibilityAction {
    private struct ConcreteBase<Base>: AbstractAnyAccessibilityAction, Equatable where Base: AccessibilityActionHandler {
        var base: Base

        var name: Text? {
            base.name
        }

        var image: Image? {
            base.image
        }

        var category: AccessibilityActionCategory? {
            base.category
        }

        func perform(value: Any) -> AccessibilityActionResult {
            guard let value = value as? Base.Value else {
                return false
            }
            return base.perform(value: value)
        }

        func perform<A>(action: A, value: A.Value) -> AccessibilityActionResult where A: AccessibilityAction {
            guard matches(action), let value = value as? Base.Value else {
                return false
            }
            return base.perform(value: value)
        }

        func matches<A>(_ action: A) -> Bool where A: AccessibilityAction {
            base.action.matches(action)
        }

        func impliedRole(for traits: AccessibilityTraitStorage) -> AccessibilityRole? {
            base.impliedRole(for: traits)
        }

        func asReference(for node: AccessibilityNode) -> AnyAccessibilityAction {
            AnyAccessibilityAction(AccessibilityActionReference(base, node), bridged: false)
        }

        func asCustomAction(category: AccessibilityActionCategory?) -> AnyAccessibilityAction? {
            base.asCustomAction(category: category)
        }

        func asCombinedAction(
            name: Text,
            properties: AccessibilityProperties,
            child: AccessibilityNode
        ) -> AnyAccessibilityAction? {
            base.asCombinedAction(name: name, properties: properties, child: child)
        }

        func asCodableAction(in environment: EnvironmentValues) -> CodableAccessibilityAction? {
            base.asCodableAction(in: environment)
        }

        func isEqual(to other: any AbstractAnyAccessibilityAction) -> Bool {
            (other as? Self)?.base == base
        }

        static func == (lhs: ConcreteBase, rhs: ConcreteBase) -> Bool {
            lhs.base == rhs.base
        }
    }

    private var base: any AbstractAnyAccessibilityAction

    let bridged: Bool

    init<H>(_ handler: H, bridged: Bool) where H: AccessibilityActionHandler {
        base = ConcreteBase(base: handler)
        self.bridged = bridged
    }

    init<A>(
        action: A,
        label: Text?,
        image: Image?,
        handler: @escaping (A.Value) -> AccessibilityActionResult,
        bridged: Bool
    ) where A: AccessibilityAction {
        self.init(
            AccessibilityActionStorage(
                action: action,
                category: nil,
                label: label,
                image: image,
                handler: handler
            ),
            bridged: bridged
        )
    }

    func matches<A>(_ action: A) -> Bool where A: AccessibilityAction {
        base.matches(action)
    }

    func perform<A>(action: A, value: A.Value) -> AccessibilityActionResult where A: AccessibilityAction {
        base.perform(action: action, value: value)
    }

    func asCombinedAction(
        name: Text,
        properties: AccessibilityProperties,
        child: AccessibilityNode
    ) -> AnyAccessibilityAction? {
        if let action = base.asCombinedAction(name: name, properties: properties, child: child) {
            return action
        }
        return AnyAccessibilityAction(
            action: AccessibilityVoidAction(kind: AccessibilityActionKind(named: name)),
            label: nil,
            image: base.image ?? properties.images.first,
            handler: {
                if bridged {
                    return base.perform(value: ())
                } else {
                    return AccessibilityActionResult(
                        booleanLiteral: child.sendAction(AccessibilityVoidAction(kind: .default), value: ())
                    )
                }
            },
            bridged: bridged
        )
    }

    struct Resolved {
        var name: NSAttributedString
        var category: String?
        var image: PlatformImage?
    }
}

extension AnyAccessibilityAction: AbstractAnyAccessibilityAction {
    var name: Text? {
        base.name
    }

    var image: Image? {
        base.image
    }

    var category: AccessibilityActionCategory? {
        base.category
    }

    func perform(value: Any) -> AccessibilityActionResult {
        base.perform(value: value)
    }

    func impliedRole(for traits: AccessibilityTraitStorage) -> AccessibilityRole? {
        base.impliedRole(for: traits)
    }

    func asReference(for node: AccessibilityNode) -> AnyAccessibilityAction {
        base.asReference(for: node)
    }

    func asCustomAction(category: AccessibilityActionCategory?) -> AnyAccessibilityAction? {
        base.asCustomAction(category: category)
    }

    fileprivate func isEqual(to other: any AbstractAnyAccessibilityAction) -> Bool {
        (other as? AnyAccessibilityAction) == self
    }

    func asCodableAction(in environment: EnvironmentValues) -> CodableAccessibilityAction? {
        base.asCodableAction(in: environment)
    }
}

extension AnyAccessibilityAction: Equatable {
    static func == (lhs: AnyAccessibilityAction, rhs: AnyAccessibilityAction) -> Bool {
        lhs.base.isEqual(to: rhs.base)
    }
}

// MARK: - AccessibilityActionReference

struct AccessibilityActionReference<A>: AccessibilityActionHandler where A: AccessibilityAction {
    typealias Value = A.Value

    let action: A

    let category: AccessibilityActionCategory?

    let label: Text?

    let imageStorage: Image?

    weak var node: AccessibilityNode?

    init<H>(_ handler: H, _ node: AccessibilityNode) where H: AccessibilityActionHandler, H.Action == A {
        action = handler.action
        category = handler.category
        label = handler.label
        imageStorage = handler.image
        self.node = node
    }

    var image: Image? {
        if let imageStorage {
            return imageStorage
        }
        guard let node else {
            return nil
        }
        return node.properties.images.first
    }

    func perform(value: A.Value) -> AccessibilityActionResult {
        guard let node else {
            return false
        }
        return AccessibilityActionResult(booleanLiteral: node.sendAction(action, value: value))
    }

    func asCustomAction(category: AccessibilityActionCategory?) -> AnyAccessibilityAction? {
        nil
    }

    static func == (lhs: AccessibilityActionReference, rhs: AccessibilityActionReference) -> Bool {
        lhs.action == rhs.action
            && lhs.category == rhs.category
            && lhs.label == rhs.label
            && lhs.imageStorage == rhs.imageStorage
            && lhs.node == rhs.node
    }
}

// MARK: - AccessibilityActionStorage

private var AccessibilityActionHandlerSeed: UInt32 = 0

struct AccessibilityActionStorage<A>: AccessibilityActionHandler where A: AccessibilityAction {
    typealias Value = A.Value

    let action: A

    let category: AccessibilityActionCategory?

    let label: Text?

    let image: Image?

    let handler: (A.Value) -> AccessibilityActionResult

    var seed: UInt32

    init(
        action: A,
        category: AccessibilityActionCategory?,
        label: Text?,
        image: Image?,
        handler: @escaping (A.Value) -> AccessibilityActionResult
    ) {
        self.action = action
        self.category = category
        self.label = label
        self.image = image
        self.handler = handler
        seed = AccessibilityActionHandlerSeed
        AccessibilityActionHandlerSeed.unsafeIncrement()
    }

    func perform(value: A.Value) -> AccessibilityActionResult {
        Update.dispatchImmediately(reason: nil) {
            handler(value)
        }
    }

    func asCustomAction(category: AccessibilityActionCategory?) -> AnyAccessibilityAction? {
        guard let storage = self as? AccessibilityActionStorage<AccessibilityVoidAction> else {
            return nil
        }
        let name: Text
        if case let .custom(text) = storage.action.kind.kind {
            name = text
        } else if let label {
            name = label
        } else {
            return nil
        }
        return AnyAccessibilityAction(
            AccessibilityActionStorage<AccessibilityVoidAction>(
                action: AccessibilityVoidAction(kind: AccessibilityActionKind(named: name)),
                category: category,
                label: nil,
                image: image,
                handler: storage.handler
            ),
            bridged: false
        )
    }

    static func == (lhs: AccessibilityActionStorage, rhs: AccessibilityActionStorage) -> Bool {
        lhs.seed == rhs.seed
            && lhs.action == rhs.action
            && lhs.category == rhs.category
            && lhs.label == rhs.label
            && lhs.image == rhs.image
    }
}
