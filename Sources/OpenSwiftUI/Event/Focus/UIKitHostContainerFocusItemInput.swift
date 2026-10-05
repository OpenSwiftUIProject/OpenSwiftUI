//
//  UIKitHostContainerFocusItemInput.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: 10718FCC504A33B6994038B6E6E29C50 (SwiftUI?)

#if os(iOS) || os(visionOS)
import COpenSwiftUI
import OpenAttributeGraphShims
@_spi(ForOpenSwiftUIOnly)
import OpenSwiftUICore
import UIKit

// MARK: - AnyUIKitHostedFocusItemResponder

protocol AnyUIKitHostedFocusItemResponder: ViewResponder, BaseFocusResponder {
    var hostedItem: (any AnyUIKitHostedFocusItem)? { get }
}

// MARK: - AnyUIKitHostedFocusItem

protocol AnyUIKitHostedFocusItem: UIFocusItem {
    var host: UIView? { get set }
    var frame: CGRect { get set }
    var responder: (ViewResponder & BaseFocusResponder)? { get }
    func ensureHost()
}

extension AnyUIKitHostedFocusItem {
    func ensureHost() {
        guard host == nil else { return }
        let root = responder?.firstAncestor(ofType: UIViewResponder.self)?.hostView
            ?? responder?.host?.as(UIView.self)
        guard let root else { return }
        var views = [root]
        while !views.isEmpty {
            let view = views.removeFirst()
            if view is any UIKitContainerFocusItem {
                addToHostIfNeeded(view)
                return
            }
            views.append(contentsOf: view.subviews)
        }
    }

    fileprivate func addToHostIfNeeded(_ host: UIView) {
        guard self.host == nil else { return }
        Log.focus?.log("adding unmanaged: \(UIKitFocusItemDescription(self)) to: \(UIKitFocusItemDescription(host))")
        self.host = host
    }

    fileprivate func move(toParent parent: UIView?) {
        guard host !== parent else { return }
        if let host {
            Log.focus?.log("unparenting: \(UIKitFocusItemDescription(self)) from \(UIKitFocusItemDescription(host))")
            UIFocusSystem.focusSystem(for: host)?._focusEnvironmentWillDisappear(self)
        }
        host = parent
        if let host {
            Log.focus?.log("parenting: \(UIKitFocusItemDescription(self)) to: \(UIKitFocusItemDescription(host))")
            UIFocusSystem.focusSystem(for: host)?._focusEnvironmentDidAppear(self)
        }
    }

    fileprivate func invalidateFocusIfNeeded() {
        guard let host, isFocused, !canBecomeFocused else { return }
        Log.focus?.log("invalidating focus in \(UIKitFocusItemDescription(host))")
        host.setNeedsFocusUpdate()
    }
}

// MARK: - UIKitHostedFocusItem

protocol UIKitHostedFocusItem: AnyUIKitHostedFocusItem {
    var id: ViewIdentity { get }
}

// MARK: - UIKitHostedContainerFocusItem

protocol UIKitHostedContainerFocusItem: AnyUIKitHostedFocusItem, UIKitContainerFocusItem {
    var providesDefaultFocusItems: Bool { get }
    func defaultFocusItems() -> [any UIFocusItem]
}

extension UIKitHostedContainerFocusItem {
    func defaultFocusItems() -> [any UIFocusItem] {
        guard let root = rootResponder(), let host else { return [] }
        return FocusBridge.defaultFocusItems(responderNode: root.responder, host: host)
    }
}

// MARK: - UIKitContainerFocusItem

protocol UIKitContainerFocusItem: UIFocusItem, UIFocusItemContainer {
    var host: UIView? { get }
    func rootResponder() -> (responder: ResponderNode, isVisited: Bool)?
    func childFocusItems(in rect: CGRect) -> [any UIFocusItem]
    func defaultFocusItemsContainer() -> (any UIKitHostedContainerFocusItem)?
}

extension UIKitContainerFocusItem {
    func childFocusItems(in rect: CGRect) -> [any UIFocusItem] {
        guard let root = rootResponder(), let host else { return [] }
        return FocusBridge.focusItems(
            responderNode: root.responder,
            rect: rect,
            host: host,
            skipRoot: root.isVisited
        )
    }

    func defaultFocusItemsContainer() -> (any UIKitHostedContainerFocusItem)? {
        guard let root = rootResponder(), let host else { return nil }
        return FocusBridge.defaultFocusItemsContainer(responderNode: root.responder, host: host)
    }
}

extension UIKitContainerFocusItem where Self: AnyUIKitHostedFocusItem {
    func rootResponder() -> (responder: ResponderNode, isVisited: Bool)? {
        responder.map { ($0, true) }
    }
}

