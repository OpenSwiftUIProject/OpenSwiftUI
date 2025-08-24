//
//  ScrapeableContent.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: WIP
//  ID: 0EC4D15D4D4D8FD0340271BA6BA4D1B4

package import Foundation
package import OpenGraphShims

// MARK: - ScrapeableID

package struct ScrapeableID: Hashable {
    package static let none: ScrapeableID = .init(value: 0)

    package init() {
        value = numericCast(makeUniqueID())
    }

    let value: UInt32

    private init(value: UInt32) {
        self.value = value
    }
}

// MARK: - ViewInputs + Scrapeable

extension _ViewInputs {
    package var isScrapeable: Bool {
        get {
            guard needsGeometry else {
                return false
            }
            return preferences.contains(DisplayList.Key.self)
        }
        set {
            base.options.setValue(!newValue, for: .doNotScrape)
        }
    }

    private struct ScrapeableParentID: ViewInput {
        static var defaultValue: ScrapeableID { .none }
    }

    package var scrapeableParentID: ScrapeableID {
        get { self[ScrapeableParentID.self] }
        set { self[ScrapeableParentID.self] = newValue }
    }
}

// MARK: - ScrapeableAttribute

package protocol ScrapeableAttribute: _AttributeBody {
    static func scrapeContent(from ident: AnyAttribute) -> ScrapeableContent.Item?
}

// MARK: - ScrapeableAttachmentViewModifier

private struct ScrapeableAttachmentViewModifier: MultiViewModifier, PrimitiveViewModifier {
    var content: ScrapeableContent.Content?

    nonisolated static func _makeView(
        modifier: _GraphValue<Self>,
        inputs: _ViewInputs,
        body: @escaping (_Graph, _ViewInputs) -> _ViewOutputs
    ) -> _ViewOutputs {
        var inputs = inputs
        if inputs.needsGeometry, inputs.preferences.requiresDisplayList {
            let localID = ScrapeableID()
            let attachment = Attribute(
                Attachment(
                    content: modifier.value[keyPath: \.content],
                    position: inputs.position,
                    size: inputs.size,
                    transform:  inputs.transform,
                    localID: localID,
                    parentID: inputs.scrapeableParentID
                )
            )
            attachment.flags = [attachment.flags, .scrapeable]
            inputs.scrapeableParentID = localID
        }
        let outputs = body(_Graph(), inputs)
        return outputs
    }

    struct Attachment: Rule, ScrapeableAttribute {
        @Attribute var content: ScrapeableContent.Content?
        @Attribute var position: ViewOrigin
        @Attribute var size: ViewSize
        @Attribute var transform: ViewTransform
        let localID: ScrapeableID
        let parentID: ScrapeableID

        var value: Void {
            _openSwiftUIUnimplementedFailure()
        }

        static func scrapeContent(from ident: AnyAttribute) -> ScrapeableContent.Item? {
            let pointer = ident.info.body.assumingMemoryBound(to: Attachment.self)
            guard let content = pointer.pointee.content else {
                return nil
            }
            return .init(
                content,
                ids: pointer.pointee.localID,
                pointer.pointee.parentID,
                position: pointer.pointee.$position,
                size: pointer.pointee.$size,
                transform: pointer.pointee.$transform
            )
        }
    }
}

extension View {
    package func scrapeableAttachment(_ content: ScrapeableContent.Content?) -> some View {
        modifier(ScrapeableAttachmentViewModifier(content: content))
    }
}

// MARK: - ScrapeableContent [WIP]

package struct ScrapeableContent {
    indirect package enum Content {
        case text(Text, ResolvedStyledText, EnvironmentValues)
        case image(Image, EnvironmentValues)
        case platformView(AnyObject)
        case accessibilityProperties(AccessibilityProperties, EnvironmentValues, AnyInterfaceIdiom)
        case intelligenceProvider(Any)
        case opacity(Double)
        #if canImport(Darwin)
        case userActivity(NSUserActivity)
        #endif
        case hidden
        case presentationContainer
        case presentationContainerChild
    }

    package struct Item {
        package var localID: ScrapeableID
        package var parentID: ScrapeableID
        package var content: ScrapeableContent.Content
        package var size: CGSize
        package var transform: ViewTransform

        package init(
            _ content: ScrapeableContent.Content,
            ids localID: ScrapeableID,
            _ parentID: ScrapeableID,
            position: Attribute<ViewOrigin>,
            size: Attribute<ViewSize>,
            transform: Attribute<ViewTransform>
        ) {
            self.localID = localID
            self.parentID = parentID
            self.content = content
            self.size = size.value.value
            self.transform = transform.value.withPosition(position.value)
        }
    }

    final package class Node {
        package let item: Item

        package private(set) var children: [ScrapeableContent.Node]

        private var moved: Bool

        init(item: Item, children: [ScrapeableContent.Node] = [], moved: Bool = false) {
            self.item = item
            self.children = children
            self.moved = moved
        }
    }

    package var nodes: [ScrapeableContent.Node]

    package var children: [ScrapeableContent]

    package var isEmpty: Bool {
        nodes.isEmpty && children.isEmpty
    }
}

