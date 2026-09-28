//
//  AccessibilityNodeAttachment.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: E6F55EC17684DEB3593A96D781D9FC84 (SwiftUICore)

import libAccessibilityPrivate
import Foundation

// MARK: - AccessibilityNodeAttachment

package struct AccessibilityNodeAttachment {
    package enum Storage {
        case codable(CodableAccessibilityAttachmentStorage)
        case attachment(AccessibilityAttachment)
    }

    package enum Kind: Codable, Hashable {
        case standard
        case placeholder
    }

    package var storage: Storage
    package var createsNode: Bool
    package var kind: Kind

    package func makeAttachment<A>(with applicator: A.Type) -> AccessibilityAttachment
    where A: AccessibilityPlatformPropertyApplicator {
        switch storage {
        case let .codable(storage):
            AccessibilityAttachment(storage, applicator: applicator)
        case let .attachment(attachment):
            attachment
        }
    }

    package init(
        _ attachment: AccessibilityAttachment,
        platformStorage: AccessibilityPlatformPropertyStorage,
        in environment: EnvironmentValues,
        idiom: AnyInterfaceIdiom,
        createsNode: Bool,
        kind: Kind,
        encode: Bool
    ) {
        storage = encode ? .codable(CodableAccessibilityAttachmentStorage(
            attachment,
            platformStorage: platformStorage,
            in: environment,
            idiom: idiom
        )) : .attachment(attachment)
        self.createsNode = createsNode
        self.kind = kind
    }
}

extension AccessibilityNodeAttachment: ProtobufMessage {
    private enum Error: Swift.Error {
        case invalidStorage
    }

    package func encode(to encoder: inout ProtobufEncoder) throws {
        guard case let .codable(storage) = storage else {
            throw Error.invalidStorage
        }
        try encoder.messageField(1, storage)
        encoder.boolField(2, createsNode)
        if encoder.archiveOptions.deploymentVersion < .v6 {
            try encoder.codableField(3, kind)
        } else {
            encoder.enumField(4, kind)
        }
    }

    package init(from decoder: inout ProtobufDecoder) throws {
        var storage: CodableAccessibilityAttachmentStorage?
        createsNode = false
        kind = .standard
        while let field = try decoder.nextField() {
            switch field.tag {
            case 1: storage = try decoder.messageField(field)
            case 2: createsNode = try decoder.boolField(field)
            case 3: kind = try decoder.codableField(field) ?? .standard
            case 4: kind = try decoder.enumField(field) ?? .standard
            default: try decoder.skipField(field)
            }
        }
        guard let storage else {
            throw ProtobufDecoder.DecodingError.failed
        }
        self.storage = .codable(storage)
    }
}

extension AccessibilityNodeAttachment.Kind: ProtobufEnum {
    package var protobufValue: UInt {
        switch self {
        case .standard: 0
        case .placeholder: 1
        }
    }

    package init?(protobufValue value: UInt) {
        switch value {
        case 0: self = .standard
        case 1: self = .placeholder
        default: return nil
        }
    }
}

// MARK: - AccessibilityPlatformPropertyStorage

package struct AccessibilityPlatformPropertyStorage {
    package var explicitRole: String?
    package var explicitSubrole: String?
    package var explicitTraits: CodableAccessibilityUIKitTraits?

    package init(
        explicitRole: String? = nil,
        explicitSubrole: String? = nil,
        explicitTraits: CodableAccessibilityUIKitTraits? = nil
    ) {
        self.explicitRole = explicitRole
        self.explicitSubrole = explicitSubrole
        self.explicitTraits = explicitTraits
    }
}

package protocol AccessibilityPlatformPropertyApplicator {
    static func apply(_ storage: AccessibilityPlatformPropertyStorage, to properties: inout AccessibilityProperties)
}

// MARK: - CodableAccessibilityAttachmentStorage

