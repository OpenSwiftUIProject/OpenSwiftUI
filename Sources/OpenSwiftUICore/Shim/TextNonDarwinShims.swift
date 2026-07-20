//
//  TextNonDarwinShims.swift
//  OpenSwiftUICore

#if !canImport(Darwin)
public import Foundation
public import UIFoundation_Private

public typealias NSInteger = Int

class NSStringDrawingContext: NSObject {
    var wrapsForTruncationMode = false
    var wantsBaselineOffset = false
    var wantsScaledLineHeight = false
    var wantsScaledBaselineOffset = false
    var cachesLayout = false
}

package enum NSWritingDirection: Int {
    case natural = -1
    case leftToRight = 0
    case rightToLeft = 1
}

package enum NSLineBreakMode: Int {
    case byWordWrapping = 0
    case byCharWrapping
    case byClipping
    case byTruncatingHead
    case byTruncatingTail
    case byTruncatingMiddle
}

package class NSParagraphStyle: NSObject {
    fileprivate var _compositionLanguage: NSCompositionLanguage = .unset
    fileprivate var _fullyJustified = false
    fileprivate var _baseWritingDirection: NSWritingDirection = .natural
    fileprivate var _lineBreakMode: NSLineBreakMode = .byWordWrapping
}

extension NSParagraphStyle {
    package var compositionLanguage: NSCompositionLanguage {
        get { _compositionLanguage }
        set { _compositionLanguage = newValue }
    }

    package var fullyJustified: Bool {
        get { _fullyJustified }
        set { _fullyJustified = newValue }
    }

    package var baseWritingDirection: NSWritingDirection {
        get { _baseWritingDirection }
        set { _baseWritingDirection = newValue }
    }

    package var lineBreakMode: NSLineBreakMode {
        get { _lineBreakMode }
        set { _lineBreakMode = newValue }
    }
}

package class NSMutableParagraphStyle: NSParagraphStyle {}

package class NSTextAttachment: NSObject {
    override init() {
        super.init()
    }

    package init(data: Data?, ofType: String?) {
        super.init()
    }

    package var accessibilityLabel: String?
}

extension NSMutableAttributedString {
    package var isEmptyOrTerminatedByParagraphSeparator: Bool {
        false
    }
}

package class NSTextLineFragment: NSObject {
    package init(attributedString: NSAttributedString, range: NSRange) {
        self.attributedString = attributedString
        self.range = range
    }

    private(set) package var attributedString: NSAttributedString
    private var range: NSRange
}

extension NSAttributedString {
    // Work around https://github.com/swiftlang/swift/issues/71874.
    @_nonoverride
    public convenience init() {
        self.init(string: "")
    }

    public convenience init(_ attributedString: AttributedString) {
        self.init(string: String(attributedString))
    }
}

extension NSAttributedString.Key {
    public static let inlinePresentationIntent: NSAttributedString.Key = .init("NSInlinePresentationIntent")

    public static let languageIdentifier: NSAttributedString.Key = .init("NSLanguage")
}

extension InlinePresentationIntent: @retroactive Hashable {
    public func hash(into hasher: inout Hasher) {
        rawValue.hash(into: &hasher)
    }
}

extension AttributeScopes.FoundationAttributes {
    public var inlinePresentationIntent: AttributeScopes.FoundationAttributes.InlinePresentationIntentAttribute {
        get {
            _openSwiftUIUnreachableCode()
        }
    }

    @frozen public enum InlinePresentationIntentAttribute: CodableAttributedStringKey {
        public typealias Value = InlinePresentationIntent
        public static let name: String = "NSInlinePresentationIntent"

        public static func decode(from decoder: any Decoder) throws -> Value {
            let container = try decoder.singleValueContainer()
            return Value(rawValue: try container.decode(Value.RawValue.self))
        }

        public static func encode(_ value: Value, to encoder: any Encoder) throws {
            var container = encoder.singleValueContainer()
            try container.encode(value.rawValue)
        }
    }
}

#endif