extension UIKitContainerFocusItem where Self: UIView {
    func rootResponder() -> (responder: ResponderNode, isVisited: Bool)? {
        guard let renderer = nearestRenderer() else { return nil }
        if renderer === self {
            return renderer.responderNode.map { ($0, false) }
        } else {
            return nearestResponder(in: renderer).map { ($0, true) }
        }
    }
}

extension _UIHostingView: UIKitContainerFocusItem {
    var host: UIView? { self }
}

// MARK: - UIKitHostContainer

protocol UIKitHostContainer {
    var visibleHostCells: [any PlatformListCell & UIFocusItem] { get }
    var hasSelection: Bool { get }
}

// MARK: - UIKitContainerFocusResponderItem

class UIKitContainerFocusResponderItem<A>: UIKitContainerFocusResponderItemBase, UIKitHostedContainerFocusItem where A: ViewResponder, A: BaseFocusResponder {
    weak var base: A?
    weak var host: UIView?
    var frame: CGRect = .zero
    var isEnabled: Bool = true
    private var cachedCoordinateSpace: (any UICoordinateSpace)?

    init(_ base: A) {
        self.base = base
        super.init()
    }

    var providesDefaultFocusItems: Bool { false }

    var responder: (ViewResponder & BaseFocusResponder)? { base }

    var canBecomeFocused: Bool { false }

    var preferredFocusEnvironments: [any UIFocusEnvironment] { [] }

    var parentFocusEnvironment: (any UIFocusEnvironment)? { host }

    var focusItemContainer: (any UIFocusItemContainer)? { self }

    func setNeedsFocusUpdate() {
        UIFocusSystem.focusSystem(for: self)?.requestFocusUpdate(to: self)
    }

    func updateFocusIfNeeded() {
        UIFocusSystem.focusSystem(for: self)?.updateFocusIfNeeded()
    }

    func shouldUpdateFocus(in context: UIFocusUpdateContext) -> Bool { true }

    func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
        _openSwiftUIEmptyStub()
    }

    var coordinateSpace: any UICoordinateSpace {
        if cachedCoordinateSpace == nil {
            cachedCoordinateSpace = WrapperCoordinateSpace(host: host, frame: frame)
        }
        return cachedCoordinateSpace!
    }

    func focusItems(in rect: CGRect) -> [any UIFocusItem] {
        childFocusItems(in: rect)
    }

    @objc
    class func _supportsInvalidatingFocusCache() -> Bool { true }

    @objc(_focusGuideBehaviorForFocusMovement:)
    func _focusGuideBehavior(forFocusMovement movement: AnyObject?) -> UInt { 0 }

    private class WrapperCoordinateSpace: NSObject, UICoordinateSpace {
        weak var host: UIView?
        let frame: CGRect

        init(host: UIView?, frame: CGRect) {
            self.host = host
            self.frame = frame
            super.init()
        }

        // NOTE: The point overloads use the opposite direction
        func convert(_ point: CGPoint, from coordinateSpace: any UICoordinateSpace) -> CGPoint {
            host?.coordinateSpace.convert(point, to: coordinateSpace) ?? .zero
        }

        func convert(_ point: CGPoint, to coordinateSpace: any UICoordinateSpace) -> CGPoint {
            host?.coordinateSpace.convert(point, from: coordinateSpace) ?? .zero
        }

        func convert(_ rect: CGRect, to coordinateSpace: any UICoordinateSpace) -> CGRect {
            host?.coordinateSpace.convert(rect, to: coordinateSpace) ?? .zero
        }

        func convert(_ rect: CGRect, from coordinateSpace: any UICoordinateSpace) -> CGRect {
            host?.coordinateSpace.convert(rect, from: coordinateSpace) ?? .zero
        }

        var bounds: CGRect { frame }
    }
}

// MARK: - UIKitHostContainerCoordinateSpace

let UIKitHostContainerCoordinateSpace: CoordinateSpace.ID = .init()

// MARK: - UIKitHostContainerFocusItemInput

struct UIKitHostContainerFocusItemInput: ViewInput {
    static let defaultValue: OptionalAttribute<WeakBox<UIView>> = .init()
}

// MARK: - UIKitHostedFocusItemLifecycle

struct UIKitHostedFocusItemLifecycle: StatefulRule, ObservedAttribute, RemovableAttribute {
    @Attribute var phase: _GraphInputs.Phase
    @Attribute var transform: ViewTransform
    @Attribute var position: CGPoint
    @Attribute var size: ViewSize
    @OptionalAttribute var host: WeakBox<UIView>?
    @OptionalAttribute var isFocusSystemEnabled: Bool?
    @Attribute var responder: [ViewResponder]
    weak var lastHost: UIView?
    var lastResetSeed: UInt32 = 0
    var isFocusable: Bool?
    var frame: CGRect?
    var hostedItem: (any AnyUIKitHostedFocusItem)?
    var queriedResponder: (any AnyUIKitHostedFocusItemResponder)?
    private var enqueuedEvents: [Event] = []

