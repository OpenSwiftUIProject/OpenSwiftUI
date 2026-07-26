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

package enum NSTextHorizontalAlignment: Int {
    case natural = 0
    case left = 2
    case right = 3
    case center = 4
}

package struct NSLineBreakStrategy: OptionSet {
    package let rawValue: UInt

    package init(rawValue: UInt) {
        self.rawValue = rawValue
    }

    package static let pushOut = NSLineBreakStrategy(rawValue: 1 << 0)

    package static let hangulWordPriority = NSLineBreakStrategy(rawValue: 1 << 1)

    package static let standard = NSLineBreakStrategy(rawValue: 0xFFFF)
}

package class NSParagraphStyle: NSObject, NSCopying, NSMutableCopying {
    fileprivate var _compositionLanguage: NSCompositionLanguage = .unset
    fileprivate var _fullyJustified = false
    fileprivate var _spansAllLines = false
    fileprivate var _baseWritingDirection: NSWritingDirection = .natural
    fileprivate var _horizontalAlignment: NSTextHorizontalAlignment = .natural
    fileprivate var _lineBreakMode: NSLineBreakMode = .byWordWrapping
    fileprivate var _secondaryLineBreakMode: NSLineBreakMode = .byWordWrapping
    fileprivate var _lineBreakStrategy: NSLineBreakStrategy = []
    fileprivate var _lineSpacing: CGFloat = .zero
    fileprivate var _lineHeightMultiple: CGFloat = .zero
    fileprivate var _maximumLineHeight: CGFloat = .zero
    fileprivate var _minimumLineHeight: CGFloat = .zero
    fileprivate var _firstLineHeadIndent: CGFloat = .zero
    fileprivate var _hyphenationFactor: Float = .zero
    fileprivate var _allowsDefaultTighteningForTruncation = false

    fileprivate func copyProperties(from other: NSParagraphStyle) {
        _compositionLanguage = other._compositionLanguage
        _fullyJustified = other._fullyJustified
        _spansAllLines = other._spansAllLines
        _baseWritingDirection = other._baseWritingDirection
        _horizontalAlignment = other._horizontalAlignment
        _lineBreakMode = other._lineBreakMode
        _secondaryLineBreakMode = other._secondaryLineBreakMode
        _lineBreakStrategy = other._lineBreakStrategy
        _lineSpacing = other._lineSpacing
        _lineHeightMultiple = other._lineHeightMultiple
        _maximumLineHeight = other._maximumLineHeight
        _minimumLineHeight = other._minimumLineHeight
        _firstLineHeadIndent = other._firstLineHeadIndent
        _hyphenationFactor = other._hyphenationFactor
        _allowsDefaultTighteningForTruncation = other._allowsDefaultTighteningForTruncation
    }

    package func copy(with zone: NSZone? = nil) -> Any {
        let style = NSParagraphStyle()
        style.copyProperties(from: self)
        return style
    }

    package func mutableCopy(with zone: NSZone? = nil) -> Any {
        let style = NSMutableParagraphStyle()
        style.copyProperties(from: self)
        return style
    }
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

    package var spansAllLines: Bool {
        get { _spansAllLines }
        set { _spansAllLines = newValue }
    }

    package var baseWritingDirection: NSWritingDirection {
        get { _baseWritingDirection }
        set { _baseWritingDirection = newValue }
    }

    package var horizontalAlignment: NSTextHorizontalAlignment {
        get { _horizontalAlignment }
        set { _horizontalAlignment = newValue }
    }

    package var lineBreakMode: NSLineBreakMode {
        get { _lineBreakMode }
        set { _lineBreakMode = newValue }
    }

    package var secondaryLineBreakMode: NSLineBreakMode {
        get { _secondaryLineBreakMode }
        set { _secondaryLineBreakMode = newValue }
    }

    package var lineBreakStrategy: NSLineBreakStrategy {
        get { _lineBreakStrategy }
        set { _lineBreakStrategy = newValue }
    }

    package var lineSpacing: CGFloat {
        get { _lineSpacing }
        set { _lineSpacing = newValue }
    }

    package var lineHeightMultiple: CGFloat {
        get { _lineHeightMultiple }
        set { _lineHeightMultiple = newValue }
    }

    package var maximumLineHeight: CGFloat {
        get { _maximumLineHeight }
        set { _maximumLineHeight = newValue }
    }

    package var minimumLineHeight: CGFloat {
        get { _minimumLineHeight }
        set { _minimumLineHeight = newValue }
    }

    package var firstLineHeadIndent: CGFloat {
        get { _firstLineHeadIndent }
        set { _firstLineHeadIndent = newValue }
    }

    package var hyphenationFactor: Float {
        get { _hyphenationFactor }
        set { _hyphenationFactor = newValue }
    }

    package var allowsDefaultTighteningForTruncation: Bool {
        get { _allowsDefaultTighteningForTruncation }
        set { _allowsDefaultTighteningForTruncation = newValue }
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
