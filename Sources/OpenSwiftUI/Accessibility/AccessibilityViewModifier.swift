//
//  AccessibilityViewModifier.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete (TBA)
//  ID: 71F62EDC1DAE3BBC7A74521E45BA5A66 (SwiftUI)

import OpenAttributeGraphShims
import OpenCoreGraphicsShims
@_spi(ForOpenSwiftUIOnly)
import OpenSwiftUICore

// MARK: - AccessibilityViewModifier

protocol AccessibilityViewModifier: MultiViewModifier, PrimitiveViewModifier {
    static var options: AccessibilityModifierOptions { get }

    func willCreateNode(for nodes: [AccessibilityNode]) -> Bool

    func initialAttachment(for nodes: [AccessibilityNode]) -> AccessibilityAttachment

    func updatedAttachment(
        for token: AccessibilityAttachmentToken,
        nodes: [AccessibilityNode],
        atIndex index: Int
    ) -> AccessibilityAttachment

    func createOrUpdateNode(
        viewRendererHost: (any ViewRendererHost)?,
        existingNode: AccessibilityNode?
    ) -> AccessibilityNode

    static func makeAccessibilityViewModifier(
        modifier: _GraphValue<Self>,
        inputs: _ViewInputs,
        body: @escaping (_Graph, _ViewInputs) -> _ViewOutputs
    ) -> _ViewOutputs

    var supportsPlaceholders: Bool { get }
}

extension AccessibilityViewModifier {
    func updatedAttachment(
        for token: AccessibilityAttachmentToken,
        nodes: [AccessibilityNode],
        atIndex index: Int
    ) -> AccessibilityAttachment {
        AccessibilityAttachment()
    }

    static func configureInputsForGeometry(_ inputs: inout _ViewInputs) {
        guard inputs.needsGeometry,
              options.contains(.geometry),
              inputs.preferences.requiresAccessibilityNodes else {
            return
        }
        if inputs.needsAccessibilityGeometry {
            inputs.needsAccessibilityGeometry = false
        }
        if inputs.needsAccessibilityViewResponders {
            inputs.preferences.add(ViewRespondersKey.self)
        }
    }

    nonisolated public static func _makeView(
        modifier: _GraphValue<Self>,
        inputs: _ViewInputs,
        body: @escaping (_Graph, _ViewInputs) -> _ViewOutputs
    ) -> _ViewOutputs {
        if inputs.preferences.requiresAccessibilityNodes {
            var childInputs = inputs
            configureInputsForGeometry(&childInputs)
            if inputs.needsDisplayListAccessibility {
                childInputs.containerPosition = inputs.animatedPosition()
            }
            let scrapeableID: ScrapeableID
            if options.contains(.scrapeable), inputs.isScrapeable {
                scrapeableID = .init()
                childInputs.scrapeableParentID = scrapeableID
            } else {
                scrapeableID = .none
            }
            var outputs = makeAccessibilityViewModifier(
                modifier: modifier,
                inputs: childInputs,
                body: body
            )
            if inputs.needsDisplayListAccessibility {
                let deferredAttachment = inputs.preferences.contains(AccessibilityAttachment.Key.self)
                    ? outputs[AccessibilityAttachment.Key.self] : nil
                let identity = DisplayList.Identity()
                inputs.pushIdentity(identity)
                outputs.displayList = Attribute(DisplayListTransform(
                    identity: identity,
                    archivable: inputs.archivedView.isArchived,
                    idiom: inputs.base.interfaceIdiom,
                    options: inputs[DisplayList.Options.self],
                    modifier: modifier.value,
                    size: inputs.animatedSize(),
                    position: inputs.animatedPosition(),
                    containerPosition: inputs.containerPosition,
                    environment: inputs.environment,
                    content: .init(outputs.displayList),
                    deferredAttachment: .init(deferredAttachment),
                    nodeList: .init(outputs.accessibilityNodes)
                ))
            }
            let nodes = makePropertiesTransform(
                modifier: modifier,
                inputs: inputs,
                outputs: outputs,
                scrapeableID: scrapeableID
            )
            outputs.accessibilityNodes = nodes
            if options.contains(.geometry) {
                outputs.accessibilityNodes = makeAccessibilityGeometryTransform(
                    for: nodes,
                    kind: nil,
                    inputs: inputs,
                    outputs: outputs
                )
            }
            return outputs
        } else {
            var outputs: _ViewOutputs
            if inputs.preferences.requiresPlatformItemList,
               inputs.preferences.contains(AccessibilityAttachment.Key.self),
               inputs.platformItemListFlags.contains(.accessibility) {
                var childInputs = inputs
                childInputs.platformItemListFlags.remove(.accessibility)
                outputs = makeAccessibilityViewModifier(modifier: modifier, inputs: inputs, body: body)
                let deferredAttachment = outputs[AccessibilityAttachment.Key.self]
                outputs.transformPlatformItemList(
                    inputs: inputs,
                    transform: Attribute(PlatformItemListTransform(
                        deferredAttachment: .init(deferredAttachment),
                        environment: inputs.environment
                    ))
                )
            } else {
                outputs = makeAccessibilityViewModifier(modifier: modifier, inputs: inputs, body: body)
            }
            if inputs.preferences.requiresPlatformItems,
               inputs.platformItemFeatures.contains(.accessibility) {
                let environment = Attribute(PlatformAccessibilityEnv(
                    environment: inputs.environment,
                    tracker: .init()
                ))
                let content = Attribute(PlatformAccessibilityContent(
                    deferredAttachment: .init(outputs[AccessibilityAttachment.Key.self]),
                    environment: environment
                ))
                let transform = Attribute(MakePlatformTransform(content: content))
                AccessibilityPlatformItemTransform.transformPlatformItemsOutputs(
                    &outputs,
                    inputs: inputs,
                    modifier: _GraphValue(transform)
                )
            }
            return outputs
        }
    }