    typealias Value = Void

    init(inputs: _ViewInputs, responder: Attribute<[ViewResponder]>) {
        _phase = inputs.viewPhase
        _transform = inputs.transform
        _position = inputs.animatedPosition()
        _size = inputs.animatedSize()
        _host = inputs[UIKitHostContainerFocusItemInput.self]
        _isFocusSystemEnabled = .init(inputs.base.isFocusSystemEnabled)
        _responder = responder
    }

    mutating func updateValue() {
        guard isFocusSystemEnabled == true else { return }
        lastHost = host?.base
        if lastResetSeed != phase.resetSeed {
            lastResetSeed = phase.resetSeed
            remove()
            hostedItem = nil
            frame = nil
            isFocusable = nil
        }
        if let first = responder.first, first !== queriedResponder {
            queriedResponder = first as? any AnyUIKitHostedFocusItemResponder
        }
        guard let item = queriedResponder?.hostedItem else {
            flushQueue()
            return
        }
        var transform = transform
        transform.appendPosition(position)
        var frame = CGRect(origin: .zero, size: size.value)
        frame.convert(to: .id(UIKitHostContainerCoordinateSpace), transform: transform)
        let isFocusable = item.canBecomeFocused
        if hostedItem == nil {
            hostedItem = item
            self.frame = frame
            self.isFocusable = isFocusable
            insert()
        } else {
            if self.frame != frame {
                self.frame = frame
                invalidateFrame()
            }
            if self.isFocusable != isFocusable {
                self.isFocusable = isFocusable
                invalidateFocusIfNeeded()
            }
        }
        flushQueue()
    }

    static func willRemove(attribute: AnyAttribute) {
        let body = UnsafeMutableRawPointer(mutating: attribute.info.body)
            .assumingMemoryBound(to: Self.self)
        body.pointee.remove()
    }

    static func didReinsert(attribute: AnyAttribute) {
        let body = UnsafeMutableRawPointer(mutating: attribute.info.body)
            .assumingMemoryBound(to: Self.self)
        if body.pointee.insert() {
            attribute.invalidateValue()
        }
    }

    mutating func destroy() {
        remove()
        flushQueue()
    }

    mutating func flushQueue() {
        let events = enqueuedEvents
        enqueuedEvents = []
        Update.enqueueAction {
            for event in events {
                event.action()
            }
        }
    }

    private mutating func remove() {
        guard let hostedItem else { return }
        if enqueuedEvents.first?.type == .inserted {
            enqueuedEvents = []
        } else {
            enqueuedEvents = [Event(type: .removed) {
                hostedItem.move(toParent: nil)
            }]
        }
    }

    @discardableResult
    private mutating func insert() -> Bool {
        guard let lastHost, let hostedItem, let frame else { return false }
        enqueuedEvents.append(Event(type: .inserted) {
            hostedItem.frame = frame
            hostedItem.move(toParent: lastHost)
        })
        return true
    }

    private mutating func invalidateFrame() {
        guard let hostedItem, let frame else { return }
        enqueuedEvents.append(Event(type: .updated) {
            hostedItem.frame = frame
            if hostedItem.isFocused,
               let component = hostedItem.host?.window?.windowScene?._focusSystemSceneComponent,
               component.responds(to: #selector(NSObject._requestFocusEffectUpdate(to:))) {
                component._requestFocusEffectUpdate(to: hostedItem)
            }
        })
    }

    private mutating func invalidateFocusIfNeeded() {
        guard let hostedItem else { return }
        enqueuedEvents.append(Event(type: .updated) {
            hostedItem.invalidateFocusIfNeeded()
        })
    }

    private struct Event {
        var type: EventType
        var action: () -> Void
    }

    private enum EventType: Hashable {
        case updated
        case inserted
        case removed
    }
}

// MARK: - FocusBridge + UIKit containers

extension FocusBridge {
    fileprivate static func focusItems(
        responderNode: ResponderNode,
        rect: CGRect,
        host: UIView,
        skipRoot: Bool
    ) -> [any UIFocusItem] {
        var items: [any UIFocusItem] = []
        responderNode.visitBaseFocusResponders { responder in
            if skipRoot, responder === responderNode {
                return .next
            }
            if _SemanticFeature_v6.isEnabled, !responder.isEnabled {
                return .skipToNextSibling
            }
            guard let item = responder.platformItem else { return .next }
            let frame: CGRect?
            if let view = item as? UIView {
                frame = view.convert(view.bounds, to: host as any UICoordinateSpace)
            } else if let hostedItem = item as? any AnyUIKitHostedFocusItem {
                hostedItem.addToHostIfNeeded(host)
                frame = hostedItem.frame
            } else {
                Log.focus?.error("unknown focus item: \(UIKitFocusItemDescription(item))")
                frame = nil
            }
            if let frame, !frame.intersection(rect).isEmpty {
                items.append(item)
            } else {
                Log.focus?.log("skipped: \(UIKitFocusItemDescription(item)) with: \((frame ?? .zero).loggable) in: \(rect.loggable) for: \(UIKitFocusItemDescription(host))")
            }
            return .skipToNextSibling
        }
        Log.focus?.log("focus items queried: \(items.count) in: \(rect.loggable) for: \(UIKitFocusItemDescription(host))")
        return items
    }

