//
//  AccessibilityChildBehavior.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Blocked by AccessibilityNode
//  ID: F0D4BE429651399A5FAD2DF7DCDF699D (SwiftUI)

import OpenAttributeGraphShims
@_spi(ForOpenSwiftUIOnly)
import OpenSwiftUICore

// MARK: - AccessibilityChildBehavior

/// Defines the behavior for the child elements of the new parent element.
@available(OpenSwiftUI_v1_0, *)
public struct AccessibilityChildBehavior: Hashable {
    var modifier: AnyAccessibilityViewModifier

    /// Any child accessibility elements become hidden.
    ///
    /// Use this behavior when you want a view represented by
    /// a single accessibility element. The new accessibility element
    /// has no initial properties. So you will need to use other
    /// accessibility modifiers, such as ``View.accessibilityLabel(_:)``,
    /// to begin making it accessible.
    ///
    ///     var body: some View {
    ///         VStack {
    ///             Button("Previous Page", action: goBack)
    ///             Text("\(pageNumber)")
    ///             Button("Next Page", action: goForward)
    ///         }
    ///         .accessibilityElement(children: .ignore)
    ///         .accessibilityValue("Page \(pageNumber) of \(pages.count)")
    ///         .accessibilityAdjustableAction { action in
    ///             if action == .increment {
    ///                 goForward()
    ///             } else {
    ///                 goBack()
    ///             }
    ///         }
    ///     }
    ///
    /// Before using the ``AccessibilityChildBehavior/ignore`` behavior, consider
    /// using the ``AccessibilityChildBehavior/combine`` behavior.
    ///
    /// - Note: A new accessibility element is always created.
    public static let ignore = AccessibilityChildBehavior(modifier: AccessibilityChildBehaviorBox(provider: Ignore()))

    /// Any child accessibility elements become children of the new
    /// accessibility element.
    ///
    /// Use this behavior when you want a view to be an accessibility
    /// container. An accessibility container groups child accessibility
    /// elements which improves navigation. For example, all children
    /// of an accessibility container are navigated in order before
    /// navigating through the next accessibility container.
    ///
    ///     var body: some View {
    ///         ScrollView {
    ///             VStack {
    ///                 HStack {
    ///                     ForEach(users) { user in
    ///                         UserCell(user)
    ///                     }
    ///                 }
    ///                 .accessibilityElement(children: .contain)
    ///                 .accessibilityLabel("Users")
    ///
    ///                 VStack {
    ///                     ForEach(messages) { message in
    ///                         MessageCell(message)
    ///                     }
    ///                 }
    ///                 .accessibilityElement(children: .contain)
    ///                 .accessibilityLabel("Messages")
    ///             }
    ///         }
    ///     }
    ///
    /// A new accessibility element is created when:
    /// * The view contains multiple or zero accessibility elements
    /// * The view contains a single accessibility element with no children
    ///
    /// - Note: If an accessibility element is not created, the
    ///         ``AccessibilityChildBehavior`` of the existing
    ///         accessibility element is modified.
    public static let contain = AccessibilityChildBehavior(modifier: AccessibilityChildBehaviorBox(provider: Contain()))

    /// Any child accessibility element's properties are merged
    /// into the new accessibility element.
    ///
    /// Use this behavior when you want a view represented by
    /// a single accessibility element. The new accessibility element
    /// merges properties from all non-hidden children. Some
    /// properties may be transformed or ignored to achieve the
    /// ideal combined result. For example, not all of ``AccessibilityTraits``
    /// are merged and a ``AccessibilityActionKind/default`` action
    /// may become a named action (``AccessibilityActionKind/init(named:)``).
    ///
    ///     struct UserCell: View {
    ///         var user: User
    ///
    ///         var body: some View {
    ///             VStack {
    ///                 Image(user.image)
    ///                 Text(user.name)
    ///                 Button("Options", action: showOptions)
    ///             }
    ///             .accessibilityElement(children: .combine)
    ///         }
    ///     }
    ///
    /// A new accessibility element is created when:
    /// * The view contains multiple or zero accessibility elements
    /// * The view wraps a ``UIViewRepresentable``/``NSViewRepresentable``.
    ///
    /// - Note: If an accessibility element is not created, the
    ///         ``AccessibilityChildBehavior`` of the existing
    ///         accessibility element is modified.
    public static let combine = AccessibilityChildBehavior(modifier: AccessibilityChildBehaviorBox(provider: Combine(options: [])))

