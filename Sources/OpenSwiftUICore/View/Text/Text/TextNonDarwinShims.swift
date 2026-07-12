//
//  TextNonDarwinShims.swift
//  OpenSwiftUICore

#if !canImport(Darwin)
public import Foundation
public import UIFoundation_Private

public typealias NSInteger = Int

package class NSParagraphStyle: NSObject {}
package class NSMutableParagraphStyle: NSObject {}
package class TextAttachment: NSObject {}

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
