//
//  NSAttributedString+ExtensionTests.swift
//  OpenSwiftUICoreTests

import Foundation
@testable import OpenSwiftUICore
import Testing
import UIFoundation_Private

private let keyA: NSAttributedString.Key = .init("OpenSwiftUITests.A")
private let keyB: NSAttributedString.Key = .init("OpenSwiftUITests.B")

private func paragraphStyle(_ mode: NSLineBreakMode) -> NSParagraphStyle {
    let style = NSMutableParagraphStyle()
    style.lineBreakMode = mode
    return style
}

struct NSAttributedString_ExtensionTests {

    // MARK: - range

    @Test
    func range() {
        #expect(NSAttributedString(string: "").range == NSRange(location: 0, length: 0))
        #expect(NSAttributedString(string: "Hello").range == NSRange(location: 0, length: 5))
    }

    // MARK: - firstAttribute

    @Test
    func firstAttributeReturnsNilWhenAbsent() {
        let string = NSAttributedString(string: "Hello")
        #expect(string.firstAttribute(Int.self, name: keyA) == nil)
    }

    @Test
    func firstAttributeSkipsMismatchedType() {
        let string = NSMutableAttributedString(string: "Hello")
        string.addAttribute(keyA, value: "text", range: NSRange(location: 0, length: 2))
        #expect(string.firstAttribute(Int.self, name: keyA) == nil)
        #expect(string.firstAttribute(String.self, name: keyA) == "text")
    }

    @Test
    func firstAttributeReturnsEarliestValue() {
        let string = NSMutableAttributedString(string: "Hello")
        string.addAttribute(keyA, value: 1, range: NSRange(location: 1, length: 1))
        string.addAttribute(keyA, value: 2, range: NSRange(location: 3, length: 1))
        #expect(string.firstAttribute(Int.self, name: keyA) == 1)
    }

    // MARK: - replacingLineBreakModes

    @Test
    func replacingLineBreakModesWithoutParagraphStyle() {
        let string = NSAttributedString(string: "Hello")
        #expect(string.replacingLineBreakModes(.byClipping) === string)
    }

    @Test
    func replacingLineBreakModesWithMatchingMode() {
        let string = NSMutableAttributedString(string: "Hello")
        string.addAttribute(.kitParagraphStyle, value: paragraphStyle(.byClipping), range: string.range)
        #expect(string.replacingLineBreakModes(.byClipping) === string)
    }

    @Test
    func replacingLineBreakModesUpdatesMatchingRanges() {
        let string = NSMutableAttributedString(string: "Hello")
        string.addAttribute(
            .kitParagraphStyle,
            value: paragraphStyle(.byWordWrapping),
            range: NSRange(location: 0, length: 2)
        )
        string.addAttribute(
            .kitParagraphStyle,
            value: paragraphStyle(.byClipping),
            range: NSRange(location: 2, length: 3)
        )
        let result = string.replacingLineBreakModes(.byTruncatingTail)
        #expect(result !== string)
        #expect(result.string == "Hello")
        let runs = result.runs()
        let modes = runs.compactMap { run in
            (run.attributes[.kitParagraphStyle] as? NSParagraphStyle)?.lineBreakMode
        }
        #expect(modes.count == runs.count)
        #expect(modes.allSatisfy { $0 == .byTruncatingTail })
        // The receiver is left untouched.
        let style = string.firstAttribute(NSParagraphStyle.self, name: .kitParagraphStyle)
        #expect(style?.lineBreakMode == .byWordWrapping)
    }

    // MARK: - addUniformAttribute

    @Test
    func addUniformAttributes() {
        let string = NSMutableAttributedString(string: "Hello")
        string.addUniformAttribute(keyA, value: 1)
        string.addUniformAttributes([keyB: 2])
        let runs = string.runs()
        #expect(runs.count == 1)
        #expect(runs[0].range == string.range)
        #expect(runs[0].attributes[keyA] as? Int == 1)
        #expect(runs[0].attributes[keyB] as? Int == 2)
    }

    // MARK: - mergeAttributes

    @Test
    func mergeAttributesWithEmptyRange() {
        let string = NSMutableAttributedString(string: "Hello")
        string.mergeAttributes([keyA: 1], in: NSRange(location: 0, length: 0))
        #expect(string.runs().count == 1)
        #expect(string.runs()[0].attributes.isEmpty)
    }

    @Test
    func mergeAttributesPreservesExistingAttributes() {
        let string = NSMutableAttributedString(string: "Hello")
        string.addAttribute(keyA, value: 1, range: NSRange(location: 0, length: 2))
        string.mergeAttributes([keyB: 2])
        let runs = string.runs()
        #expect(runs.count == 2)
        #expect(runs[0].range == NSRange(location: 0, length: 2))
        #expect(runs[0].attributes[keyA] as? Int == 1)
        #expect(runs[0].attributes[keyB] as? Int == 2)
        #expect(runs[1].range == NSRange(location: 2, length: 3))
        #expect(runs[1].attributes[keyA] == nil)
        #expect(runs[1].attributes[keyB] as? Int == 2)
    }

    @Test
    func mergeAttributesInSubrange() {
        let string = NSMutableAttributedString(string: "Hello")
        string.mergeAttributes([keyA: 1], in: NSRange(location: 1, length: 2))
        let runs = string.runs()
        #expect(runs.count == 3)
        #expect(runs[1].range == NSRange(location: 1, length: 2))
        #expect(runs[1].attributes[keyA] as? Int == 1)
    }

    // MARK: - runs

    @Test
    func runs() {
        let string = NSMutableAttributedString(string: "Hello")
        string.addAttribute(keyA, value: 1, range: NSRange(location: 0, length: 3))
        let all = string.runs()
        #expect(all.map(\.range) == [NSRange(location: 0, length: 3), NSRange(location: 3, length: 2)])
        let partial = string.runs(in: NSRange(location: 2, length: 2))
        #expect(partial.map(\.range) == [NSRange(location: 2, length: 1), NSRange(location: 3, length: 1)])
    }
}
