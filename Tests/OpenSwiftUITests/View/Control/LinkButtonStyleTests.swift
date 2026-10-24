//
//  LinkButtonStyleTests.swift
//  OpenSwiftUITests

@testable import OpenSwiftUI
import OpenSwiftUITestsSupport
import Testing

@Suite(.tags(.aigc))
@MainActor
struct LinkButtonStyleTests {
    #if os(macOS)
    @Test(arguments: [nil, .cancel, .destructive] as [ButtonRole?])
    func preservesActionAndRoleWithLinkTrait(role: ButtonRole?) throws {
        var triggerCount = 0
        let configuration = PrimitiveButtonStyleConfiguration(
            role: role,
            action: .closure { triggerCount += 1 }
        )
        let style: LinkButtonStyle = .link
        let body = style.makeBody(configuration: configuration)
        typealias AccessibleButton = ModifiedContent<
            Button<PrimitiveButtonStyleConfiguration.Label>,
            AccessibilityAttachmentModifier
        >
        let button = try #require(
            Mirror(reflecting: body).descendant("content", "content") as? AccessibleButton
        )
        #expect(triggerCount == 0)
        #expect(button.content.role == role)
        #expect(button.modifier.storage.value.properties.traits[.isLink] == true)
        button.content.action()
        #expect(triggerCount == 1)
    }
    #endif
}
