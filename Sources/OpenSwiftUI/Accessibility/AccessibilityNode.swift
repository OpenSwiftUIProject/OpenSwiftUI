//
//  AccessibilityNode.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: WIP
//  ID: 2F6327E72581B7F866C81F7546545BE8 (SwiftUI)

import Foundation
import OpenAttributeGraphShims
@_spi(ForOpenSwiftUIOnly)
import OpenSwiftUICore
import struct OpenSwiftUICore.UniqueID

#if canImport(UIKit)
import UIKit
typealias AccessibilityNodeBase = UIResponder
#else
typealias AccessibilityNodeBase = NSObject
#endif

// MARK: - AccessibilityNode [TBA]

class AccessibilityNode: AccessibilityNodeBase {
    let id = UniqueID()

    var version = DisplayList.Version()

    var children: [AccessibilityNode] = []

    weak var bridgedChild: AccessibilityNode?

    var bridgedChildren: [AccessibilityNode] {
        bridgedChild?.children ?? []
    }

    weak var parent: AccessibilityNode?

    weak var viewRendererHost: (any ViewRendererHost)?

    var isFromDisplayList: Bool

    var environment: EnvironmentValues

    private var attachmentsStorage: [AccessibilityAttachmentStorage] = []

    private var cachedCombinedAttachment: AccessibilityAttachment?

    var platformElementPropertiesDirty = true

    #if canImport(UIKit)
    var platformRotorStorage: [String: UIAccessibilityCustomRotor] = [:]
    #endif

    var cachedIsPlaceholderOrIgnored: Bool?

    var relationshipScope: AccessibilityRelationshipScope?

    override convenience init() {
        self.init(viewRendererHost: nil, isFromDisplayList: false)
    }

    init(viewRendererHost: (any ViewRendererHost)?, isFromDisplayList: Bool) {
        self.viewRendererHost = viewRendererHost
        self.isFromDisplayList = isFromDisplayList
        environment = EnvironmentValues()
        environment.configureForPlatform(traitCollection: nil)
        super.init()
    }

    var representedElement: PlatformAccessibilityElement {
        platformElement ?? self
    }

    var platformElement: PlatformAccessibilityElement? {
        for storage in attachmentsStorage.reversed() {
            if let element = storage.attachment.platformElement {
                return element
            }
        }
        return nil
    }

    var properties: AccessibilityProperties {
        attachment.properties
    }

    private var attachment: AccessibilityAttachment {
        if let cachedCombinedAttachment {
            return cachedCombinedAttachment
        }
        let attachment = AccessibilityAttachment.combine(attachmentsStorage.map(\.attachment))
        cachedCombinedAttachment = attachment
        platformElementPropertiesDirty = true
        return attachment
    }

    func updatePlatformProperties() {
        if platformElement != nil {
            // TODO: Apply platform properties and relationships to the element.
            _openSwiftUIUnimplementedFailure()
        }
        switch explicitVisibility ?? .container {
        case .container, .containerElement:
            for child in children {
                child.updatePlatformProperties()
            }
        case .element, .hidden:
            break
        }
    }

    func addAttachment(
        _ attachment: AccessibilityAttachment,
        isInPlatformItemList: Bool,
        token: AccessibilityAttachmentToken?
    ) {
        scheduleNotifyForAttachmentAddition(of: attachment)
        attachmentsStorage.append(.init(attachment: attachment, geometry: nil, token: token))
        cachedCombinedAttachment = nil
        platformElementPropertiesDirty = true
    }

    func removeAttachment(isInPlatformItemList: Bool, token: AccessibilityAttachmentToken?) {
        guard let storage = attachmentsStorage.first(where: { $0.token == token }) else {
            return
        }
        scheduleNotifyForAttachmentChange(from: storage.attachment, to: nil)
        attachmentsStorage.removeAll { $0.token == token }
        cachedCombinedAttachment = nil
        platformElementPropertiesDirty = true
    }

    func attachmentIndex(of token: AccessibilityAttachmentToken?) -> Int? {
        guard let token else {
            return attachmentsStorage.isEmpty ? nil : 0
        }
        return attachmentsStorage.firstIndex { $0.token == token }
    }

    func removeAttachments(after token: AccessibilityAttachmentToken) {
        guard let index = attachmentIndex(of: token) else {
            return
        }
        // The matching attachment is part of the suffix to remove.
        let removed = attachmentsStorage[index...]
        attachmentsStorage.removeSubrange(index...)
        scheduleNotifyForAttachmentChange(from: .combine(removed.map(\.attachment)), to: nil)
        cachedCombinedAttachment = nil
        platformElementPropertiesDirty = true
    }

