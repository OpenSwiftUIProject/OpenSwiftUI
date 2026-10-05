//
//  AccessibilityProperties.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete

@_spi(ForOpenSwiftUIOnly)
package import OpenSwiftUICore

// MARK: - AccessibilityProperties + AccessibilityCombinable

extension AccessibilityProperties: AccessibilityCombinable {
    @discardableResult
    package mutating func merge(with child: AccessibilityProperties) -> Bool {
        guard !child.isEmpty else {
            return false
        }
        visibility.merge(with: child.visibility)
        traits.merge(with: child.traits)
        if labelStorage == nil {
            labelStorage = child.labelStorage
            if textLayoutProperties == nil {
                textLayoutProperties = child.textLayoutProperties
            }
        } else if labelStorage.merge(with: child.labelStorage) {
            textLayoutProperties = nil
        } else if child.labelStorage == nil, textLayoutProperties == nil {
            textLayoutProperties = child.textLayoutProperties
        }
        value.merge(with: child.value)
        if hints.isEmpty {
            hints = child.hints
        }
        if roleDescription == nil {
            roleDescription = child.roleDescription
        }
        activationPointStorage.merge(with: child.activationPointStorage)
        if inputLabels == nil {
            inputLabels = child.inputLabels
        }
        actions.merge(with: child.actions)
        customAttributes.merge(with: child.customAttributes)
        identifierStorage.merge(with: child.identifierStorage)
        if sortPriority == nil {
            sortPriority = child.sortPriority
        }
        if explicitAutomationType == nil {
            explicitAutomationType = child.explicitAutomationType
        }
        #if os(macOS)
        if focusViewItemID == nil {
            focusViewItemID = child.focusViewItemID
        }
        if focusViewElement == nil {
            focusViewElement = child.focusViewElement
        }
        #endif
        if dataSeriesConfiguration == nil {
            dataSeriesConfiguration = child.dataSeriesConfiguration
        }
        if scrollableCollection == nil {
            scrollableCollection = child.scrollableCollection
        }
        if scrollableContext == nil {
            scrollableContext = child.scrollableContext
        }
        if touchInfo == nil {
            touchInfo = child.touchInfo
        }
        #if os(macOS)
        if autoInteractable == nil {
            autoInteractable = child.autoInteractable
        }
        if role == nil {
            role = child.role
        }
        if subrole == nil {
            subrole = child.subrole
        }
        #elseif canImport(UIKit)
        uiKitTraits.merge(with: child.uiKitTraits)
        if uiKitBridgedInteraction == nil {
            uiKitBridgedInteraction = child.uiKitBridgedInteraction
        }
        #endif
        if linkDestination == nil {
            linkDestination = child.linkDestination
        }
        customContentList.merge(with: child.customContentList)
        if textContentType == nil {
            textContentType = child.textContentType
        }
        if textHeadingLevel == nil {
            textHeadingLevel = child.textHeadingLevel
        }
        rotorInfo.merge(with: child.rotorInfo)
        #if !os(macOS)
        images.merge(with: child.images)
        #endif
        if chartDescriptor == nil {
            chartDescriptor = child.chartDescriptor
        }
        #if !os(macOS)
        if tableContext == nil {
            tableContext = child.tableContext
        }
        #endif
        if locale == nil {
            locale = child.locale
        }
        if bridgedElement == nil {
            bridgedElement = child.bridgedElement
        }
        if childBehaviorKind == nil {
            childBehaviorKind = child.childBehaviorKind
        }
        if temporalState == nil {
            temporalState = child.temporalState
        }
        if automationVisibility == nil {
            automationVisibility = child.automationVisibility
        }
        return true
    }
}

// MARK: - AccessibilityAttachment + AccessibilityCombinable

extension AccessibilityAttachment: AccessibilityCombinable {
    package static func combine(_ children: [AccessibilityAttachment]) -> AccessibilityAttachment {
        guard var result = children.last else {
            return AccessibilityAttachment()
        }
        for child in children.dropLast().reversed() {
            result.merge(with: child)
        }
        return result
    }

    @discardableResult
    package mutating func merge(with child: AccessibilityAttachment) -> Bool {
        var changed = properties.merge(with: child.properties)
        if platformElement == nil, let element = child.platformElement {
            platformElement = element
            changed = true
        }
        return changed
    }
}

// MARK: - AccessibilityProperties + Keys