package struct CodableAccessibilityAttachmentStorage: ProtobufMessage {
    package struct VBase {
        var identifier: String?
        var label: CodableAccessibilityVersionStorage<CodableResolvedStyledText, AccessibilityText>?
        var hint: CodableAccessibilityVersionStorage<CodableResolvedStyledText, AccessibilityText>?
        var roleDescription: CodableAccessibilityVersionStorage<CodableResolvedStyledText, AccessibilityText>?
        var visibility: AccessibilityNullableOptionSet<AccessibilityVisibility>
        var traits: AccessibilityNullableOptionSet<AccessibilityTraitSet>
        var sortPriority: Double?
        var explicitAutomationType: AXAutomationType?
        var dataSeriesConfiguration: CodableAccessibilityDataSeriesConfiguration?
        var linkDestination: LinkDestination.Configuration?
        var customAttributes: AccessibilityCustomAttributes?
    }

    package struct V2 {
        var base: VBase
        var textValue: ResolvedStyledText?
    }

    package struct V3 {
        var base: VBase
        var platformStorage: AccessibilityPlatformPropertyStorage = .init()
        var value: CodableAccessibilityValueStorage?
        var inputLabels: [AccessibilityText]?
        var activationPoint: AccessibilityActivationPoint.Location?
        var customContentList: CodableAccessibilityCustomContentList?
        var textHeadingLevel: AccessibilityHeadingLevel?
        var textContentType: AccessibilityTextContentType?
        var chartDescriptor: CodableAXChartDescriptor?
        var locale: String?
        var childBehaviorKind: AccessibilityChildBehaviorKind?
    }

    var base: CodableAccessibilityVersionStorage<V2, V3>

    package init(
        _ attachment: AccessibilityAttachment,
        platformStorage: AccessibilityPlatformPropertyStorage,
        in environment: EnvironmentValues,
        idiom: AnyInterfaceIdiom
    ) {
        let properties = attachment.properties
        let base = VBase(
            identifier: properties.identifierStorage.flatMap {
                $0.placement == .optional ? nil : $0.value
            },
            label: .init(
                texts: properties.labelStorage?.texts,
                in: environment,
                optional: properties.labelStorage?.placement == .optional,
                idiom: idiom
            ),
            hint: .init(texts: properties.hints, in: environment, optional: false, idiom: idiom),
            roleDescription: .init(
                texts: properties.roleDescription.map { [$0] },
                in: environment,
                optional: false,
                idiom: idiom
            ),
            visibility: properties.visibility,
            traits: properties.traits,
            sortPriority: properties.sortPriority,
            explicitAutomationType: properties.explicitAutomationType,
            dataSeriesConfiguration: properties.dataSeriesConfiguration.map {
                CodableAccessibilityDataSeriesConfiguration($0, in: environment)
            },
            linkDestination: properties.linkDestination,
            customAttributes: properties.customAttributes
        )
        switch CodableAccessibilityVersion.current {
        case .v2:
            let textValue: ResolvedStyledText? = {
                guard let value = properties.value else {
                    return nil
                }
                let texts = value.description.text
                guard let storage = AccessibilityCore.textsResolvedToAttributedText(
                    texts,
                    in: environment,
                    includeResolvableAttributes: false,
                    includeDefaultAttributes: true,
                    updateResolvableAttributes: false,
                    resolveSuffix: false,
                    idiom: nil
                ) else {
                    return nil
                }
                return ResolvedStyledText.styledText(
                    storage: storage,
                    environment: environment,
                    isCollapsible: texts.contains { $0.isCollapsible() },
                    writingMode: nil
                )
            }()
            self.base = .v2(V2(base: base, textValue: textValue))
        case .v3:
            self.base = .v3(V3(
                base: base,
                platformStorage: platformStorage,
                value: properties.value.map {
                    CodableAccessibilityValueStorage($0, in: environment, idiom: idiom)
                },
                inputLabels: properties.inputLabels?.compactMap {
                    AccessibilityText($0, environment: environment)
                },
                activationPoint: properties.activationPoint,
                customContentList: properties.customContentList.isEmpty ? nil :
                    CodableAccessibilityCustomContentList(properties.customContentList, in: environment),
                textHeadingLevel: properties.textHeadingLevel,
                textContentType: properties.textContentType,
                chartDescriptor: properties.chartDescriptor.map { CodableAXChartDescriptor($0) },
                locale: environment.locale.identifier,
                childBehaviorKind: properties.childBehaviorKind
            ))
        }
    }

    package func encode(to encoder: inout ProtobufEncoder) throws {
        try base.encode(to: &encoder)
    }

    package init(from decoder: inout ProtobufDecoder) throws {
        base = try CodableAccessibilityVersionStorage(from: &decoder)
    }
}

extension CodableAccessibilityAttachmentStorage.VBase: ProtobufMessage {
    package func encode(to encoder: inout ProtobufEncoder) throws {
        if let identifier { try encoder.stringField(1, identifier) }
        if let label { try encoder.messageField(2, label) }
        if let hint { try encoder.messageField(3, hint) }
        if let roleDescription { try encoder.messageField(4, roleDescription) }
        try encoder.messageField(5, visibility)
        try encoder.messageField(6, traits)
        if let sortPriority { encoder.doubleField(7, sortPriority, defaultValue: nil) }
        if let explicitAutomationType {
            encoder.fixed64Field(8, explicitAutomationType.rawValue, defaultValue: nil)
        }
        if let dataSeriesConfiguration { try encoder.codableField(9, dataSeriesConfiguration) }
        if let linkDestination { try encoder.codableField(10, linkDestination) }
        if let customAttributes { try encoder.codableField(11, customAttributes) }
    }

