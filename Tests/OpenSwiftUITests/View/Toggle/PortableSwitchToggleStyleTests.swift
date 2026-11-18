//
//  PortableSwitchToggleStyleTests.swift
//  OpenSwiftUITests

#if UIKIT_CROSS_PLATFORM
import OpenAttributeGraphShims
@testable import OpenSwiftUI
import OpenSwiftUITestsSupport
import Testing

@MainActor
@Suite(.disabled(if: attributeGraphVendor == .oag))
struct PortableSwitchToggleStyleTests {
    @Test(arguments: [false, true], [false, true])
    func defaultAndExplicitSwitchRenderState(isOn: Bool, explicitStyle: Bool) {
        let displayList = DisplayListUtil.renderDisplayList(
            toggle(isOn: isOn, explicitStyle: explicitStyle)
        )

        #expect(DisplayListUtil.containsColor("#FFFFFFFF", in: displayList))
        #expect(DisplayListUtil.containsColor("#00FF00FF", in: displayList) == isOn)
    }

    @Test(arguments: [false, true])
    func hiddenLabelsAreNotRendered(explicitStyle: Bool) {
        let content = toggle(isOn: false, explicitStyle: explicitStyle)
        let visible = DisplayListUtil.renderDisplayList(content)
        let hidden = DisplayListUtil.renderDisplayList(content.labelsHidden())

        #expect(DisplayListUtil.containsColor("#FF0000FF", in: visible))
        #expect(!DisplayListUtil.containsColor("#FF0000FF", in: hidden))
        #expect(DisplayListUtil.containsColor("#FFFFFFFF", in: hidden))
    }

    private func toggle(isOn: Bool, explicitStyle: Bool) -> some View {
        styledToggle(isOn: isOn, explicitStyle: explicitStyle)
            .tint(Color(red: 0, green: 1, blue: 0))
            .frame(width: 120)
    }

    @ViewBuilder
    private func styledToggle(isOn: Bool, explicitStyle: Bool) -> some View {
        let toggle = Toggle(isOn: .constant(isOn)) {
            Color(red: 1, green: 0, blue: 0)
                .frame(width: 8, height: 8)
        }
        if explicitStyle {
            toggle.toggleStyle(.switch)
        } else {
            toggle
        }
    }
}
#endif