    func hasAttachment(token: AccessibilityAttachmentToken?) -> Bool {
        attachmentsStorage.contains { $0.token == token }
    }

    func updateAttachment(
        _ attachment: AccessibilityAttachment,
        isInPlatformItemList: Bool,
        token: AccessibilityAttachmentToken?,
        merge: Bool
    ) -> Bool {
        guard let index = attachmentIndex(of: token) else {
            return false
        }
        let previous = attachmentsStorage[index].attachment
        guard previous != attachment else {
            return false
        }
        var previousProperties = previous.properties
        var newProperties = attachment.properties
        var needsNotification = true
        if !previousProperties.actions.isEmpty,
           previousProperties.actions.count == newProperties.actions.count {
            previousProperties.actions = []
            newProperties.actions = []
            needsNotification = previousProperties != newProperties
        }
        if needsNotification {
            scheduleNotifyForAttachmentChange(from: previous, to: attachment)
        }
        if merge {
            attachmentsStorage[index].attachment.merge(with: attachment)
        } else {
            attachmentsStorage[index].attachment = attachment
        }
        cachedCombinedAttachment = nil
        platformElementPropertiesDirty = true
        return needsNotification
    }

    func updateChildren(_ children: [AccessibilityNode]) {
        let changedIDs = Set(self.children.map(\.id)).symmetricDifference(children.map(\.id))
        let fullReplacement = !self.children.isEmpty
            && changedIDs.count == self.children.count + children.count
        for child in children {
            child.parent = self
        }
        for child in self.children where changedIDs.contains(child.id) {
            child.parent = nil
        }
        self.children = children
        switch impliedVisibility(consideringParent: true, with: nil) {
        case .container, .containerElement:
            if !changedIDs.isEmpty {
                scheduleNotifyForChildrenChange(fullReplacement: fullReplacement)
            }
        case .element, .hidden:
            break
        }
    }

    func updateSize(_ size: CGSize, token: AccessibilityAttachmentToken?) {
        guard let index = attachmentIndex(of: token) else { return }
        if attachmentsStorage[index].geometry == nil {
            attachmentsStorage[index].geometry = AccessibilityGeometryStorage(for: self)
        }
        attachmentsStorage[index].geometry?.updateSize(size)
    }

    func updateTransform(_ transform: ViewTransform, token: AccessibilityAttachmentToken?) {
        guard let index = attachmentIndex(of: token) else { return }
        if attachmentsStorage[index].geometry == nil {
            attachmentsStorage[index].geometry = AccessibilityGeometryStorage(for: self)
        }
        attachmentsStorage[index].geometry?.updateTransform(transform)
    }

    func updatePath(_ path: Path, token: AccessibilityAttachmentToken?) {
        guard let index = attachmentIndex(of: token) else { return }
        if attachmentsStorage[index].geometry == nil {
            attachmentsStorage[index].geometry = AccessibilityGeometryStorage(for: self)
        }
        attachmentsStorage[index].geometry?.updatePath(path)
    }

    func updateViewResponders(_ responders: [ViewResponder], token: AccessibilityAttachmentToken?) {
        guard let index = attachmentIndex(of: token) else { return }
        if attachmentsStorage[index].geometry == nil {
            attachmentsStorage[index].geometry = AccessibilityGeometryStorage(for: self)
        }
        attachmentsStorage[index].geometry?.updateViewResponders(responders)
    }

    func updateEnvironment(_ environment: EnvironmentValues) {
        var environment = environment
        environment.configureForPlatform(traitCollection: nil)
        self.environment = environment
        cachedIsPlaceholderOrIgnored = nil
    }

    func sendAction(_ action: AccessibilityActionKind) -> Bool {
        sendAction(AccessibilityVoidAction(kind: action))
    }

    func sendAction<A>(_ action: A) -> Bool where A: AccessibilityAction, A.Value == Void {
        sendAction(action, value: ())
    }

    func sendAction<A>(_ action: A, value: A.Value) -> Bool where A: AccessibilityAction {
        guard isEnabled else { return false }
        var actions = properties.actions
        if let action = action as? AccessibilityVoidAction, action.kind == .default {
            actions.reverse()
        }
        var performed = false
        for candidate in actions {
            switch candidate.perform(action: action, value: value) {
            case .success:
                viewRendererHost?.render(targetTimestamp: nil)
                return true
            case .passive:
                performed = true
            case .failure(true):
                continue
            case .failure(false):
                return false
            }
        }
        if performed {
            viewRendererHost?.render(targetTimestamp: nil)
        }
        return performed
    }