    fileprivate static func defaultFocusItems(responderNode: ResponderNode, host: UIView) -> [any UIFocusItem] {
        var items: [any UIFocusItem] = []
        responderNode.visitBaseFocusResponders { responder in
            if _SemanticFeature_v6.isEnabled, !responder.isEnabled {
                return .skipToNextSibling
            }
            guard let item = responder.platformItem else { return .next }
            if let container = item as? any UIKitHostedContainerFocusItem,
               !container.providesDefaultFocusItems {
                return .next
            }
            (item as? any AnyUIKitHostedFocusItem)?.addToHostIfNeeded(host)
            items.append(item)
            return .skipToNextSibling
        }
        return items
    }

    fileprivate static func defaultFocusItemsContainer(
        responderNode: ResponderNode,
        host: UIView
    ) -> (any UIKitHostedContainerFocusItem)? {
        var result: (any UIKitHostedContainerFocusItem)?
        responderNode.visitBaseFocusResponders { responder in
            if _SemanticFeature_v6.isEnabled, !responder.isEnabled {
                return .skipToNextSibling
            }
            guard let item = responder.platformItem as? any UIKitHostedContainerFocusItem else {
                result = nil
                return .cancel
            }
            guard item.providesDefaultFocusItems else { return .next }
            guard result == nil else {
                result = nil
                return .cancel
            }
            item.addToHostIfNeeded(host)
            result = item
            return .skipToNextSibling
        }
        return result
    }
}

// MARK: - UIFocusEnvironment + responders

extension UIFocusEnvironment {
    fileprivate func nearestRenderer() -> (any ViewRendererHost)? {
        var environment: (any UIFocusEnvironment)? = self
        while let current = environment {
            if let renderer = current as? any ViewRendererHost {
                return renderer
            }
            environment = current.parentFocusEnvironment
        }
        return nil
    }

    fileprivate func nearestResponder(in renderer: any ViewRendererHost) -> ResponderNode? {
        _ = renderer.responderNode
        if let item = self as? any AnyUIKitHostedFocusItem,
           nearestRenderer() === renderer {
            return item.responder
        }
        var environment: (any UIFocusEnvironment)? = self
        while let current = environment {
            if let host = current as? any AnyPlatformViewHost,
               let responder = host.responder,
               responder.host === renderer {
                return responder
            }
            environment = current.parentFocusEnvironment
        }
        return nil
    }
}

// MARK: - UIKitFocusItemDescription

struct UIKitFocusItemDescription<Item>: CustomStringConvertible where Item: UIFocusItem {
    var description: String

    init(_ item: Item) {
        let category = Category(item)
        description = "<\(category.name): \(address(of: item))"
        for attribute in category.attributes {
            description += "; " + attribute
        }
        description += ">"
    }

    enum Category {
        case host(UIView & UIKitContainerFocusItem)
        case container(any UIKitHostedContainerFocusItem)
        case item(any AnyUIKitHostedFocusItem)
        case unknown(Item)

        init(_ item: Item) {
            if let host = item as? UIView & UIKitContainerFocusItem {
                self = .host(host)
            } else if let container = item as? any UIKitHostedContainerFocusItem {
                self = .container(container)
            } else if let item = item as? any AnyUIKitHostedFocusItem {
                self = .item(item)
            } else {
                self = .unknown(item)
            }
        }

        var name: String {
            switch self {
            case .host: "Host"
            case .container: "Container"
            case .item: "Item"
            case let .unknown(item): "Unknown<\(_typeName(type(of: item), qualified: false))>"
            }
        }

        var attributes: [String] {
            switch self {
            case .host:
                []
            case .container:
                ["responder: \(addressOfResponder ?? "??")"]
            case let .item(item):
                ["responder: \(addressOfResponder ?? "??")", "focused: \(item.isFocused)"]
            case let .unknown(item):
                ["focused: \(item.isFocused)"]
            }
        }

        private var addressOfResponder: String? {
            let responder: ViewResponder?
            switch self {
            case let .container(item): responder = item.responder
            case let .item(item): responder = item.responder
            case .host, .unknown: return nil
            }
            return responder.map { "\(address(of: $0))" }
        }
    }
}
#endif
