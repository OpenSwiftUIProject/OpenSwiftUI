//
//  LinkTests.swift
//  OpenSwiftUITests

import Foundation
@_spi(Private) @testable import OpenSwiftUI
import Testing

@MainActor
@Suite(.tags(.aigc))
struct LinkTests {
    private let url = URL(string: "https://example.com/link")!

    @Test
    func textInitializers() {
        let title = "Open link"
        #expect(Link("Open link", destination: url).label == Text("Open link"))
        #expect(Link(title, destination: url).label == Text(verbatim: title))
        #expect(Link(title.dropFirst(5), destination: url).label == Text(verbatim: "link"))
        #expect(Link("Open link", sensitiveUrl: url).label == Text("Open link"))
        #expect(Link(title, sensitiveUrl: url).label == Text(verbatim: title))
    }

    @Test(arguments: [false, true])
    func labelBuilderRunsOnce(isSensitive: Bool) {
        var calls = 0
        let label = { calls += 1; return Text(verbatim: "Label") }
        let link = isSensitive
            ? Link(sensitiveUrl: url, label: label)
            : Link(destination: url, label: label)
        #expect(calls == 1)
        #expect(link.destination.configuration.url == url)
        #expect(link.destination.configuration.isSensitive == isSensitive)
    }

    @Test(arguments: [false, true])
    func liveAccessibility(isSensitive: Bool) throws {
        let link = isSensitive
            ? Link(sensitiveUrl: url) { EmptyView() }
            : Link(destination: url) { EmptyView() }
        let attachment = try accessibilityAttachment(in: link.body)
        let properties = attachment.storage.value.properties
        #expect(properties.linkDestination?.url == url)
        #expect(properties.linkDestination?.isSensitive == isSensitive)
        #expect(properties.traits[.isLink] == true)
        #expect(attachment.behavior == nil)
    }

    @Test
    func archivedAccessibility() throws {
        let link = Link(destination: url) { EmptyView() }
        let attachment = try accessibilityAttachment(in: link.archivedBody)
        let properties = attachment.storage.value.properties
        #expect(properties.linkDestination == nil)
        #expect(properties.traits[.isButton] == true)
        #expect(properties.traits[.isLink] == false)
        #expect(attachment.behavior != nil)
    }

    @Test(arguments: [false, true])
    func archiveConfiguration(isSensitive: Bool) throws {
        let modifier = ArchivableLinkModifier(configuration: .init(url: url, isSensitive: isSensitive))
        let data = try JSONEncoder().encode(modifier)
        let object = try #require(JSONSerialization.jsonObject(with: data) as? [String: Any])
        let configuration = try #require(object["configuration"] as? [String: Any])
        #expect(configuration["url"] as? String == "https://example.com/link")
        #expect(configuration["isSensitive"] as? Bool == isSensitive)
        let decoded = try JSONDecoder().decode(ArchivableLinkModifier.self, from: data)
        #expect(decoded.configuration.url == url)
        #expect(decoded.configuration.isSensitive == isSensitive)
    }

    private func accessibilityAttachment(in view: some View) throws -> AccessibilityAttachmentModifier {
        let mirror = Mirror(reflecting: view)
        let storage = try #require(mirror.descendant("storage") ?? mirror.descendant("content", "storage"))
        let branch = try #require(Mirror(reflecting: storage).children.first?.value)
        return try #require(Mirror(reflecting: branch).descendant("modifier") as? AccessibilityAttachmentModifier)
    }
}