    private static func makePropertiesTransform(
        modifier: _GraphValue<Self>,
        inputs: _ViewInputs,
        outputs: _ViewOutputs,
        scrapeableID: ScrapeableID
    ) -> Attribute<AccessibilityNodeList> {
        let deferredAttachment = inputs.preferences.contains(AccessibilityAttachment.Key.self)
            ? outputs[AccessibilityAttachment.Key.self] : nil
        let attribute = Attribute(PropertiesTransform(
            modifier: modifier.value,
            position: inputs.position,
            size: inputs.size,
            transform: inputs.transform,
            environment: inputs.environment,
            phase: inputs.viewPhase,
            localID: scrapeableID,
            parentID: inputs.scrapeableParentID,
            deferredAttachment: .init(deferredAttachment),
            nodeList: .init(outputs.accessibilityNodes),
            idiom: inputs.base.interfaceIdiom,
            isInPlatformItemList: !inputs.needsGeometry
        ))
        attribute.flags = .removable
        if scrapeableID != .none {
            attribute.flags.insert(.scrapeable)
        }
        return attribute
    }
}

// MARK: - AccessibilityModifierOptions

struct AccessibilityModifierOptions: OptionSet {
    var rawValue: UInt32

    static let geometry = AccessibilityModifierOptions(rawValue: 1 << 0)
    static let scrapeable = AccessibilityModifierOptions(rawValue: 1 << 1)
}

// MARK: - AnyAccessibilityViewModifier

class AnyAccessibilityViewModifier {
    func willCreateNode(for nodes: [AccessibilityNode]) -> Bool {
        _openSwiftUIBaseClassAbstractMethod()
    }

    func initialAttachment(for nodes: [AccessibilityNode]) -> AccessibilityAttachment {
        _openSwiftUIBaseClassAbstractMethod()
    }

    func updatedAttachment(
        for token: AccessibilityAttachmentToken,
        nodes: [AccessibilityNode],
        atIndex index: Int
    ) -> AccessibilityAttachment {
        _openSwiftUIBaseClassAbstractMethod()
    }

    func isEqual(to other: AnyAccessibilityViewModifier) -> Bool {
        _openSwiftUIBaseClassAbstractMethod()
    }

    func hash(into hasher: inout Hasher) {
        _openSwiftUIBaseClassAbstractMethod()
    }

    func visibility(
        for token: AccessibilityAttachmentToken,
        nodes: [AccessibilityNode]
    ) -> AccessibilityNullableOptionSet<AccessibilityVisibility> {
        _openSwiftUIBaseClassAbstractMethod()
    }
}

// MARK: - ArchivableAccessibilityViewModifier

struct ArchivableAccessibilityViewModifier: _ArchivableViewModifier {
    fileprivate let attachment: AccessibilityArchivableViewAttachment

    func body(content: Content) -> some View {
        content.modifier(ArchivedAttachmentModifier(attachment: .init(properties: attachment.properties)))
    }

