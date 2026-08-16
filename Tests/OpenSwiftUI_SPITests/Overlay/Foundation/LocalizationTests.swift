//
//  LocalizationTests.swift
//  OpenSwiftUI_SPITests
//

#if canImport(Darwin)
import Foundation
import OpenSwiftUI_SPI
import Testing

struct LocalizationTests {
    @Test
    func localizedString() throws {
        let (bundle, bundleURL) = try makeLocalizationBundle()
        defer {
            try? FileManager.default.removeItem(at: bundleURL)
        }

        #expect(
            _LocalizeString(
                bundle,
                "GREETING",
                nil,
                Locale(identifier: "en_US")
            ) == "Hello"
        )
        #expect(
            _LocalizeString(
                bundle,
                "GREETING",
                nil,
                Locale(identifier: "fr_FR")
            ) == "Bonjour"
        )
        #expect(
            _LocalizeString(
                bundle,
                "TABLE_VALUE",
                "Alternate",
                Locale(identifier: "en_US")
            ) == "Alternate value"
        )
    }

    @Test
    func localizedAttributedString() throws {
        let (bundle, bundleURL) = try makeLocalizationBundle()
        defer {
            try? FileManager.default.removeItem(at: bundleURL)
        }

        let string = _LocalizeAttributedString(
            bundle,
            "GREETING",
            nil,
            Locale(identifier: "fr_FR")
        )
        #expect(string.string == "Bonjour")
    }

    @Test
    func isBeginningOfSentence() {
        let string = "Hello world. Second sentence."
        let locale = Locale(identifier: "en_US")
        #expect(_isBeginningOfSentence(string, "HELLO", locale) == true)
        #expect(_isBeginningOfSentence(string, "WORLD", locale) == false)
        #expect(_isBeginningOfSentence(string, "SECOND", locale) == true)
        #expect(_isBeginningOfSentence(string, "MISSING", locale) == false)
        #expect(_isBeginningOfSentence(string, "HELLO", nil) == true)
    }

    private func makeLocalizationBundle() throws -> (Bundle, URL) {
        let identifier = UUID().uuidString
        let bundleURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(identifier)
            .appendingPathExtension("bundle")
        let englishURL = bundleURL.appendingPathComponent("en.lproj")
        let frenchURL = bundleURL.appendingPathComponent("fr.lproj")
        try FileManager.default.createDirectory(
            at: englishURL,
            withIntermediateDirectories: true
        )
        try FileManager.default.createDirectory(
            at: frenchURL,
            withIntermediateDirectories: true
        )

        let info: [String: Any] = [
            "CFBundleDevelopmentRegion": "en",
            "CFBundleIdentifier": "org.openswiftuiproject.openswiftui.LocalizationTests.\(identifier)",
            "CFBundleName": "LocalizationTests",
            "CFBundlePackageType": "BNDL",
            "CFBundleVersion": "1",
        ]
        let infoData = try PropertyListSerialization.data(
            fromPropertyList: info,
            format: .xml,
            options: 0
        )
        try infoData.write(to: bundleURL.appendingPathComponent("Info.plist"))

        try "\"GREETING\" = \"Hello\";\n".write(
            to: englishURL.appendingPathComponent("Localizable.strings"),
            atomically: true,
            encoding: .utf8
        )
        try "\"GREETING\" = \"Bonjour\";\n".write(
            to: frenchURL.appendingPathComponent("Localizable.strings"),
            atomically: true,
            encoding: .utf8
        )
        try "\"TABLE_VALUE\" = \"Alternate value\";\n".write(
            to: englishURL.appendingPathComponent("Alternate.strings"),
            atomically: true,
            encoding: .utf8
        )

        return (try #require(Bundle(url: bundleURL)), bundleURL)
    }
}
#endif
