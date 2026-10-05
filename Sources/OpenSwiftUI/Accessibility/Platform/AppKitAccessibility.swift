//
//  AppKitAccessibility.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: WIP (TBA)
//  ID: F9F3632E7F7BE116C99E79BEEDA2329B (SwiftUI)

#if os(macOS)
public import AppKit
import COpenSwiftUI
@_spi(ForOpenSwiftUIOnly)
import OpenSwiftUICore
import OpenSwiftUI_SPI

// MARK: - WindowAccessibilityDelegate [WIP]

private class WindowAccessibilityDelegate: NSObject, NSWindowSwiftUIDelegate {
    static let shared = WindowAccessibilityDelegate()

    func _accessibilityWindow(
        _ window: NSWindow,
        focusedUIElementOverrideWithCurrentValue currentValue: Any?
    ) -> Any? {
        // TODO: Include HostingScrollView when its AppKit implementation is available.
        if currentValue == nil || currentValue is any ViewRendererHost,
           let view = window.firstResponder as? NSView {
            if let element = AccessibilityCore.unignoredDescendant(of: view) {
                return element
            }
            if let host = view.enclosingViewRendererHost as? NSView {
                return host.accessibilityFocusedUIElement()
            }
        }
        guard let element = currentValue as? NSObject else {
            return currentValue
        }
        let node: AccessibilityNode?
        if let cell = element as? NSCell {
            node = cell.accessibilityNodeForPlatformElement
                ?? cell.controlView?.accessibilityNodeForPlatformElement
        } else {
            node = element.accessibilityNodeForPlatformElement
        }
        if let node,
           node.impliedVisibility(consideringParent: true, with: nil) == .hidden,
           let host = node.viewRendererHost as? NSView {
            return host.accessibilityFocusedUIElement()
        }
        return currentValue
    }
}

// MARK: - AppKitAccessibilitySystemAction

class AppKitAccessibilitySystemAction: NSAccessibilityCustomAction {
    private let systemAction: NSAccessibility.Action

    init(systemAction: NSAccessibility.Action, action: @escaping () -> Bool) {
        self.systemAction = systemAction
        super.init(name: systemAction.description ?? systemAction.rawValue, handler: action)
    }

    @objc func _accessibilityCustomActionIdentifier() -> String {
        systemAction.rawValue
    }
}

// MARK: - CustomRotorStorage

class CustomRotorStorage {
    fileprivate var rotor: NSAccessibilityCustomRotor
    fileprivate var entryResolver: RotorEntryResolver

    fileprivate init(rotor: NSAccessibilityCustomRotor, entryResolver: RotorEntryResolver) {
        self.rotor = rotor
        self.entryResolver = entryResolver
    }
}

// MARK: - LoadingToken

@objc(OpenSwiftUIRotorLoadingToken)
private class LoadingToken: NSObject, NSSecureCoding {
    var index: Int

    init(index: Int) {
        self.index = index
        super.init()
    }

    static var supportsSecureCoding: Bool { true }

    required init?(coder: NSCoder) {
        index = coder.decodeInteger(forKey: "index")
        super.init()
    }

    func encode(with coder: NSCoder) {
        coder.encode(index, forKey: "index")
    }
}

// MARK: - RotorEntryResolver

private class RotorEntryResolver: NSObject, NSAccessibilityCustomRotorItemSearchDelegate, NSAccessibilityElementLoading {
    var rotorInfo: AccessibilityRotorInfo
    weak var node: AccessibilityNode?

    init(rotorInfo: AccessibilityRotorInfo, node: AccessibilityNode) {
        self.rotorInfo = rotorInfo
        self.node = node
        super.init()
    }

    func rotor(
        _ rotor: NSAccessibilityCustomRotor,
        resultFor searchParameters: NSAccessibilityCustomRotor.SearchParameters
    ) -> NSAccessibilityCustomRotor.ItemResult? {
        node?.result(for: rotorInfo, going: searchParameters.searchDirection, from: searchParameters.currentItem)
    }

    func accessibilityElement(withToken token: NSAccessibilityLoadingToken) -> (any NSAccessibilityElementProtocol)? {
        guard let token = token as? LoadingToken, let node else {
            return nil
        }
        return node.element(for: rotorInfo, token: token) as? any NSAccessibilityElementProtocol
    }

