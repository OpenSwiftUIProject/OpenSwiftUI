//
//  TextImageTests.swift
//  OpenSwiftUICoreTests

import OpenSwiftUICore
import Testing

struct TextImageTests {
    @Test
    func attachmentParticipatesInEquality() {
        #expect(Text(Image(systemName: "star")) == Text(Image(systemName: "star")))
        #expect(Text(Image(systemName: "star")) != Text(Image(systemName: "circle")))
    }

    @Test
    func attachmentResolvesToObjectReplacementCharacter() {
        let text = Text(Image.redacted)

        #expect(text.resolveString(in: EnvironmentValues()) == "\u{fffc}")
    }

    @Test
    func imageInterpolationUsesAttachmentText() {
        let key: LocalizedStringKey = "Symbol: \(Image.redacted)"
        let text = Text(key)

        #expect(text.resolveString(in: EnvironmentValues()) == "Symbol: \u{fffc}")
    }
}