    fileprivate struct Factory: Codable, _DisplayList_ViewFactory {
        var attachment: AccessibilityArchivableViewAttachment
        var identity: DisplayList.Identity
        var size: CGSize

        func makeView() -> AnyView {
            AnyView(
                ArchivablePlaceholder(identity: identity, size: size)
                    .modifier(ArchivableAccessibilityViewModifier(attachment: attachment))
            )
        }

        var viewType: any Any.Type {
            ArchivableAccessibilityViewModifier.self
        }

        func encoding() -> (id: String, data: any Codable)? {
            (_typeName(ArchivableAccessibilityViewModifier.self), self)
        }
    }
}

// MARK: - PlatformItemListTransform

private struct PlatformItemListTransform: Rule, CustomStringConvertible {
    @OptionalAttribute var deferredAttachment: AccessibilityAttachment.Tree?
    @Attribute var environment: EnvironmentValues

    var value: (inout PlatformItemList) -> Void {
        guard environment.accessibilityEnabled, let deferredAttachment else {
            return { _ in _openSwiftUIEmptyStub() }
        }
        return { list in
            // TBA
            switch deferredAttachment {
            case let .leaf(attachment):
                if list.items.isEmpty {
                    list.items.append(.init(accessibility: .init(
                        properties: attachment.properties,
                        environment: environment
                    )))
                } else {
                    list.modify { item in
                        item.accessibility = .init(
                            properties: attachment.properties.combined(with: item.accessibility?.properties ?? .init()),
                            environment: item.accessibility?.environment ?? environment
                        )
                    }
                }
            case let .branch(children):
                if list.items.isEmpty {
                    var properties = AccessibilityProperties()
                    for child in children {
                        if let attachment = child.attachment {
                            properties.merge(with: attachment.properties)
                        }
                    }
                    list.items.append(.init(accessibility: .init(
                        properties: properties,
                        environment: environment
                    )))
                } else {
                    for index in list.items.indices {
                        guard children.indices.contains(index) else {
                            continue
                        }
                        let properties: AccessibilityProperties
                        switch children[index] {
                        case let .leaf(attachment):
                            properties = attachment.properties
                        case let .branch(children):
                            properties = AccessibilityChildBehavior.defaultCombine(
                                childProperties: children.compactMap { $0.attachment?.properties },
                                createsCustomActions: true
                            )
                        case .empty:
                            continue
                        }
                        list.items[index].accessibility = .init(
                            properties: properties.combined(with: list.items[index].accessibility?.properties ?? .init()),
                            environment: list.items[index].accessibility?.environment ?? environment
                        )
                    }
                }
            case .empty:
                break
            }
        }
    }

    var description: String {
        "AccessibilityPlatformItemListTransform"
    }
}

// MARK: - MakePlatformTransform

private struct MakePlatformTransform: Rule {
    @Attribute var content: PlatformItem.AccessibilityContent?

    var value: AccessibilityPlatformItemTransform {
        AccessibilityPlatformItemTransform(accessibility: content)
    }
}

// MARK: - PlatformAccessibilityContent

private struct PlatformAccessibilityContent: StatefulRule {
    @OptionalAttribute var deferredAttachment: AccessibilityAttachment.Tree?
    @Attribute var environment: EnvironmentValues

    typealias Value = PlatformItem.AccessibilityContent?

    mutating func updateValue() {
        let (environment, environmentChanged) = $environment.changedValue()
        guard environment.accessibilityEnabled else {
            value = nil
            return
        }
        let (deferredAttachment, attachmentChanged) = $deferredAttachment?.changedValue() ?? (.empty, false)
        let properties: AccessibilityProperties
        switch deferredAttachment {
        case let .leaf(attachment):
            properties = attachment.properties
        case let .branch(children):
            var mergedProperties = AccessibilityProperties()
            for child in children {
                if let attachment = child.attachment {
                    mergedProperties.merge(with: attachment.properties)
                }
            }
            properties = mergedProperties
        case .empty:
            value = nil
            return
        }
        if environmentChanged || attachmentChanged || !hasValue {
            value = .init(properties: properties, weakEnv: .init($environment))
        }
    }
}

// MARK: - PlatformAccessibilityEnv

private struct PlatformAccessibilityEnv: StatefulRule {
    @Attribute var environment: EnvironmentValues
    let tracker: PropertyList.Tracker

    typealias Value = EnvironmentValues

    mutating func updateValue() {
        let (environment, environmentChanged) = $environment.changedValue()
        if !hasValue || (environmentChanged && tracker.hasDifferentUsedValues(environment.plist)) {
            tracker.reset()
            value = EnvironmentValues(environment.plist, tracker: tracker)
        }
    }
}