    func accessibilityRangeInTargetElement(withToken token: NSAccessibilityLoadingToken) -> NSRange {
        guard let token = token as? LoadingToken, let node else {
            return NSRange(location: NSNotFound, length: 0)
        }
        return node.range(for: rotorInfo, token: token) ?? NSRange(location: NSNotFound, length: 0)
    }
}

// MARK: - AppKitAccessibilityLinkRotorBridge

class AppKitAccessibilityLinkRotorBridge: NSAccessibilityCustomRotor, AccessibilityLinkRotorBridge {
    weak var node: AccessibilityNode?
    var paragraphHash: Int = 0
    var elements: [any AccessibilityLinkElement] = []

    init(for node: AccessibilityNode) {
        self.node = node
        super.init(rotorType: .link, itemSearchDelegate: node)
    }

    static func linkElement(for node: AccessibilityNode, range: NSRange) -> any AccessibilityLinkElement {
        LinkElement(node: node, range: range)
    }

    fileprivate class LinkElement: NSAccessibilityElement, NSAccessibilityElementProtocol, AccessibilityLinkElement {
        weak var node: AccessibilityNode?
        var range: NSRange

        init(node: AccessibilityNode, range: NSRange) {
            self.node = node
            self.range = range
            super.init()
        }

        override func isAccessibilityElement() -> Bool {
            true
        }

        override func accessibilityParent() -> Any? {
            node
        }

        override func accessibilityFrame() -> NSRect {
            node?.accessibilityFrameForRange(range) ?? .zero
        }

        override func accessibilityRole() -> NSAccessibility.Role? {
            .link
        }

        override func accessibilityLabel() -> String? {
            node?.accessibilityStringForRange(range)
        }

        override func accessibilityIdentifier() -> String {
            "swiftui-link"
        }
    }
}

// MARK: - AppKitAccessibilityNotificationBridge

private class AppKitAccessibilityNotificationBridge {
    var observers: [NSKeyValueObservation] = []

    static let shared = AppKitAccessibilityNotificationBridge()

    init() {
        observers.append(NSWorkspace.shared.observe(\.isVoiceOverEnabled, options: []) { _, _ in
            NSWorkspace.shared.notificationCenter.post(name: NSWorkspace.voiceOverStatusChangedNotification, object: nil)
        })
        observers.append(NSWorkspace.shared.observe(\.isSwitchControlEnabled, options: []) { _, _ in
            NSWorkspace.shared.notificationCenter.post(name: NSWorkspace.switchControlStatusChangedNotification, object: nil)
        })
        observers.append(NSWorkspace.shared.observe(\.isAccessibilityFullKeyboardAccessEnabled, options: []) { _, _ in
            NSWorkspace.shared.notificationCenter.post(name: NSWorkspace.fullKeyboardAccessStatusChangedNotification, object: nil)
        })
    }
}

// MARK: - AccessibilityProperties + AppKit

extension AccessibilityProperties {
    struct SubroleKey: AccessibilityOptionalPropertiesKey {
        static let valueType = NSAccessibility.Subrole.self
    }

    var subrole: NSAccessibility.Subrole? {
        get { self[SubroleKey.self] }
        set { self[SubroleKey.self] = newValue }
    }

    struct RoleKey: AccessibilityOptionalPropertiesKey {
        static let valueType = NSAccessibility.Role.self
    }

    var role: NSAccessibility.Role? {
        get { self[RoleKey.self] }
        set { self[RoleKey.self] = newValue }
    }

    var platformStorage: AccessibilityPlatformPropertyStorage {
        .init(explicitRole: role?.rawValue, explicitSubrole: subrole?.rawValue)
    }
}

// MARK: - AccessibilityFocus.FocusNotification

extension AccessibilityFocus {
    private struct FocusNotification {
        var element: PlatformAccessibilityElement?
    }
}

// MARK: - AccessibilityValueStorage + AppKit

extension AccessibilityValueStorage {
    enum Resolved {
        case typed(AccessibilityValueStorage)
        case texts([Text])
    }

