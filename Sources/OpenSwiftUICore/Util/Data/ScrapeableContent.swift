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

// MARK: - ScrapeableAttachmentViewModifier [WIP]

private struct ScrapeableAttachmentViewModifier: ViewModifier {
    var content: ScrapeableContent.Content?

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
            _openSwiftUIUnimplementedFailure()
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
        case userActivity(NSUserActivity)
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
            _openSwiftUIUnimplementedFailure()
        }
    }

    final package class Node {
        package let item: Item

        package private(set) var children: [ScrapeableContent.Node]

        init(item: Item, children: [ScrapeableContent.Node], moved: Bool = false) {
            self.item = item
            self.children = children
            self.moved = moved
        }

        private var moved = false
    }

    package var nodes: [ScrapeableContent.Node]
    package var children: [ScrapeableContent]

    package var isEmpty: Bool {
        _openSwiftUIUnimplementedFailure()
    }
}

extension Subgraph {
    private struct Map {
        struct Key: Hashable {
            var subgraph: Subgraph
        }

        var map: [Key: [ScrapeableContent.Node]] = [:]

        func content(for subgraph: Subgraph, updated: inout Set<ObjectIdentifier>) -> ScrapeableContent? {
            _openSwiftUIUnimplementedFailure()
        }

        func resolveParents(nodes: inout [ScrapeableContent.Node], children: inout [ScrapeableContent]) {
            _openSwiftUIUnimplementedFailure()
        }
    }

    package func scrapeContent() -> ScrapeableContent {
        _openSwiftUIUnimplementedFailure()
    }
}

extension ViewGraph {
    final package func scrapeContent() -> ScrapeableContent {
        _openSwiftUIUnimplementedFailure()
    }
}

extension ViewRendererHost {
    package func scrapeContent() -> ScrapeableContent {
        _openSwiftUIUnimplementedFailure()
    }
}

extension ScrapeableContent: CustomStringConvertible {
    private func print(into printer: inout SExpPrinter) {
        _openSwiftUIUnimplementedFailure()
    }

    package var description: String {
        var printer = SExpPrinter(tag: "(scrapeable-content")
        print(into: &printer)
        return printer.end()
    }
}

extension ScrapeableContent.Node: CustomStringConvertible {
    final package var description: String {
        _openSwiftUIUnimplementedFailure()
    }
}

extension ScrapeableContent.Item: CustomStringConvertible {
    package var description: String {
        _openSwiftUIUnimplementedFailure()
    }
}