    static let automatic = AccessibilityChildBehavior(modifier: AccessibilityChildBehaviorBox(provider: Automatic()))

    static let host = AccessibilityChildBehavior(modifier: AccessibilityChildBehaviorBox(provider: Host()))

    static let automation = AccessibilityChildBehavior(modifier: AccessibilityChildBehaviorBox(provider: Automation()))

    static func defaultCombine(
        childProperties: [AccessibilityProperties],
        createsCustomActions: Bool
    ) -> AccessibilityProperties {
        guard var properties = childProperties.last else {
            return AccessibilityProperties()
        }
        for child in childProperties.dropLast().reversed() {
            properties.merge(with: child)
        }

        var labels: [Text] = []
        var descriptions: [Text] = []
        var hints: [Text] = []
        var identifiers: [String] = []
        var inputLabels: [Text] = []
        var allStaticTextOrImages = true
        for child in childProperties {
            let isImage = child.traits[.isImage, default: false]
            let isOptionalImageLabel = isImage && child.labelStorage?.placement == .optional
            let isButtonLabel = createsCustomActions && child.traits[.isButton, default: false]
            if !isOptionalImageLabel && !isButtonLabel {
                labels += child.labelStorage?.texts ?? []
            }
            descriptions += child.value?.description.text ?? []
            hints += child.hints
            inputLabels += child.inputLabels ?? []
            if let identifier = child.identifierStorage,
               identifier.placement != .optional,
               let value = identifier.value,
               !value.isEmpty {
                identifiers.append(value)
            }
            if !child.traits[.isStaticText, default: false] && !isImage {
                allStaticTextOrImages = false
            }
        }
        if labels.isEmpty {
            labels = childProperties.flatMap { $0.labelStorage?.texts ?? [] }
        }
        if !labels.isEmpty {
            properties.labelStorage = AccessibilityLabelStorage(texts: labels)
        }
        if !descriptions.isEmpty {
            if properties.value == nil {
                properties.value = AccessibilityValueStorage(descriptions: descriptions)
            } else {
                properties.value?.valueDescription = descriptions
            }
        }
        properties.hints = hints
        let identifier = identifiers.joined(separator: "-")
        properties.identifierStorage = identifier.isEmpty ? nil : AccessibilityIdentifierStorage(identifier)
        properties.inputLabels = inputLabels.isEmpty ? nil : inputLabels
        if !allStaticTextOrImages {
            properties.traits[.isStaticText] = nil
        }
        properties.traits[.isImage] = nil
        if createsCustomActions && !properties.actions.isEmpty {
            properties.traits[.isButton] = nil
            properties.traits[.isLink] = nil
        }
        properties.activationPointStorage = nil
        properties.traits[.isLabel] = nil
        properties.automationVisibility = nil
        properties.textLayoutProperties = nil
        #if canImport(UIKit)
        properties.uiKitBridgedInteraction = nil
        #endif
        return properties
    }

    public func hash(into hasher: inout Hasher) {
        modifier.hash(into: &hasher)
    }

    public static func == (lhs: AccessibilityChildBehavior, rhs: AccessibilityChildBehavior) -> Bool {
        lhs.modifier.isEqual(to: rhs.modifier)
    }

    // MARK: - AccessibilityChildBehaviorProvider Types [TBA]

    struct Automation: AccessibilityChildBehaviorProvider {
        func initialAttachment(for nodes: [AccessibilityNode]) -> AccessibilityAttachment {
            .properties(AccessibilityProperties(AccessibilityProperties.VisibilityKey.self, .init(adding: .container)))
        }

        func willCreateNode(for nodes: [AccessibilityNode]) -> Bool {
            true
        }
    }

    struct Ignore: AccessibilityChildBehaviorProvider {
        func initialAttachment(for nodes: [AccessibilityNode]) -> AccessibilityAttachment {
            .properties(AccessibilityProperties(
                AccessibilityProperties.VisibilityKey.self,
                .init(adding: .element, .childrenIgnored, removing: .container)
            ))
        }

        func willCreateNode(for nodes: [AccessibilityNode]) -> Bool {
            true
        }
    }