// MARK: - DisplayListTransform

private struct DisplayListTransform<Modifier>: Rule, CustomStringConvertible where Modifier: AccessibilityViewModifier {
    let identity: DisplayList.Identity
    let archivable: Bool
    let idiom: AnyInterfaceIdiom
    let options: DisplayList.Options
    @Attribute var modifier: Modifier
    @Attribute var size: ViewSize
    @Attribute var position: ViewOrigin
    @Attribute var containerPosition: ViewOrigin
    @Attribute var environment: EnvironmentValues
    @OptionalAttribute var content: DisplayList?
    @OptionalAttribute var deferredAttachment: AccessibilityAttachment.Tree?
    @OptionalAttribute var nodeList: AccessibilityNodeList?

    var value: DisplayList {
        var list = content ?? DisplayList()
        let nodes = nodeList?.nodes ?? []
        guard environment.accessibilityEnabled else {
            return list
        }
        // TBA
        let placeholder = nodes.isEmpty && modifier.supportsPlaceholders && list.features.contains(.views)
        var createsNode = modifier.willCreateNode(for: nodes)
        var attachments: [AccessibilityAttachment] = []
        if createsNode || placeholder {
            var attachment = modifier.initialAttachment(for: nodes)
            if let deferred = deferredAttachment?.attachment {
                attachment.merge(with: deferred)
            }
            attachments.append(attachment)
        } else {
            let token = AccessibilityAttachmentToken(attribute)
            for index in nodes.indices {
                var attachment = modifier.updatedAttachment(for: token, nodes: nodes, atIndex: index)
                if let deferred = deferredAttachment?.attachment {
                    attachment.merge(with: deferred)
                }
                if !attachment.isEmpty {
                    attachments.append(attachment)
                }
            }
        }
        let frame = CGRect(origin: CGPoint(position - containerPosition), size: size.value)
        let version = DisplayList.Version(forUpdate: ())
        var archivableAttachment: AccessibilityArchivableViewAttachment?
        if archivable {
            archivableAttachment = attachments.reduce(into: nil) { result, attachment in
                guard let next = AccessibilityArchivableViewAttachment(attachment, environment: environment) else {
                    return
                }
                if result != nil {
                    if let actions = next.actions {
                        result?.actions?.append(contentsOf: actions)
                    }
                } else {
                    result = next
                }
            }
        }
        if !createsNode {
            createsNode = mergeAttachments(
                list: &list,
                attachments: &attachments,
                frame: CGRect(origin: .zero, size: frame.size)
            )
        }
        let nodeAttachments = attachments.map { attachment in
            let platformStorage: AccessibilityPlatformPropertyStorage
            #if canImport(UIKit)
            platformStorage = .init(explicitTraits: attachment.properties.uiKitTraits.map {
                CodableAccessibilityUIKitTraits(removed: $0.removed.rawValue, added: $0.added.rawValue)
            })
            #elseif os(macOS)
            platformStorage = .init(
                explicitRole: attachment.properties.role?.rawValue,
                explicitSubrole: attachment.properties.subrole?.rawValue
            )
            #else
            platformStorage = .init()
            #endif
            return AccessibilityNodeAttachment(
                attachment,
                platformStorage: platformStorage,
                in: environment,
                idiom: idiom,
                createsNode: createsNode,
                kind: placeholder ? .placeholder : .standard,
                encode: archivable
            )
        }
        var item = DisplayList.Item(
            .effect(.accessibility(nodeAttachments), list),
            frame: archivableAttachment == nil ? frame : CGRect(origin: .zero, size: size.value),
            identity: archivableAttachment == nil ? identity : .none,
            version: version
        )
        item.canonicalize(options: options)
        list = DisplayList(item)
        if let archivableAttachment {
            let factory = ArchivableAccessibilityViewModifier.Factory(
                attachment: archivableAttachment,
                identity: identity,
                size: size.value
            )
            var item = DisplayList.Item(.effect(.view(factory), list), frame: frame, identity: identity, version: version)
            item.canonicalize(options: options)
            list = DisplayList(item)
        }
        return list
    }

    var description: String {
        "AccessibilityDisplayListTransform"
    }