    var platformValue: Any? {
        guard let value = value?.value else {
            return nil
        }
        if let wrapper = value as? any ValueWrapper {
            return wrapper.wrappedValue
        }
        return value
    }
}

// MARK: - AppKitAccessibilityLocationDescriptor

struct AppKitAccessibilityLocationDescriptor {
    weak var view: NSView?
    var attributedName: NSAttributedString
    var point: CGPoint

    init?(
        _ point: AccessibilityActivationPoint,
        in environment: EnvironmentValues,
        for node: AccessibilityNode,
        kind: AccessibilityActivationPoint.InteractionKind,
        resolveLabel: Bool
    ) {
        let description = point.resolvedDescription(for: node, in: environment, kind: kind, resolveLabel: resolveLabel)
        guard let attributedName = AccessibilityCore.textResolvedToAttributedText(description, in: environment),
              let location = node.resolvedDragDropPoint(for: point.location),
              let view = node.viewRendererHost as? NSView,
              let window = view.window else {
            return nil
        }
        self.view = view
        self.attributedName = attributedName
        let windowPoint: CGPoint
        switch location {
        case var .global(point):
            if _SemanticFeature_v3.isEnabled {
                point.y = (view.window?.frame.height ?? 0) - point.y
            }
            windowPoint = point
        case let .screen(point):
            windowPoint = window.convertPoint(fromScreen: point)
        }
        self.point = view.convert(windowPoint, from: nil)
    }

    private enum RepresentationKey: String {
        case viewPointerNumber
        case pointValue
        case attributedName

        var platformRawValue: String {
            "AXInteractionLocationDescriptor\(rawValue.prefix(1).capitalized)\(rawValue.dropFirst())Key"
        }
    }
}

// MARK: - AppKitAccessibilityPropertyApplicator

struct AppKitAccessibilityPropertyApplicator: AccessibilityPlatformPropertyApplicator {
    static func apply(
        _ storage: AccessibilityPlatformPropertyStorage,
        to properties: inout AccessibilityProperties
    ) {
        properties.role = storage.explicitRole.map { NSAccessibility.Role(rawValue: $0) }
        properties.subrole = storage.explicitSubrole.map { NSAccessibility.Subrole(rawValue: $0) }
    }
}

// MARK: - AccessibilityRole.Resolved

extension AccessibilityRole {
    struct Resolved {
        var role: NSAccessibility.Role?
        var subrole: NSAccessibility.Subrole?
        var traits: AXOpenSwiftUITraits?
    }
}

// MARK: - AccessibilityRotorInfo + AppKit

extension AccessibilityRotorInfo {
    func resolve(in environment: EnvironmentValues, for node: AccessibilityNode) -> NSAccessibilityCustomRotor? {
        let id = designation.uniqueID(in: environment)
        if let storage = node.platformRotorStorage[id] {
            return storage.rotor
        }
        let resolver = RotorEntryResolver(rotorInfo: self, node: node)
        let rotor: NSAccessibilityCustomRotor
        switch designation {
        case let .user(label):
            rotor = NSAccessibilityCustomRotor(
                label: label.resolveString(in: environment, with: .includeAccessibility, idiom: nil),
                itemSearchDelegate: resolver
            )
        case let .system(system):
            rotor = NSAccessibilityCustomRotor(rotorType: system.customRotorType, itemSearchDelegate: resolver)
        }
        rotor.itemLoadingDelegate = resolver
        node.platformRotorStorage[id] = CustomRotorStorage(rotor: rotor, entryResolver: resolver)
        return rotor
    }
}

extension AccessibilitySystemRotor {
    var customRotorType: NSAccessibilityCustomRotor.RotorType {
        switch rawValue {
        case .links: .link
        case .visitedLinks: .visitedLink
        case .headings: .heading
        case .headingsLevel1: .headingLevel1
        case .headingsLevel2: .headingLevel2
        case .headingsLevel3: .headingLevel3
        case .headingsLevel4: .headingLevel4
        case .headingsLevel5: .headingLevel5
        case .headingsLevel6: .headingLevel6
        case .boldText: .boldText
        case .italicText: .italicText
        case .underlineText: .underlinedText
        case .misspelledWords: .misspelledWord
        case .images: .image
        case .textFields: .textField
        case .tables: .table
        case .lists: .list
        case .landmarks: .landmark
        }
    }
}