    struct Contain: AccessibilityChildBehaviorProvider {
        func initialAttachment(for nodes: [AccessibilityNode]) -> AccessibilityAttachment {
            .properties(AccessibilityProperties(
                AccessibilityProperties.VisibilityKey.self,
                .init(adding: .containerElement, removing: .childrenIgnored)
            ))
        }

        func willCreateNode(for nodes: [AccessibilityNode]) -> Bool {
            guard nodes.count == 1 else {
                return true
            }
            let visibility = nodes[0].visibility
            if visibility[.container, default: false] {
                return false
            }
            if !visibility[.element, default: false] || visibility[.childrenIgnored, default: false] {
                return true
            }
            return nodes[0].children.isEmpty
        }
    }

    struct Combine: AccessibilityChildBehaviorProvider {
        var options: Options

        func willCreateNode(for nodes: [AccessibilityNode]) -> Bool {
            if nodes.count == 1 {
                if nodes[0].platformElement != nil {
                    return !options.contains(.preservePlatformElement)
                }
                return options.contains(.includeHiddenChild) && nodes[0].visibility.resolvesToHidden
            }
            if nodes.count >= 2 && options.contains(.reuseLabelNodes) {
                return !nodes.contains { $0.isLabel }
            }
            return true
        }

        func initialAttachment(for nodes: [AccessibilityNode]) -> AccessibilityAttachment {
            var children = nodes
            if nodes.count == 1, nodes[0].platformElement != nil {
                children += nodes[0].bridgedChild?.children ?? []
                if nodes[0].visibility.resolved != .element {
                    children += nodes[0].children
                }
            }
            var attachment: AccessibilityAttachment
            if nodes.contains(where: { $0.properties.temporalState != nil }) {
                var properties = AccessibilityProperties()
                properties.childBehaviorKind = .combine
                attachment = .properties(properties)
            } else {
                attachment = Self.combine(children: children, options: options)
            }
            attachment.properties.visibility = .init(adding: .element, .childrenIgnored, removing: .container)
            if options.contains(.preservePlatformElement), willCreateNode(for: nodes) {
                attachment.platformElement = nodes.lazy.compactMap { $0.platformElement }.first
            }
            return attachment
        }

        func visibility(
            for token: AccessibilityAttachmentToken,
            nodes: [AccessibilityNode]
        ) -> AccessibilityVisibilityStorage {
            nodes.first?.visibilityIgnoringAttachment(with: token) ?? .init()
        }

        static func combine(children: [AccessibilityNode], options: Options) -> AccessibilityAttachment {
            let children = children.filter {
                !$0.visibility.resolvesToHidden && !$0.isPlaceholderOrIgnored
            }.sorted {
                ($0.sortPriority ?? 0) > ($1.sortPriority ?? 0)
            }
            var childProperties = children.map { $0.properties }
            if !options.contains(.preservePlatformElement) {
                for index in children.indices where children[index].platformElement != nil {
                    let bridgedProperties = Graph.withoutUpdate {
                        childProperties[index].bridgedElement.map { element -> AccessibilityProperties in
                            #if os(macOS) || os(iOS) || os(visionOS)
                            element.bridgedProperties
                            #else
                            _openSwiftUIPlatformUnimplementedFailure()
                            #endif
                        }
                    }
                    if let bridgedProperties {
                        childProperties[index].bridgedElement = nil
                        childProperties[index].merge(with: bridgedProperties)
                    }
                }
            }
            var properties = AccessibilityChildBehavior.defaultCombine(
                childProperties: childProperties,
                createsCustomActions: true
            )
            var hasDefaultAction = options.contains(.allActionsCustom)
            let combinedActions = zip(childProperties, children).map { childProperties, child in
                var removedLabels: [Text] = []
                var actions: [AnyAccessibilityAction] = []
                actions.reserveCapacity(childProperties.actions.count)
                for action in childProperties.actions {
                    guard action.matches(AccessibilityVoidAction(kind: .default)) else {
                        actions.append(action.bridged ? action : action.asReference(for: child))
                        continue
                    }
                    let alreadyHasDefaultAction = hasDefaultAction
                    if !alreadyHasDefaultAction {
                        actions.append(action.bridged ? action : action.asReference(for: child))
                        hasDefaultAction = true
                        if !childProperties.traits[.isButton, default: false] {
                            continue
                        }
                        if let label = childProperties.labelStorage?.texts.first,
                           properties.labelStorage?.texts.contains(label) == true {
                            continue
                        }
                    }
                    var labels = childProperties.labelStorage?.texts ?? []
                    if labels.isEmpty {
                        labels = action.name.map { [$0] } ?? []
                    }
                    var combinedAction: AnyAccessibilityAction?
                    if let name = labels.first {
                        if alreadyHasDefaultAction {
                            removedLabels += labels
                        }
                        combinedAction = action.asCombinedAction(name: name, properties: childProperties, child: child)
                    }
                    actions.append(combinedAction ?? (action.bridged ? action : action.asReference(for: child)))
                }
                return (removedLabels, actions)
            }
            properties.actions = combinedActions.flatMap { $0.1 }
            for label in combinedActions.flatMap({ $0.0 }) {
                properties.labelStorage?.removing(label)
            }
            return .properties(properties)
        }