    private func mergeAttachments(
        list: inout DisplayList,
        attachments: inout [AccessibilityAttachment],
        frame: CGRect
    ) -> Bool {
        guard list.items.count == 1,
              list.items[0].frame == frame,
              case let .effect(.accessibility(nodeAttachments), content) = list.items[0].value,
              attachments.count == 1,
              nodeAttachments.count == 1,
              nodeAttachments[0].kind == .standard else {
            return false
        }
        let nodeAttachment = nodeAttachments[0]
        let attachment: AccessibilityAttachment
        #if canImport(UIKit)
        attachment = nodeAttachment.makeAttachment(with: UIKitAccessibilityPropertyApplicator.self)
        #elseif os(macOS)
        attachment = nodeAttachment.makeAttachment(with: AppKitAccessibilityPropertyApplicator.self)
        #else
        _openSwiftUIPlatformUnimplementedFailure()
        #endif
        attachments = [.combine([attachment, attachments[0]])]
        list = content
        return nodeAttachment.createsNode
    }
}

// MARK: - AccessibilityPlatformItemTransform

private struct AccessibilityPlatformItemTransform: PrimitiveViewModifier, UnaryPlatformItemsModifier {
    var accessibility: PlatformItem.AccessibilityContent?

    static var features: PlatformItem.Features {
        .accessibility
    }

    static func updateItem(modifier: Self, item: inout PlatformItem) {
        item.accessibility = modifier.accessibility
    }
}

// MARK: - PropertiesTransform

private struct PropertiesTransform<Modifier>: StatefulRule, RemovableAttribute, CustomStringConvertible where Modifier: AccessibilityViewModifier {
    @Attribute var modifier: Modifier
    @Attribute var position: ViewOrigin
    @Attribute var size: ViewSize
    @Attribute var transform: ViewTransform
    @Attribute var environment: EnvironmentValues
    @Attribute var phase: _GraphInputs.Phase
    let localID: ScrapeableID
    let parentID: ScrapeableID
    @OptionalAttribute var deferredAttachment: AccessibilityAttachment.Tree?
    @OptionalAttribute var nodeList: AccessibilityNodeList?
    let idiom: AnyInterfaceIdiom
    var isInPlatformItemList: Bool
    var parentNode: AccessibilityNode?
    weak var removedParentNode: AccessibilityNode?
    var resetSeed: UInt32 = 0

    typealias Value = AccessibilityNodeList

    mutating func updateValue() {
        // TBA
        guard environment.accessibilityEnabled else {
            value = nodeList ?? AccessibilityNodesKey.defaultValue
            return
        }
        if resetSeed != phase.resetSeed {
            parentNode = nil
            removedParentNode = nil
            resetSeed = phase.resetSeed
        }
        let (modifier, _) = $modifier.changedValue()
        let (environment, environmentChanged) = $environment.changedValue()
        let token = AccessibilityAttachmentToken(attribute)
        let (childList, childListChanged) = $nodeList?.changedValue()
            ?? (AccessibilityNodesKey.defaultValue, false)
        let nodes = childList.nodes
        var result = childList
        if modifier.willCreateNode(for: nodes) {
            let node = modifier.createOrUpdateNode(
                viewRendererHost: ViewGraph.viewRendererHost,
                existingNode: parentNode
            )
            var changed = node !== parentNode
            if changed {
                if hasValue, parentNode == nil {
                    for child in nodes {
                        child.removeAttachments(after: token)
                    }
                }
                if parentNode == nil, !environmentChanged {
                    node.updateEnvironment(environment)
                }
                parentNode = node
            }
            if environmentChanged {
                node.updateEnvironment(environment)
                changed = true
            }
            var attachment = modifier.initialAttachment(for: nodes)
            if let deferred = deferredAttachment?.attachment {
                attachment.merge(with: deferred)
            }
            if node.hasAttachment(token: token) {
                if node.updateAttachment(
                    attachment,
                    isInPlatformItemList: isInPlatformItemList,
                    token: token,
                    merge: false
                ) || node.platformElement != nil || node.parent == nil {
                    changed = true
                }
            } else {
                node.addAttachment(
                    attachment,
                    isInPlatformItemList: isInPlatformItemList,
                    token: token
                )
                changed = true
            }
            node.updateChildren(nodes)
            result.nodes = [node]
            if changed {
                result.version = .init(forUpdate: ())
            } else {
                if childListChanged {
                    Update.enqueueAction {
                        node.updatePlatformProperties()
                    }
                }
                result.version = hasValue ? value.version : result.version
            }
        } else {
            if parentNode != nil {
                for node in nodes {
                    node.parent = nil
                }
                parentNode = nil
            }
            var changed = childListChanged
            for (index, node) in nodes.enumerated() {
                var attachment = modifier.updatedAttachment(for: token, nodes: nodes, atIndex: index)
                if let deferred = deferredAttachment?.attachment {
                    attachment.merge(with: deferred)
                }
                if node.hasAttachment(token: token) {
                    if node.updateAttachment(
                        attachment,
                        isInPlatformItemList: isInPlatformItemList,
                        token: token,
                        merge: false
                    ) {
                        changed = true
                    }
                } else if !attachment.isEmpty,
                          !node.isLabel || !attachment.properties.traits[.isLabel, default: true] {
                    node.addAttachment(
                        attachment,
                        isInPlatformItemList: isInPlatformItemList,
                        token: token
                    )
                    changed = true
                }
            }
            result.version = changed ? .init(forUpdate: ()) : (hasValue ? value.version : result.version)
        }
        value = result
    }