extension AccessibilityProperties {
    struct AutomationVisibilityKey: AccessibilityOptionalPropertiesKey {
        static let valueType = AccessibilityVisibilityStorage.self
    }

    var automationVisibility: AccessibilityVisibilityStorage? {
        get { self[AutomationVisibilityKey.self] }
        set { self[AutomationVisibilityKey.self] = newValue }
    }

    #if os(macOS)
    struct FocusViewItemIDKey: AccessibilityOptionalPropertiesKey {
        static let valueType = ViewIdentity.self
    }

    var focusViewItemID: ViewIdentity? {
        get { self[FocusViewItemIDKey.self] }
        set { self[FocusViewItemIDKey.self] = newValue }
    }

    struct FocusViewElementKey: AccessibilityOptionalPropertiesKey {
        static let valueType = PlatformAccessibilityElement.self
    }

    var focusViewElement: PlatformAccessibilityElement? {
        get { self[FocusViewElementKey.self] }
        set { self[FocusViewElementKey.self] = newValue }
    }

    struct AutoInteractableKey: AccessibilityOptionalPropertiesKey {
        static let valueType = Bool.self
    }

    var autoInteractable: Bool? {
        get { self[AutoInteractableKey.self] }
        set { self[AutoInteractableKey.self] = newValue }
    }
    #endif

    struct TemporalState: AccessibilityOptionalPropertiesKey {
        static let valueType = StrongHash.self
    }

    var temporalState: StrongHash? {
        get { self[TemporalState.self] }
        set { self[TemporalState.self] = newValue }
    }

    struct BridgedElementKey: AccessibilityOptionalPropertiesKey {
        static let valueType = PlatformAccessibilityElement.self
    }

    var bridgedElement: PlatformAccessibilityElement? {
        get { self[BridgedElementKey.self] }
        set { self[BridgedElementKey.self] = newValue }
    }

    struct TableContextKey: AccessibilityOptionalPropertiesKey {
        static let valueType = AccessibilityTableContext.self
    }

    var tableContext: AccessibilityTableContext? {
        get { self[TableContextKey.self] }
        set { self[TableContextKey.self] = newValue }
    }

    struct ImagesKey: AccessibilityPropertiesKey {
        static let defaultValue: [Image] = []
    }

    var images: [Image] {
        get { self[ImagesKey.self] }
        set { self[ImagesKey.self] = newValue }
    }

    struct RotorInfoKey: AccessibilityPropertiesKey {
        static var defaultValue: [AccessibilityRotorInfo] { [] }

        static func isDefault(_ value: [AccessibilityRotorInfo]) -> Bool {
            value.isEmpty
        }
    }

    var rotorInfo: [AccessibilityRotorInfo] {
        get { self[RotorInfoKey.self] }
        set { self[RotorInfoKey.self] = newValue }
    }

    struct TouchInfoKey: AccessibilityOptionalPropertiesKey {
        static let valueType = AccessibilityTouchInfo.self
    }

    var touchInfo: AccessibilityTouchInfo? {
        get { self[TouchInfoKey.self] }
        set { self[TouchInfoKey.self] = newValue }
    }

    struct ScrollableContextKey: AccessibilityOptionalPropertiesKey {
        static let valueType = AccessibilityScrollableContext.self
    }

    var scrollableContext: AccessibilityScrollableContext? {
        get { self[ScrollableContextKey.self] }
        set { self[ScrollableContextKey.self] = newValue }
    }

    struct ScrollableCollectionKey: AccessibilityOptionalPropertiesKey {
        static let valueType = (any ScrollableCollection).self
    }

    var scrollableCollection: (any ScrollableCollection)? {
        get { self[ScrollableCollectionKey.self] }
        set { self[ScrollableCollectionKey.self] = newValue }
    }

    struct ActionsKey: AccessibilityPropertiesKey {
        static let defaultValue: [AnyAccessibilityAction] = []
    }

    var actions: [AnyAccessibilityAction] {
        get { self[ActionsKey.self] }
        set { self[ActionsKey.self] = newValue }
    }

    struct TextLayoutPropertiesKey: AccessibilityOptionalPropertiesKey {
        static let valueType = AccessibilityTextLayoutProperties.self
    }

    var textLayoutProperties: AccessibilityTextLayoutProperties? {
        get { self[TextLayoutPropertiesKey.self] }
        set { self[TextLayoutPropertiesKey.self] = newValue }
    }
}
