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
    func isBeginningOfSentence() {
        let string = "Hello world. Second sentence."
        let locale = Locale(identifier: "en_US")
        #expect(_isBeginningOfSentence(string, "HELLO", locale) == true)
        #expect(_isBeginningOfSentence(string, "WORLD", locale) == false)
        #expect(_isBeginningOfSentence(string, "SECOND", locale) == true)
        #expect(_isBeginningOfSentence(string, "MISSING", locale) == false)
    }
}
#endif