// MARK: - AccessibilityNode + Custom Rotor Entries [TBA]

private extension AccessibilityNode {
    func result(
        for rotorInfo: AccessibilityRotorInfo,
        going direction: NSAccessibilityCustomRotor.SearchDirection,
        from currentItem: NSAccessibilityCustomRotor.ItemResult?
    ) -> NSAccessibilityCustomRotor.ItemResult? {
        // TODO: Resolve the next rotor entry and its platform item result.
        _openSwiftUIUnimplementedFailure()
    }

    func element(for rotorInfo: AccessibilityRotorInfo, token: LoadingToken) -> PlatformAccessibilityElement? {
        temporarilySuppressingLayoutChanged(for: 0.1) { () -> PlatformAccessibilityElement? in
            // TODO: Resolve and prepare the rotor entry at token.index.
            _openSwiftUIUnimplementedFailure()
        }
    }

    func range(for rotorInfo: AccessibilityRotorInfo, token: LoadingToken) -> NSRange? {
        temporarilySuppressingLayoutChanged(for: 0.1) { () -> NSRange? in
            // TODO: Resolve the range of the prepared rotor entry at token.index.
            _openSwiftUIUnimplementedFailure()
        }
    }
}

// MARK: - AccessibilityNode + NSAccessibilityCustomRotorItemSearchDelegate

extension AccessibilityNode: NSAccessibilityCustomRotorItemSearchDelegate {
    func rotor(
        _ rotor: NSAccessibilityCustomRotor,
        resultFor searchParameters: NSAccessibilityCustomRotor.SearchParameters
    ) -> NSAccessibilityCustomRotor.ItemResult? {
        guard let rotor = rotor as? AppKitAccessibilityLinkRotorBridge,
              let parameters = searchParameters.linkRotorSearchParameters else {
            return nil
        }
        rotor.update()
        guard let element = rotor.search(parameters: parameters) as? AppKitAccessibilityLinkRotorBridge.LinkElement else {
            return nil
        }
        return NSAccessibilityCustomRotor.ItemResult(targetElement: element)
    }
}

private extension NSAccessibilityCustomRotor.SearchParameters {
    var linkRotorSearchParameters: AccessibilityLinkRotorSearchParameters? {
        let element = currentItem?.targetElement as? any AccessibilityLinkElement
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

// MARK: - NSWorkspace + Accessibility Notifications

private extension NSWorkspace {
    static let voiceOverStatusChangedNotification = Notification.Name("OpenSwiftUI_VoiceOverStatusDidChangeNotification")
    static let switchControlStatusChangedNotification = Notification.Name("OpenSwiftUI_SwitchControlStatusDidChangeNotification")
    static let fullKeyboardAccessStatusChangedNotification = Notification.Name("OpenSwiftUI_FullKeyboardAccessStatusDidChangeNotification")
    static let voiceControlStatusChangedNotification = Notification.Name("kDictationIMNotificationUseOnlyOfflineDictationChanged")
    static let hoverTextStatusChangedNotification = Notification.Name("com.apple.accessibility.AXVisualSupportAgent.hoverTextSettingsDidChange")
}

// MARK: - AccessibilityCoreNotification

protocol AccessibilityCoreNotification {
    static var name: NSAccessibility.Notification { get }
    var info: AccessibilityCore.Notification.Info { get }
}

extension AccessibilityCoreNotification {
    func post() {
        info.post(name: Self.name)
    }
}

// MARK: - AccessibilityCore + AppKit

extension AccessibilityCore {
    enum Notification {
        struct Info {
            var element: PlatformAccessibilityElement
            var userInfo: [NSAccessibility.NotificationUserInfoKey: Any]?

            func post(name: NSAccessibility.Notification) {
                if name == .layoutChanged, suppressLayoutChangedCount != 0 {
                    return
                }
                var element: Any = self.element
                if name == .layoutChanged,
                   let ancestor = NSAccessibility.unignoredAncestor(of: element) {
                    element = ancestor
                }
                NSAccessibility.post(element: element, notification: name, userInfo: userInfo)
            }
        }

        struct LayoutChanged: AccessibilityCoreNotification {
            var sourceElement: PlatformAccessibilityElement
            var nextElement: PlatformAccessibilityElement?

            static var name: NSAccessibility.Notification { .layoutChanged }

            var info: Info {
                var userInfo: [NSAccessibility.NotificationUserInfoKey: Any] = [
                    .uiElements: [sourceElement],
                ]
                if let nextElement {
                    userInfo[.init(rawValue: "AXElementToFocusForLayoutChange")] = nextElement
                }
                return Info(element: sourceElement, userInfo: userInfo)
            }
        }
    }

    static func unignoredDescendant(of element: Any) -> PlatformAccessibilityElement? {
        NSAccessibility.unignoredDescendant(of: element) as? PlatformAccessibilityElement
    }
}

private extension NSView {
    var enclosingViewRendererHost: (any ViewRendererHost)? {
        if let host = self as? any ViewRendererHost {
            return host
        }
        return superview?.enclosingViewRendererHost
    }
}

private var suppressLayoutChangedCount: UInt = 0

func temporarilySuppressingLayoutChanged<Result>(for delay: Double?, work: () -> Result) -> Result {
    suppressLayoutChangedCount += 1
    defer {
        if let delay {
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                suppressLayoutChangedCount -= 1
            }
        } else {
            suppressLayoutChangedCount -= 1
        }
    }
    return work()
}

// MARK: - PlatformAccessibilityElementProtocol + NSObject extension

extension PlatformAccessibilityElementProtocol where Self: NSObject {
    var stringsForResolvingRange: [String] {
        var strings: [String] = []
        if let label = valueForAttribute(.description, asType: String.self) {
            strings.append(label)
        }
        if let value = valueForAttribute(.value, asType: Any.self) as? String,
           !strings.contains(value) {
            strings.append(value)
        }
        return strings
    }