    package init(from decoder: inout ProtobufDecoder) throws {
        var visibility: AccessibilityNullableOptionSet<AccessibilityVisibility>?
        var traits: AccessibilityNullableOptionSet<AccessibilityTraitSet>?
        while let field = try decoder.nextField() {
            switch field.tag {
            case 1: identifier = try decoder.stringField(field)
            case 2: label = try decoder.messageField(field)
            case 3: hint = try decoder.messageField(field)
            case 4: roleDescription = try decoder.messageField(field)
            case 5: visibility = try decoder.messageField(field)
            case 6: traits = try decoder.messageField(field)
            case 7: sortPriority = try decoder.doubleField(field)
            case 8: explicitAutomationType = AXAutomationType(rawValue: try decoder.fixed64Field(field))
            case 9: dataSeriesConfiguration = .some(try decoder.codableField(field))
            case 10: linkDestination = .some(try decoder.codableField(field))
            case 11: customAttributes = .some(try decoder.codableField(field))
            default: try decoder.skipField(field)
            }
        }
        guard let visibility, let traits else {
            throw ProtobufDecoder.DecodingError.failed
        }
        self.visibility = visibility
        self.traits = traits
    }
}

extension CodableAccessibilityAttachmentStorage.V2: ProtobufMessage {
    package func encode(to encoder: inout ProtobufEncoder) throws {
        try encoder.messageField(1, base)
        if let textValue {
            try encoder.messageField(2, CodableResolvedStyledText(base: textValue))
        }
    }

    package init(from decoder: inout ProtobufDecoder) throws {
        var base: CodableAccessibilityAttachmentStorage.VBase?
        while let field = try decoder.nextField() {
            switch field.tag {
            case 1: base = try decoder.messageField(field)
            case 2:
                let value: CodableResolvedStyledText = try decoder.messageField(field)
                textValue = value.base
            default: try decoder.skipField(field)
            }
        }
        guard let base else {
            throw ProtobufDecoder.DecodingError.failed
        }
        self.base = base
    }
}

extension CodableAccessibilityAttachmentStorage.V3: ProtobufMessage {
    package func encode(to encoder: inout ProtobufEncoder) throws {
        try encoder.messageField(1, base)
        if let value { try encoder.codableField(2, value) }
        if let inputLabels {
            for label in inputLabels {
                try encoder.messageField(3, label)
            }
        }
        if let activationPoint { try encoder.messageField(4, activationPoint) }
        if let customContentList { try encoder.codableField(5, customContentList) }
        if let textContentType { encoder.enumField(6, textContentType) }
        if let role = platformStorage.explicitRole { try encoder.stringField(7, role) }
        if let subrole = platformStorage.explicitSubrole { try encoder.stringField(8, subrole) }
        if let chartDescriptor { try encoder.codableField(9, chartDescriptor) }
        if let locale { try encoder.stringField(10, locale) }
        if let traits = platformStorage.explicitTraits { try encoder.messageField(11, traits) }
        if let textHeadingLevel { encoder.enumField(12, textHeadingLevel) }
        if let childBehaviorKind {
            if encoder.archiveOptions.deploymentVersion < .v6 {
                try encoder.codableField(13, childBehaviorKind)
            } else {
                encoder.enumField(14, childBehaviorKind)
            }
        }
    }

    package init(from decoder: inout ProtobufDecoder) throws {
        var base: CodableAccessibilityAttachmentStorage.VBase?
        while let field = try decoder.nextField() {
            switch field.tag {
            case 1: base = try decoder.messageField(field)
            case 2: value = .some(try decoder.codableField(field))
            case 3:
                let label: AccessibilityText = try decoder.messageField(field)
                if inputLabels == nil { inputLabels = [] }
                inputLabels?.append(label)
            case 4: activationPoint = try decoder.messageField(field)
            case 5: customContentList = .some(try decoder.codableField(field))
            case 6: textContentType = try decoder.enumField(field)
            case 7: platformStorage.explicitRole = try decoder.stringField(field)
            case 8: platformStorage.explicitSubrole = try decoder.stringField(field)
            case 9: chartDescriptor = .some(try decoder.codableField(field))
            case 10: locale = try decoder.stringField(field)
            case 11: platformStorage.explicitTraits = try decoder.messageField(field)
            case 12: textHeadingLevel = try decoder.enumField(field)
            case 13: childBehaviorKind = try decoder.codableField(field)
            case 14: childBehaviorKind = try decoder.enumField(field)
            default: try decoder.skipField(field)
            }
        }
        guard let base else {
            throw ProtobufDecoder.DecodingError.failed
        }
        self.base = base
    }
}