    mutating func insert() {
        parentNode = removedParentNode
        parentNode?.platformElementPropertiesDirty = true
    }

    static func willRemove(attribute: AnyAttribute) {
        let body = UnsafeMutableRawPointer(mutating: attribute.info.body)
            .assumingMemoryBound(to: Self.self)
        body.pointee.removedParentNode = body.pointee.parentNode
        body.pointee.parentNode = nil
    }

    static func didReinsert(attribute: AnyAttribute) {
        let body = UnsafeMutableRawPointer(mutating: attribute.info.body)
            .assumingMemoryBound(to: Self.self)
        body.pointee.insert()
    }

    var description: String {
        "AccessibilityPropertiesTransform: \(Modifier.self)"
    }
}

extension PropertiesTransform: ScrapeableAttribute where Modifier == AccessibilityAttachmentModifier {
    static func scrapeContent(from ident: AnyAttribute) -> ScrapeableContent.Item? {
        let pointer = ident.info.body.assumingMemoryBound(to: Self.self)
        return .init(
            .accessibilityProperties(
                pointer[].modifier.storage.value.properties,
                pointer[].environment,
                pointer[].idiom
            ),
            ids: pointer[].localID,
            pointer[].parentID,
            position: pointer[].$position,
            size: pointer[].$size,
            transform: pointer[].$transform
        )
    }
}

// MARK: - AccessibilityArchivableViewAttachment

private struct AccessibilityArchivableViewAttachment: Codable, DynamicProperty {
    @Environment(\.appIntentExecutor) var appIntentExecutor: AppIntentExecutor?
    var actions: [CodableAccessibilityAction]?

    init?(_ attachment: AccessibilityAttachment, environment: EnvironmentValues) {
        let actions = attachment.properties.actions.compactMap { $0.asCodableAction(in: environment) }
        guard !actions.isEmpty else {
            return nil
        }
        self.actions = actions
    }

    var properties: AccessibilityProperties {
        var properties = AccessibilityProperties()
        if let actions {
            properties.actions = actions.map { AnyAccessibilityAction($0, appIntentExecutor: appIntentExecutor) }
        }
        return properties
    }

    private enum CodingKeys: String, CodingKey {
        case actions
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        actions = try container.decodeIfPresent([CodableAccessibilityAction].self, forKey: .actions)
    }

    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(actions, forKey: .actions)
    }
}

// MARK: - ArchivedAttachmentModifier

struct ArchivedAttachmentModifier: AccessibilityViewModifier {
    var attachment: AccessibilityAttachment

    static var options: AccessibilityModifierOptions { [] }

    func willCreateNode(for nodes: [AccessibilityNode]) -> Bool {
        false
    }

    func initialAttachment(for nodes: [AccessibilityNode]) -> AccessibilityAttachment {
        attachment
    }

    func updatedAttachment(
        for token: AccessibilityAttachmentToken,
        nodes: [AccessibilityNode],
        atIndex index: Int
    ) -> AccessibilityAttachment {
        attachment
    }

    func createOrUpdateNode(
        viewRendererHost: (any ViewRendererHost)?,
        existingNode: AccessibilityNode?
    ) -> AccessibilityNode {
        existingNode ?? AccessibilityNode(viewRendererHost: viewRendererHost, isFromDisplayList: false)
    }

    static func makeAccessibilityViewModifier(
        modifier: _GraphValue<Self>,
        inputs: _ViewInputs,
        body: @escaping (_Graph, _ViewInputs) -> _ViewOutputs
    ) -> _ViewOutputs {
        body(_Graph(), inputs)
    }

    var supportsPlaceholders: Bool { true }
}