    func releaseAccessibilityLock(
        for attribute: NSAccessibility.Attribute,
        source: AXAttributeLockSource
    ) -> Bool {
        guard accessibilityLockSource(for: attribute) == source else {
            return false
        }
        setAccessibilityLockSource(.none, for: attribute)
        return true
    }

    func setAccessibilityLockedOverrideHandler(
        for attribute: NSAccessibility.Attribute,
        source: AXAttributeLockSource,
        _ handler: (() -> Any?)?
    ) -> Bool {
        let currentSource = accessibilityLockSource(for: attribute)
        guard currentSource == .none || currentSource == source else {
            return false
        }
        setAccessibilityLockSource(source, for: attribute)
        return _accessibilitySetOverrideHandler(handler, for: attribute)
    }

    func valueForAttribute<Value>(_ attribute: NSAccessibility.Attribute, asType: Value.Type) -> Value? {
        NSAccessibilityBeginInternalAccessors()
        defer { NSAccessibilityEndInternalAccessors() }
        guard let value = NSAccessibilityEntryPointValueForAttribute(self, attribute),
              !(value is NSNull) else {
            return nil
        }
        return value as? Value
    }

    var viewsHaveHitTestingPriority: Bool {
        AXNSTableRowClass().map { isKind(of: $0) } ?? false
    }

    func traverseAncestors(_ body: (PlatformAccessibilityElement) -> Bool) {
        var element: PlatformAccessibilityElement? = self
        while let current = element {
            guard body(current) else {
                return
            }
            if let cell = current as? NSCell, let controlView = cell.controlView {
                element = controlView
            } else if let parent = current.valueForAttribute(.parent, asType: NSObject.self),
                      !(parent is NSWindow), !(parent is NSView) {
                element = parent
            } else if let view = current as? NSView, let superview = view.superview {
                element = superview
            } else {
                element = current.valueForAttribute(.parent, asType: NSObject.self)
            }
        }
    }