// MARK: - AccessibilityAttachment + CodableAccessibilityAttachmentStorage

extension AccessibilityAttachment {
    package init<A>(_ storage: CodableAccessibilityAttachmentStorage, applicator: A.Type)
    where A: AccessibilityPlatformPropertyApplicator {
        var properties = AccessibilityProperties()
        let base: CodableAccessibilityAttachmentStorage.VBase
        switch storage.base {
        case let .v2(storage):
            base = storage.base
            properties.value = storage.textValue.map {
                AccessibilityValueStorage(description: $0.accessibilityText)
            }
        case let .v3(storage):
            base = storage.base
            properties.value = storage.value?.accessibilityValue
            properties.inputLabels = storage.inputLabels?.map { $0.text } ?? []
            properties.activationPointStorage = storage.activationPoint.map {
                AccessibilityActivationPointStorage(kind: .activate, point: $0)
            }
            properties.customContentList = storage.customContentList?.customContentList ?? []
            properties.textHeadingLevel = storage.textHeadingLevel
            properties.textContentType = storage.textContentType
            properties.chartDescriptor = storage.chartDescriptor?.storage
            properties.locale = storage.locale.map { Locale(identifier: $0) }
            properties.childBehaviorKind = storage.childBehaviorKind
            A.apply(storage.platformStorage, to: &properties)
        }
        properties.labelStorage = base.label.map { label in
            let placement: AccessibilityLabelStorage.Placement
            if case let .v3(text) = label, text.optional {
                placement = .optional
            } else {
                placement = .assign
            }
            return AccessibilityLabelStorage(texts: [label.text], placement: placement)
        }
        properties.hints = base.hint.map { [$0.text] } ?? []
        properties.identifierStorage = base.identifier.map { AccessibilityIdentifierStorage($0) }
        properties.visibility = base.visibility
        properties.traits = base.traits
        properties.sortPriority = base.sortPriority
        properties.explicitAutomationType = base.explicitAutomationType
        properties.roleDescription = base.roleDescription?.text
        properties.dataSeriesConfiguration = base.dataSeriesConfiguration?.configuration
        properties.linkDestination = base.linkDestination
        properties.customAttributes = base.customAttributes
        self.init(properties: properties)
    }
}

// MARK: - CodableAccessibilityUIKitTraits

package struct CodableAccessibilityUIKitTraits {
    package var removed: UInt64
    package var added: UInt64

    package init(removed: UInt64 = 0, added: UInt64 = 0) {
        self.removed = removed
        self.added = added
    }
}

extension CodableAccessibilityUIKitTraits: ProtobufMessage {
    package func encode(to encoder: inout ProtobufEncoder) throws {
        encoder.fixed64Field(1, removed)
        encoder.fixed64Field(2, added)
    }

    package init(from decoder: inout ProtobufDecoder) throws {
        self.init()
        while let field = try decoder.nextField() {
            switch field.tag {
            case 1: removed = try decoder.fixed64Field(field)
            case 2: added = try decoder.fixed64Field(field)
            default: try decoder.skipField(field)
            }
        }
    }
}

// MARK: - CodableAccessibilityVersion

enum CodableAccessibilityVersion: Sendable {
    case v2
    case v3

    static let current: CodableAccessibilityVersion = Semantics.AccessibilityCodableVersion3.isEnabled ? .v3 : .v2
}

// MARK: - CodableAccessibilityVersionStorage

enum CodableAccessibilityVersionStorage<V2: ProtobufMessage, V3: ProtobufMessage> {
    case v2(V2)
    case v3(V3)
}

extension CodableAccessibilityVersionStorage: CodableByProtobuf {}

extension CodableAccessibilityVersionStorage: ProtobufMessage {
    func encode(to encoder: inout ProtobufEncoder) throws {
        switch self {
        case let .v2(value): try encoder.messageField(2, value)
        case let .v3(value): try encoder.messageField(3, value)
        }
    }

    init(from decoder: inout ProtobufDecoder) throws {
        var value: Self?
        while let field = try decoder.nextField() {
            switch field.tag {
            case 2: value = .v2(try decoder.messageField(field))
            case 3: value = .v3(try decoder.messageField(field))
            default: try decoder.skipField(field)
            }
        }
        guard let value else {
            throw ProtobufDecoder.DecodingError.failed
        }
        self = value
    }
}