        struct Options: OptionSet, Hashable {
            var rawValue: UInt8

            static let preservePlatformElement = Options(rawValue: 1 << 0)
            static let reuseLabelNodes = Options(rawValue: 1 << 1)
            static let allActionsCustom = Options(rawValue: 1 << 2)
            static let includeHiddenChild = Options(rawValue: 1 << 3)
        }
    }

    struct Automatic: AccessibilityChildBehaviorProvider {
        func initialAttachment(for nodes: [AccessibilityNode]) -> AccessibilityAttachment {
            guard nodes.count != 1 else {
                return AccessibilityAttachment()
            }
            var visibility = AccessibilityVisibilityStorage()
            visibility[.element] = true
            if !nodes.isEmpty {
                visibility[.container] = true
            }
            return .properties(AccessibilityProperties(AccessibilityProperties.VisibilityKey.self, visibility))
        }

        func willCreateNode(for nodes: [AccessibilityNode]) -> Bool {
            nodes.count != 1
        }
    }

    struct Host: AccessibilityChildBehaviorProvider {
        func initialAttachment(for nodes: [AccessibilityNode]) -> AccessibilityAttachment {
            .properties(AccessibilityProperties(
                AccessibilityProperties.VisibilityKey.self,
                .init(adding: .container, .ignored, .host)
            ))
        }

        func willCreateNode(for nodes: [AccessibilityNode]) -> Bool {
            true
        }
    }
}

@available(*, unavailable)
extension AccessibilityChildBehavior: Sendable {}

// MARK: - AccessibilityChildBehaviorProvider

protocol AccessibilityChildBehaviorProvider: Hashable {
    func initialAttachment(for nodes: [AccessibilityNode]) -> AccessibilityAttachment

    func willCreateNode(for nodes: [AccessibilityNode]) -> Bool

    func visibility(for token: AccessibilityAttachmentToken, nodes: [AccessibilityNode]) -> AccessibilityVisibilityStorage
}

extension AccessibilityChildBehaviorProvider {
    func visibility(for token: AccessibilityAttachmentToken, nodes: [AccessibilityNode]) -> AccessibilityVisibilityStorage {
        nodes.first?.visibility ?? .init()
    }
}

// MARK: - AccessibilityChildBehaviorBox

private class AccessibilityChildBehaviorBox<Provider>: AnyAccessibilityViewModifier where Provider: AccessibilityChildBehaviorProvider {
    let provider: Provider

    init(provider: Provider) {
        self.provider = provider
    }

    override func willCreateNode(for nodes: [AccessibilityNode]) -> Bool {
        provider.willCreateNode(for: nodes)
    }

    override func initialAttachment(for nodes: [AccessibilityNode]) -> AccessibilityAttachment {
        provider.initialAttachment(for: nodes)
    }

    override func isEqual(to other: AnyAccessibilityViewModifier) -> Bool {
        guard let other = other as? AccessibilityChildBehaviorBox<Provider> else {
            return false
        }
        return provider == other.provider
    }

    override func hash(into hasher: inout Hasher) {
        provider.hash(into: &hasher)
    }

    override func visibility(for token: AccessibilityAttachmentToken, nodes: [AccessibilityNode]) -> AccessibilityVisibilityStorage {
        provider.visibility(for: token, nodes: nodes)
    }
}
