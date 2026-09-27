//
//  AccessibilityProperties+Keys.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: WIP

package import Foundation

// MARK: - AccessibilityProperties + Keys

extension AccessibilityProperties {
    package struct ActivationPointKey: AccessibilityOptionalPropertiesKey {
        package static let valueType = AccessibilityActivationPointStorage.self
    }

    package var activationPointStorage: AccessibilityActivationPointStorage? {
        get { self[ActivationPointKey.self] }
        set { self[ActivationPointKey.self] = newValue }
    }

    package var activationPoint: AccessibilityActivationPoint.Location? {
        activationPointStorage?.activate
    }

    // TODO: Add AccessibilityChartDescriptorStorage.
    #if false
    package struct ChartDescriptorKey: AccessibilityOptionalPropertiesKey {
        package static let valueType = AccessibilityChartDescriptorStorage.self
    }

    package var chartDescriptor: AccessibilityChartDescriptorStorage? {
        get { self[ChartDescriptorKey.self] }
        set { self[ChartDescriptorKey.self] = newValue }
    }
    #endif

    package struct ChildBehaviorKind: AccessibilityOptionalPropertiesKey {
        package static let valueType = AccessibilityChildBehaviorKind.self
    }

    package var childBehaviorKind: AccessibilityChildBehaviorKind? {
        get { self[ChildBehaviorKind.self] }
        set { self[ChildBehaviorKind.self] = newValue }
    }

    // TODO: Add AccessibilityCustomContentList.
    #if false
    package struct CustomContentListKey: AccessibilityPropertiesKey {
        package static let defaultValue: AccessibilityCustomContentList = []
    }

    package var customContentList: AccessibilityCustomContentList {
        get { self[CustomContentListKey.self] }
        set { self[CustomContentListKey.self] = newValue }
    }
    #endif

    // TODO: Add AccessibilityCustomAttributes.
    #if false
    package struct CustomAttributesKey: AccessibilityOptionalPropertiesKey {
        package static let valueType = AccessibilityCustomAttributes.self
    }

    package var customAttributes: AccessibilityCustomAttributes? {
        get { self[CustomAttributesKey.self] }
        set { self[CustomAttributesKey.self] = newValue }
    }
    #endif

    // TODO: Add AccessibilityDataSeriesConfiguration.
    #if false
    package struct DataSeriesConfigurationKey: AccessibilityOptionalPropertiesKey {
        package static let valueType = AccessibilityDataSeriesConfiguration.self
    }

    package var dataSeriesConfiguration: AccessibilityDataSeriesConfiguration? {
        get { self[DataSeriesConfigurationKey.self] }
        set { self[DataSeriesConfigurationKey.self] = newValue }
    }
    #endif

    // TODO: Add AXAutomationType.
    #if false
    package struct AutomationTypeKey: AccessibilityOptionalPropertiesKey {
        package static let valueType = AXAutomationType.self
    }

    package var explicitAutomationType: AXAutomationType? {
        get { self[AutomationTypeKey.self] }
        set { self[AutomationTypeKey.self] = newValue }
    }
    #endif

    package struct IdentifierKey: AccessibilityOptionalPropertiesKey {
        package static let valueType = AccessibilityIdentifierStorage.self
    }

    package var identifierStorage: AccessibilityIdentifierStorage? {
        get { self[IdentifierKey.self] }
        set { self[IdentifierKey.self] = newValue }
    }

    package struct HintsKey: AccessibilityPropertiesKey {
        package static let defaultValue: [Text] = []
    }

    package var hints: [Text] {
        get { self[HintsKey.self] }
        set { self[HintsKey.self] = newValue }
    }

    package struct InputLabelsKey: AccessibilityOptionalPropertiesKey {
        package static let valueType = [Text].self
    }

    package var inputLabels: [Text]? {
        get { self[InputLabelsKey.self] }
        set { self[InputLabelsKey.self] = newValue }
    }

    package struct LabelKey: AccessibilityOptionalPropertiesKey {
        package static let valueType = AccessibilityLabelStorage.self
    }

    package var labelStorage: AccessibilityLabelStorage? {
        get { self[LabelKey.self] }
        set { self[LabelKey.self] = newValue }
    }

    package struct LocaleKey: AccessibilityOptionalPropertiesKey {
        package static let valueType = Locale.self
    }

    package var locale: Locale? {
        get { self[LocaleKey.self] }
        set { self[LocaleKey.self] = newValue }
    }

    // TODO: Add LinkDestination in OpenSwiftUICore.
    #if false
    package struct LinkDestinationKey: AccessibilityOptionalPropertiesKey {
        package static let valueType = LinkDestination.Configuration.self
    }

    package var linkDestination: LinkDestination.Configuration? {
        get { self[LinkDestinationKey.self] }
        set { self[LinkDestinationKey.self] = newValue }
    }
    #endif

    package struct RoleDescriptionKey: AccessibilityOptionalPropertiesKey {
        package static let valueType = Text.self
    }

    package var roleDescription: Text? {
        get { self[RoleDescriptionKey.self] }
        set { self[RoleDescriptionKey.self] = newValue }
    }

    package struct SortPriorityKey: AccessibilityOptionalPropertiesKey {
        package static let valueType = Double.self
    }

    package var sortPriority: Double? {
        get { self[SortPriorityKey.self] }
        set { self[SortPriorityKey.self] = newValue }
    }

    package struct TextContentTypeKey: AccessibilityOptionalPropertiesKey {
        package static let valueType = AccessibilityTextContentType.self
    }

    package var textContentType: AccessibilityTextContentType? {
        get { self[TextContentTypeKey.self] }
        set { self[TextContentTypeKey.self] = newValue }
    }

    package struct TextHeadingLevelKey: AccessibilityOptionalPropertiesKey {
        package static let valueType = AccessibilityHeadingLevel.self
    }

    package var textHeadingLevel: AccessibilityHeadingLevel? {
        get { self[TextHeadingLevelKey.self] }
        set { self[TextHeadingLevelKey.self] = newValue }
    }

    package struct TraitsKey: AccessibilityPropertiesKey {
        package static let defaultValue: AccessibilityTraitStorage = .init()
    }

    package var traits: AccessibilityTraitStorage {
        get { self[TraitsKey.self] }
        set { self[TraitsKey.self] = newValue }
    }

    package subscript(trait trait: AccessibilityTrait) -> Bool? {
        get { traits[trait] }
        set { traits[trait] = newValue }
    }

    package subscript(trait trait: AccessibilityTrait, default defaultValue: Bool) -> Bool {
        traits[trait, default: defaultValue]
    }

    package struct ValueKey: AccessibilityOptionalPropertiesKey {
        package static let valueType = AccessibilityValueStorage.self
    }

    package var value: AccessibilityValueStorage? {
        get { self[ValueKey.self] }
        set { self[ValueKey.self] = newValue }
    }

    package struct VisibilityKey: AccessibilityPropertiesKey {
        package static let defaultValue: AccessibilityVisibilityStorage = .init()
    }

    package var visibility: AccessibilityVisibilityStorage {
        get { self[VisibilityKey.self] }
        set { self[VisibilityKey.self] = newValue }
    }
}