extension Subgraph {
    private struct Map {
        struct Key: Hashable {
            var subgraph: Subgraph

            #if !canImport(Darwin)
            // FIXME: Subgraph on non-Darwin platform does not conform to Hashable by default
            func hash(into hasher: inout Hasher) {
                hasher.combine(ObjectIdentifier(subgraph))
            }

            static func == (a: Key, b: Key) -> Bool {
                ObjectIdentifier(a.subgraph) == ObjectIdentifier(b.subgraph)
            }
            #endif
        }

        var map: [Key: [ScrapeableContent.Node]] = [:]

        mutating func addItem(_ item: ScrapeableContent.Item, for subgraph: Subgraph) {
            let key = Key(subgraph: subgraph)
            var nodes = map[key] ?? []
            nodes.append(.init(item: item))
            map[key] = nodes
        }

        func content(for subgraph: Subgraph, updated: inout Set<ObjectIdentifier>) -> ScrapeableContent? {
            let (isInserted, m) = updated.insert(ObjectIdentifier(subgraph))
            guard isInserted else {
                return nil
            }
            let key = Key(subgraph: subgraph)
            let content = ScrapeableContent(nodes: map[key] ?? [], children: [])
            // subgraph.childCount / OGSubgraphGetChildCount
            _openSwiftUIUnimplementedFailure()
        }

        func resolveParents(nodes: inout [ScrapeableContent.Node], children: inout [ScrapeableContent]) {
            _openSwiftUIUnimplementedFailure()
        }
    }

    package func scrapeContent() -> ScrapeableContent {
        var map = Map()
        forEach(.scrapeable) { attribute in
            guard let attr = attribute._bodyType as? ScrapeableAttribute.Type, // FIXME
                  let item = attr.scrapeContent(from: attribute) else {
                return
            }
            map.addItem(item, for: self)
        }
        var updated: Set<ObjectIdentifier> = []
        return map.content(for: self, updated: &updated) ?? .init(nodes: [], children: [])
    }
}

extension ViewGraph {
    final package func scrapeContent() -> ScrapeableContent {
        rootSubgraph.scrapeContent()
    }
}

extension ViewRendererHost {
    package func scrapeContent() -> ScrapeableContent {
        updateViewGraph { viewGraph in
            viewGraph.scrapeContent()
        }
    }
}

// MARK: - ScrapeableContent + CustomStringConvertible

extension ScrapeableContent: CustomStringConvertible {
    fileprivate func print(into printer: inout SExpPrinter) {
        for node in nodes {
            node.print(into: &printer)
        }
        guard !children.isEmpty else {
            return
        }
        printer.push("children")
        for child in children {
            child.print(into: &printer)
        }
        printer.pop()
    }

    package var description: String {
        var printer = SExpPrinter(tag: "(scrapeable-content")
        print(into: &printer)
        return printer.end()
    }
}

extension ScrapeableContent.Node: CustomStringConvertible {
    fileprivate func print(into printer: inout SExpPrinter) {
        item.print(into: &printer)
        guard !children.isEmpty else {
            return
        }
        printer.push("children")
        for child in children {
            child.print(into: &printer)
        }
        printer.pop()
    }

    final package var description: String {
        var printer = SExpPrinter(tag: "(scrapeable-content-node")
        print(into: &printer)
        return printer.end()
    }
}

extension ScrapeableContent.Item: CustomStringConvertible {
    fileprivate func print(into printer: inout SExpPrinter) {
        printer.push("item")
        if size != .zero {
            printer.print("#:size (\(size.width) \(size.height))", newline: false)
        }
        // TODO: switch Content
        printer.pop()
    }

    package var description: String {
        var printer = SExpPrinter(tag: "(scrapeable-content-item")
        print(into: &printer)
        return printer.end()
    }
}
