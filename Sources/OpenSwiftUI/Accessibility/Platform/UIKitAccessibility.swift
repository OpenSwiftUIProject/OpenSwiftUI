//
//  UIKitAccessibility.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: WIP (TBA)
//  ID: 1C25C4B203EEAC6A19839AC5BDB6A345 (SwiftUI)

#if os(iOS) || os(visionOS)
import COpenSwiftUI
@_spi(ForOpenSwiftUIOnly)
import OpenSwiftUICore
import OpenSwiftUI_SPI
import libAccessibilityPrivate
import UIKit

// MARK: - UILargeContentViewerInteractionBridge [WIP]

class UILargeContentViewerInteractionBridge: NSObject, UILargeContentViewerInteractionDelegate, UIGestureRecognizerDelegate {
    weak var host: (UIView & ViewRendererHost)?
    private var interaction: UILargeContentViewerInteraction?
    private weak var gesture: UIGestureRecognizer?
    private var simultaneousGesture: UIGestureRecognizer?
    private var activeItem: ActiveItem?
    private var largeContentViewTreeSeed: VersionSeed = .empty
    private var largeContentViewTree: AccessibilityLargeContentViewTree = .empty
    private var showLargeContentViewer: Bool

    override init() {
        showLargeContentViewer = UILargeContentViewerInteraction.isEnabled
        super.init()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(enabledStatusDidChange),
            name: UILargeContentViewerInteraction.enabledStatusDidChangeNotification,
            object: nil
        )
    }

    func updateRequestedPreferences(for graph: ViewGraph) {
        Update.ensure {
            if showLargeContentViewer {
                graph.addPreference(AccessibilityLargeContentViewTree.Key.self)
            } else {
                graph.removePreference(AccessibilityLargeContentViewTree.Key.self)
            }
        }
    }

    func preferencesDidChange(_ preferences: PreferenceValues) {
        let value = preferences[AccessibilityLargeContentViewTree.Key.self]
        guard !value.seed.matches(largeContentViewTreeSeed) else {
            return
        }
        largeContentViewTree = value.value
        if let interaction {
            if !largeContentViewTree.hasValue {
                host!.removeInteraction(interaction)
                self.interaction = nil
                gesture = nil
            }
        } else if largeContentViewTree.hasValue {
            let interaction = UILargeContentViewerInteraction(delegate: self)
            host!.addInteraction(interaction)
            self.interaction = interaction
            let gesture = interaction.gestureRecognizerForExclusionRelationship
            gesture.delegate = self
            gesture.delaysTouchesEnded = false
            gesture.cancelsTouchesInView = false
            self.gesture = gesture
        }
        largeContentViewTreeSeed = value.seed
    }

    @objc private func enabledStatusDidChange() {
        let wasEnabled = showLargeContentViewer
        showLargeContentViewer = UILargeContentViewerInteraction.isEnabled
        guard wasEnabled != showLargeContentViewer, let host else {
            return
        }
        updateRequestedPreferences(for: host.viewGraph)
    }

    func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
    ) -> Bool {
        if gesture == gestureRecognizer, otherGestureRecognizer is UIKitGestureRecognizer {
            simultaneousGesture = otherGestureRecognizer
            return true
        }
        guard gesture == gestureRecognizer,
              type(of: gestureRecognizer) == type(of: otherGestureRecognizer),
              let view = gestureRecognizer.view,
              let otherView = otherGestureRecognizer.view else {
            return false
        }
        return otherView.isDescendant(of: view)
    }

    func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer
    ) -> Bool {
        gesture == gestureRecognizer && otherGestureRecognizer is UIKitGestureRecognizer
    }

    func largeContentViewerInteraction(
        _ interaction: UILargeContentViewerInteraction,
        itemAt point: CGPoint
    ) -> (any UILargeContentViewerItem)? {
        if let activeItem, activeItem.frame.contains(host!.convert(point, to: nil)) {
            return activeItem.item
        }
        guard let item = hitTest(at: point) else {
            return nil
        }
        if activeItem != nil {
            simultaneousGesture?.reset()
        }
        activeItem = item
        return item.item
    }

    func largeContentViewerInteraction(
        _ interaction: UILargeContentViewerInteraction,
        didEndOn item: (any UILargeContentViewerItem)?,
        at point: CGPoint
    ) {
        activeItem = nil
        simultaneousGesture = nil
        guard item != nil, host != nil else {
            return
        }
        // TODO: Forward the action for UIKitBarItemHost<BarItemView>.
        _openSwiftUIUnimplementedFailure()
    }

    private func hitTest(at point: CGPoint) -> ActiveItem? {
        if let view = host!._largeContentViewerItem(at: point) as? UIView {
            return ActiveItem(item: view, frame: host!.convert(view.bounds, from: view as any UICoordinateSpace))
        }
        let globalPoint = host!.convert(point, to: nil)
        guard let item = largeContentViewTree.hitTest(at: globalPoint) else {
            return nil
        }
        return ActiveItem(item: UILargeContentViewerItemBridge(item), frame: item.frame)
    }

    private struct ActiveItem {
        var item: any UILargeContentViewerItem
        var frame: CGRect
    }
}