    func sendAction(named name: String) -> Bool {
        guard isEnabled else { return false }
        var performed = false
        for action in properties.actions {
            guard let text = action.name,
                  AccessibilityCore.textResolvedToPlainText(text, in: environment) == name else {
                continue
            }
            switch action.perform(value: ()) {
            case .success:
                viewRendererHost?.render(targetTimestamp: nil)
                return true
            case .passive:
                performed = true
            case .failure(true):
                continue
            case .failure(false):
                return false
            }
        }
        if performed {
            viewRendererHost?.render(targetTimestamp: nil)
        }
        return performed
    }

    var hasAnyAction: Bool {
        !properties.actions.isEmpty
    }

    var traits: AccessibilityNullableOptionSet<AccessibilityTraitSet> {
        if let cachedCombinedAttachment {
            return cachedCombinedAttachment.properties.traits
        }
        var traits = AccessibilityNullableOptionSet<AccessibilityTraitSet>()
        for storage in attachmentsStorage.reversed() {
            traits.merge(with: storage.attachment.properties.traits)
        }
        return traits
    }

    var visibility: AccessibilityVisibilityStorage {
        if let cachedCombinedAttachment {
            return cachedCombinedAttachment.properties.visibility
        }
        var visibility = AccessibilityVisibilityStorage()
        for storage in attachmentsStorage.reversed() {
            visibility.merge(with: storage.attachment.properties.visibility)
        }
        return visibility
    }

    func visibilityIgnoringAttachment(with token: AccessibilityAttachmentToken) -> AccessibilityVisibilityStorage {
        var visibility = AccessibilityVisibilityStorage()
        for storage in attachmentsStorage.reversed() where storage.token != token {
            visibility.merge(with: storage.attachment.properties.visibility)
        }
        return visibility
    }

    var automationVisibility: AccessibilityVisibilityStorage {
        if let cachedCombinedAttachment {
            return cachedCombinedAttachment.properties.automationVisibility ?? .init()
        }
        var visibility = AccessibilityVisibilityStorage()
        for storage in attachmentsStorage.reversed() {
            if let value = storage.attachment.properties.automationVisibility {
                visibility.merge(with: value)
            }
        }
        return visibility
    }

    var explicitVisibility: AccessibilityVisibility.Resolved? {
        visibility.resolved
    }

    func impliedVisibility(
        consideringParent: Bool,
        with parentVisibility: AccessibilityVisibility.Resolved?
    ) -> AccessibilityVisibility.Resolved {
        let explicit = explicitVisibility
        if explicit == .hidden { return .hidden }
        if let parent {
            let inherited = parentVisibility
                ?? parent.impliedVisibility(consideringParent: consideringParent, with: nil)
            if inherited == .hidden { return .hidden }
            if consideringParent, inherited == .element, parent.platformElement == nil {
                return .hidden
            }
        }
        if isPlaceholderOrIgnored { return .hidden }
        if let explicit { return explicit }
        return children.isEmpty && bridgedChildren.isEmpty ? .element : .container
    }

    var isEnabled: Bool {
        environment.isEnabled
    }

    var isPlaceholderOrIgnored: Bool {
        if let cachedIsPlaceholderOrIgnored {
            return cachedIsPlaceholderOrIgnored
        }
        let result = (traits[.isStaticText, default: false] || traits[.isImage, default: false])
            && environment.redactionReasons.contains(.placeholder)
        cachedIsPlaceholderOrIgnored = result
        return result
    }

    var locale: Locale {
        properties.locale ?? environment.locale
    }

    var isLabel: Bool {
        if traits[.isLabel, default: false] { return true }
        guard relationshipScope != nil else { return false }
        // TODO: Resolve labeled-pair content in the relationship scope.
        _openSwiftUIUnimplementedFailure()
    }

    var sortPriority: Double? {
        if let cachedCombinedAttachment {
            return cachedCombinedAttachment.properties.sortPriority
        }
        for storage in attachmentsStorage.reversed() {
            if let priority = storage.attachment.properties.sortPriority {
                return priority
            }
        }
        return nil
    }