    func setAccessibilityLockedOverride(
        for attribute: NSAccessibility.Attribute,
        source: AXAttributeLockSource,
        _ value: Any?
    ) -> Bool {
        let currentSource = accessibilityLockSource(for: attribute)
        guard currentSource == .none || currentSource == source else {
            return false
        }
        setAccessibilityLockSource(source, for: attribute)
        return _accessibilitySetOverrideValue(value, for: attribute)
    }
}

// MARK: - PlatformAccessibilityElementProtocol + Bridged Properties

extension PlatformAccessibilityElementProtocol where Self: NSObject {
    var bridgedProperties: AccessibilityProperties {
        guard let elements = NSAccessibility.unignoredChildrenForOnlyChild(from: knownRepresentedElement) as? [PlatformAccessibilityElement],
              !elements.isEmpty else {
            return knownRepresentedElement._bridgedProperties
        }
        if elements.count == 1 {
            return elements[0]._bridgedProperties
        }
        return AccessibilityChildBehavior.defaultCombine(
            childProperties: elements.map { $0._bridgedProperties },
            createsCustomActions: true
        )
    }

    private var _bridgedProperties: AccessibilityProperties {
        var properties = AccessibilityProperties(reserving: 4)
        if let description = valueForAttribute(.description, asType: String.self), !description.isEmpty {
            properties.labelStorage = AccessibilityLabelStorage(texts: [AccessibilityText(description).text])
        } else if let title = valueForAttribute(.title, asType: String.self), !title.isEmpty {
            properties.labelStorage = AccessibilityLabelStorage(texts: [AccessibilityText(title).text])
        }
        if let description = valueForAttribute(.valueDescription, asType: String.self), !description.isEmpty {
            properties.value = AccessibilityValueStorage(description: AccessibilityText(description).text)
        } else if let value = valueForAttribute(.value, asType: String.self), !value.isEmpty {
            properties.value = AccessibilityValueStorage(description: AccessibilityText(value).text)
        }
        if let help = valueForAttribute(.help, asType: String.self), !help.isEmpty {
            properties.hints = [AccessibilityText(help).text]
        }
        if let labels = valueForAttribute(.attributedUserInputLabelsAttribute, asType: [NSAttributedString].self),
           !labels.isEmpty {
            properties.inputLabels = labels.map { AccessibilityText($0).text }
        }
        if let identifier = valueForAttribute(.identifier, asType: String.self), !identifier.isEmpty {
            properties.identifierStorage = AccessibilityIdentifierStorage(identifier)
        }

        var actions: [AnyAccessibilityAction] = []
        if let actionNames = NSAccessibilityEntryPointActionNames(self) as? [NSAccessibility.Action] {
            for actionName in actionNames where actionName != .press {
                guard let description = NSAccessibilityEntryPointActionDescription(self, actionName) else {
                    continue
                }
                let action = AnyAccessibilityAction(
                    action: AccessibilityVoidAction(kind: .init(named: AccessibilityText(description).text)),
                    label: nil,
                    image: nil,
                    handler: { [weak self] in
                        .init(booleanLiteral: NSAccessibilityEntryPointPerformAction(self as Any, actionName))
                    },
                    bridged: true
                )
                actions.append(action)
            }
        }
        if accessibilityOpenSwiftUIDefaultActionStoredBlock != nil {
            let action = AnyAccessibilityAction(
                action: AccessibilityVoidAction(kind: .default),
                label: nil,
                image: nil,
                handler: { [weak self] in
                    .init(booleanLiteral: self?.accessibilityOpenSwiftUIDefaultActionStoredBlock?() ?? false)
                },
                bridged: true
            )
            actions.append(action)
        }
        if !actions.isEmpty {
            properties.actions = actions
        }
        return properties
    }
}

// MARK: - NSControl + PlatformAccessibilityElementProtocol

@_spi(ForOpenSwiftUIOnly)
extension NSControl {
    override dynamic public var knownRepresentedElement: any PlatformAccessibilityElement {
        if let cell {
            return cell
        }
        return self
    }

    override dynamic public var rotorOwnerElement: any PlatformAccessibilityElement {
        self
    }
}

// MARK: - NSScrollView + PlatformAccessibilityElementProtocol

@_spi(ForOpenSwiftUIOnly)
extension NSScrollView {
    override dynamic public var knownRepresentedElement: any PlatformAccessibilityElement {
        if let tableView = documentView as? NSTableView {
            return tableView
        }
        return self
    }

    override dynamic public var rotorOwnerElement: any PlatformAccessibilityElement {
        if let documentView,
           documentView.valueForAttribute(.isAccessibilityElementAttribute, asType: Bool.self) == true {
            return documentView
        }
        return self
    }
}
#endif