// MARK: - UILargeContentViewerItemBridge [WIP]

private class UILargeContentViewerItemBridge: NSObject, UILargeContentViewerItem {
    let largeContentTitle: String?
    let largeContentImage: UIImage?

    init(_ item: AccessibilityLargeContentViewItem) {
        largeContentTitle = item.title
        if let image = item.image?.basePlatformItemImage {
            largeContentImage = (image as! UIImage)
        } else if item.image != nil {
            // TODO: Use GraphicsImage.makePlatformImage with a fixed symbol configuration.
            _openSwiftUIUnimplementedFailure()
        } else {
            largeContentImage = nil
        }
        super.init()
    }

    var showsLargeContentViewer: Bool { true }

    var scalesLargeContentImage: Bool { true }

    var largeContentImageInsets: UIEdgeInsets { .zero }
}

// MARK: - UIKitAccessibilityLinkRotorBridge

class UIKitAccessibilityLinkRotorBridge: UIAccessibilityCustomRotor, AccessibilityLinkRotorBridge {
    weak var node: AccessibilityNode?
    var paragraphHash: Int = 0
    var elements: [any AccessibilityLinkElement] = []

    init(for node: AccessibilityNode) {
        self.node = node
        super.init(systemType: .link) { [weak node] predicate in
            guard let rotor = node?.currentLinkRotor,
                  let parameters = predicate.linkRotorSearchParameters else {
                return nil
            }
            rotor.update()
            guard let element = rotor.search(parameters: parameters) as? LinkElement else {
                return nil
            }
            return UIAccessibilityCustomRotorItemResult(targetElement: element, targetRange: nil)
        }
    }

    static func linkElement(for node: AccessibilityNode, range: NSRange) -> any AccessibilityLinkElement {
        LinkElement(node: node, range: range)
    }

    private class LinkElement: UIAccessibilityElement, AccessibilityLinkElement {
        weak var node: AccessibilityNode?
        var range: NSRange

        init(node: AccessibilityNode, range: NSRange) {
            self.node = node
            self.range = range
            super.init(accessibilityContainer: node)
        }

        override var accessibilityFrame: CGRect {
            get { node?._accessibilityBounds(for: range) ?? .zero }
            set { _openSwiftUIEmptyStub() }
        }

        override var accessibilityTraits: UIAccessibilityTraits {
            get { .link }
            set { _openSwiftUIEmptyStub() }
        }

        override var accessibilityLabel: String? {
            get { (node?.accessibilityLabel as NSString?)?.substring(with: range) }
            set { _openSwiftUIEmptyStub() }
        }

        override var accessibilityActivationPoint: CGPoint {
            get {
                guard let node else {
                    return .zero
                }
                let frame = node._accessibilityBounds(for: NSRange(location: range.location, length: 1))
                return CGPoint(x: frame.origin.x + frame.width / 2, y: frame.origin.y + frame.height / 2)
            }
            set { _openSwiftUIEmptyStub() }
        }
    }
}

// MARK: - AccessibilityProperties.UIKitBridgedInteractionKey

extension AccessibilityProperties {
    struct UIKitBridgedInteractionKey: AccessibilityOptionalPropertiesKey {
        static let valueType = (NSObject & UIInteraction).self
    }

    var uiKitBridgedInteraction: (NSObject & UIInteraction)? {
        get { self[UIKitBridgedInteractionKey.self] }
        set { self[UIKitBridgedInteractionKey.self] = newValue }
    }
}

// MARK: - AccessibilityUIKitTraits

struct AccessibilityUIKitTraits: Equatable {
    var removed: UIAccessibilityTraits
    var added: UIAccessibilityTraits
}

extension AccessibilityUIKitTraits: AccessibilityCombinable {
    @discardableResult
    mutating func merge(with child: AccessibilityUIKitTraits) -> Bool {
        let newAdded = added.union(child.added).subtracting(removed)
        let newRemoved = removed.union(child.removed).subtracting(newAdded)
        let changed = added != newAdded || removed != newRemoved
        added = newAdded
        removed = newRemoved
        return changed
    }
}

// MARK: - AccessibilityProperties.UIKitTraitsKey

extension AccessibilityProperties {
    struct UIKitTraitsKey: AccessibilityOptionalPropertiesKey {
        static let valueType = AccessibilityUIKitTraits.self
    }

    var uiKitTraits: AccessibilityUIKitTraits? {
        get { self[UIKitTraitsKey.self] }
        set { self[UIKitTraitsKey.self] = newValue }
    }

}

// MARK: - UIKitAccessibilityPropertyApplicator