    var resolvedAttributedValue: NSAttributedString? {
        let type = properties.value?.value?.type
        if let value = resolvedAttributedTexts(
            properties.value?.valueDescription,
            includeDefaultAttributes: type != .disclosure && type != .toggle
        ) {
            return value
        }
        return resolvedAttributedTexts(
            resolvedToggleValue?.valueDescription,
            includeDefaultAttributes: false
        )
    }

    var resolvedPlainTextValue: String? {
        resolvedPlainTexts(properties.value?.valueDescription)
            ?? resolvedPlainTexts(resolvedToggleValue?.valueDescription)
    }

    var resolvedAttributedLabel: NSAttributedString? {
        resolvedAttributedTexts(properties.labelStorage?.texts)
    }

    var resolvedPlainTextLabel: String? {
        resolvedPlainTexts(properties.labelStorage?.texts)
    }

    var resolvedToggleValue: AccessibilityValueStorage? {
        guard properties.traits[.isToggle, default: false] else { return nil }
        return AccessibilityValueStorage(AccessibilityToggleValue(
            properties.traits[.isSelected, default: false] ? .on : .off
        ))
    }

    var isFromArchive: Bool {
        attachmentsStorage.contains {
            if case .identifier = $0.token { return true }
            return false
        }
    }

    func resolvedAttributedTexts(
        _ texts: [Text]?,
        includeDefaultAttributes: Bool = true,
        separator: Text = Text.Accessibility.comma
    ) -> NSAttributedString? {
        guard let texts else { return nil }
        return AccessibilityCore.textsResolvedToAttributedText(
            texts,
            in: environment,
            includeDefaultAttributes: includeDefaultAttributes,
            updateResolvableAttributes: isFromArchive,
            resolveSuffix: properties.textLayoutProperties != nil,
            idiom: _GraphInputs.defaultInterfaceIdiom,
            separator: resolvedPlainText(separator) ?? ", "
        )
    }

    func resolvedPlainText(_ text: Text?) -> String? {
        guard let text else { return nil }
        return AccessibilityCore.textResolvedToPlainText(
            text,
            in: environment,
            updateResolvableAttributes: true,
            resolveSuffix: properties.textLayoutProperties != nil
        )
    }

    func resolvedPlainTexts(_ texts: [Text]?, separator: Text = Text.Accessibility.comma) -> String? {
        guard let texts, !texts.isEmpty else { return nil }
        return AccessibilityCore.textsResolvedToPlainText(
            texts,
            in: environment,
            updateResolvableAttributes: true,
            idiom: _GraphInputs.defaultInterfaceIdiom,
            separator: resolvedPlainText(separator) ?? ", "
        )
    }

    var resolvedIsInteractive: Bool? {
        if let interactive = properties[trait: .isInteractive] { return interactive }
        guard isEnabled else { return false }
        if hasAnyAction { return true }
        return properties[trait: .isSingleSiblingWithGesture, default: false] ? true : nil
    }

    var subgraph: Subgraph? {
        // TODO: Resolve the subgraph from attachment tokens.
        _openSwiftUIUnimplementedFailure()
    }

    #if canImport(UIKit)
    override var next: UIResponder? {
        parent ?? viewRendererHost as? UIView
    }
    #endif

    private func scheduleNotifyForAttachmentAddition(of attachment: AccessibilityAttachment) {
        guard attachment.properties.traits[.isModal, default: false],
              impliedVisibility(consideringParent: true, with: nil) != .hidden else {
            return
        }
        #if canImport(UIKit)
        guard viewRendererHost is UIView else { return }
        #endif
        // TODO: Schedule AccessibilityCore.ScreenChanged on the main queue.
        _openSwiftUIUnimplementedFailure()
    }

    private func scheduleNotifyForAttachmentChange(
        from previous: AccessibilityAttachment,
        to attachment: AccessibilityAttachment?
    ) {
        // TODO: Compute attachment notifications and post them on the main queue.
        _openSwiftUIUnimplementedFailure()
    }

    private func scheduleNotifyForChildrenChange(fullReplacement: Bool) {
        // TODO: Schedule AccessibilityCore.ScreenChanged or LayoutChanged.
        _openSwiftUIUnimplementedFailure()
    }

    func accessibilityCustomAttribute(_ name: String) -> Any? {
        properties.customAttributes?[name]?.axRepresentation()
    }
}

private struct AccessibilityAttachmentStorage {
    var attachment: AccessibilityAttachment
    var geometry: AccessibilityGeometryStorage?
    let token: AccessibilityAttachmentToken?
}