struct UIKitAccessibilityPropertyApplicator: AccessibilityPlatformPropertyApplicator {
    static func apply(_ storage: AccessibilityPlatformPropertyStorage, to properties: inout AccessibilityProperties) {
        properties.uiKitTraits = storage.explicitTraits.map {
            AccessibilityUIKitTraits(
                removed: UIAccessibilityTraits(rawValue: $0.removed),
                added: UIAccessibilityTraits(rawValue: $0.added)
            )
        }
    }
}

// MARK: - AccessibilityCoreNotification

protocol AccessibilityCoreNotification {
    static var name: UIAccessibility.Notification { get }
    var info: AccessibilityCore.Notification.Info { get }
}

extension AccessibilityCoreNotification {
    func post() {
        let info = info
        UIAccessibility.post(notification: Self.name, argument: info.argument)
    }
}

// MARK: - AccessibilityCore.Notification

extension AccessibilityCore {
    enum Notification {
        struct Info {
            var argument: Any?
        }

        struct ScreenChanged: AccessibilityCoreNotification {
            var nextElement: PlatformAccessibilityElement?
            var updateImmediately: Bool

            static var name: UIAccessibility.Notification { .screenChanged }

            var info: Info {
                guard let nextElement, updateImmediately else {
                    return Info(argument: nextElement)
                }
                let argument: [String: Any] = [
                    AXOpenSwiftUIPerformElementUpdateImmediatelyToken(): true,
                    AXOpenSwiftUIMoveToElementNotificationKeyElement(): nextElement,
                ]
                return Info(argument: argument)
            }
        }

        struct LayoutChanged: AccessibilityCoreNotification {
            var nextElement: PlatformAccessibilityElement?

            static var name: UIAccessibility.Notification { .layoutChanged }

            var info: Info {
                Info(argument: nextElement)
            }
        }
    }
}

// MARK: - AccessibilityRole.Resolved

extension AccessibilityRole {
    struct Resolved {
        var traits: AXOpenSwiftUITraits
        var automationType: AXAutomationType?
    }
}

// MARK: - UIAccessibilityCustomRotorSearchPredicate

private extension UIAccessibilityCustomRotorSearchPredicate {
    var linkRotorSearchParameters: AccessibilityLinkRotorSearchParameters? {
        let element = currentItem.targetElement as? any AccessibilityLinkElement
        switch searchDirection {
        case .previous:
            return .init(currentElement: element, isForward: false)
        case .next:
            return .init(currentElement: element, isForward: true)
        @unknown default:
            preconditionFailure("Invalid case!")
        }
    }
}

// MARK: - PlatformAccessibilityElementProtocol

extension PlatformAccessibilityElementProtocol where Self: NSObject {
    func accessibilityResolvedUITextRange(from range: NSRange) -> UITextRange? {
        let element = elementResolvingNode
        let selector = #selector(NSObject._textRange(from:))
        if element.responds(to: selector) {
            return element._textRange(from: range)
        }
        guard element.responds(to: #selector(NSObject._textInputForReveal)),
              let input = element._textInputForReveal() as AnyObject?,
              input.responds(to: selector) else {
            return nil
        }
        return input._textRange(from: range)
    }

    func accessibilityResolvedNSRange(from range: UITextRange) -> NSRange? {
        let element = elementResolvingNode
        let selector = #selector(NSObject._nsrange(for:))
        if element.responds(to: selector) {
            return element._nsrange(for: range)
        }
        guard element.responds(to: #selector(NSObject._textInputForReveal)),
              let input = element._textInputForReveal() as AnyObject?,
              input.responds(to: selector) else {
            return nil
        }
        return input._nsrange(for: range)
    }

    func compareGeometry(to other: PlatformAccessibilityElement) -> ComparisonResult {
        guard responds(to: #selector(NSObject.accessibilityCompareGeometry(_:))) else {
            return .orderedSame
        }
        return accessibilityCompareGeometry(other)
    }

    var stringsForResolvingRange: [String] {
        var strings: [String] = []
        if let label = accessibilityLabel {
            strings.append(label)
        }
        if let value = accessibilityValue, !strings.contains(value) {
            strings.append(value)
        }
        return strings
    }

    func traverseAncestors(_ body: (PlatformAccessibilityElement) -> Bool) {
        var element: PlatformAccessibilityElement? = self
        while let current = element {
            guard body(current) else {
                return
            }
            if current.responds(to: #selector(getter: UIAccessibilityElement.accessibilityContainer)),
               let container = (current as AnyObject).accessibilityContainer as? PlatformAccessibilityElement {
                element = container
            } else if let view = current as? UIView {
                element = view.superview
            } else {
                element = nil
            }
        }
    }

    var elementResolvingNode: PlatformAccessibilityElement {
        if let node = self as? AccessibilityNode,
           let element = node.platformElement {
            return element
        }
        return self
    }
}

// MARK: - PlatformAccessibilityElementProtocol + Bridged Properties [TBA]

extension PlatformAccessibilityElementProtocol where Self: NSObject {
    var bridgedProperties: AccessibilityProperties {
        // TODO: Implement the accessibility property and action storage.
        _openSwiftUIUnimplementedFailure()
    }
}
#endif
