//
//  AccessibilityCustomAttributes.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: BF898C2367FAF9E98D04BBAD3CB75E24 (SwiftUICore)

package import Foundation

package struct AccessibilityCustomAttributes: Equatable {
    package enum Value: Equatable {
        case string(String)
        case data(Data)
        case nsNumber(NSNumber)
        case nsValue(NSValue)
        case date(Date)
        case url(URL)
        case attributedString(NSAttributedString)
        case object(NSObject)

        package var displayDescription: String {
            switch self {
            case let .string(value): value
            case let .data(value): value.description
            case let .nsNumber(value): value.stringValue
            case let .nsValue(value): value.description
            case let .date(value): value.description
            case let .url(value): value.absoluteString
            case let .attributedString(value): value.string
            case let .object(value): value.description
            }
        }

        package func axRepresentation() -> Any {
            switch self {
            case let .string(value): value as NSString
            case let .data(value): value as NSData
            case let .nsNumber(value): value
            case let .nsValue(value): value
            case let .date(value): value as NSDate
            case let .url(value): value as NSURL
            case let .attributedString(value): value
            case let .object(value): value
            }
        }
    }

    package init() {
        attributes = [:]
    }

    package init(_ attributeName: String, value: Value) {
        attributes = [attributeName: value]
    }

    private var attributes: AttributesDictionary

    package typealias AttributesDictionary = [String: Value]

    package var attributeNames: [String] {
        Array(attributes.keys)
    }

    package subscript(_ attributeName: String) -> Value? {
        get { attributes[attributeName] }
        set { attributes[attributeName] = newValue }
    }

    package static func == (lhs: Self, rhs: Self) -> Bool {
        guard lhs.attributes.count == rhs.attributes.count else {
            return false
        }
        for (name, value) in lhs.attributes {
            guard let other = rhs.attributes[name], value == other else {
                return false
            }
        }
        return true
    }
}

extension AccessibilityCustomAttributes: Collection {
    package typealias Index = AttributesDictionary.Index
    package typealias Element = AttributesDictionary.Element

    package var startIndex: Index { attributes.startIndex }
    package var endIndex: Index { attributes.endIndex }

    package subscript(index: Index) -> Element {
        attributes[index]
    }

    package func index(after index: Index) -> Index {
        attributes.index(after: index)
    }
}

extension AccessibilityCustomAttributes: CustomDebugStringConvertible {
    package var debugDescription: String {
        var result = "<"
        for (name, value) in attributes {
            result += "\(name): \(value)"
        }
        result += ">"
        return result
    }
}

extension AccessibilityCustomAttributes: AccessibilityCombinable {
    @discardableResult
    package mutating func merge(with child: Self) -> Bool {
        var changed = false
        for (name, value) in child.attributes where attributes[name] == nil {
            attributes[name] = value
            changed = true
        }
        return changed
    }
}

extension AccessibilityCustomAttributes.Value: Codable {
    private enum CodingKeys: String, CodingKey {
        case string
        case data
        case nsNumber
        case nsValue
        case date
        case url
        case attributedString
    }

    package init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let value = try? container.decode(String.self, forKey: .string) {
            self = .string(value)
        } else if let value = try? container.decode(Data.self, forKey: .data) {
            self = .data(value)
        } else if let data = try? container.decode(Data.self, forKey: .nsNumber) {
            let unarchiver = try NSKeyedUnarchiver(forReadingFrom: data)
            guard let value = unarchiver.decodeObject(forKey: CodingKeys.nsNumber.rawValue) as? NSNumber else {
                throw DecodingError.typeMismatch(
                    NSNumber.self,
                    .init(codingPath: decoder.codingPath, debugDescription: "Could not decode number!")
                )
            }
            self = .nsNumber(value)
        } else if let data = try? container.decode(Data.self, forKey: .nsValue) {
            let unarchiver = try NSKeyedUnarchiver(forReadingFrom: data)
            guard let value = unarchiver.decodeObject(forKey: CodingKeys.nsValue.rawValue) as? NSValue else {
                throw DecodingError.typeMismatch(
                    NSValue.self,
                    .init(codingPath: decoder.codingPath, debugDescription: "Could not decode value!")
                )
            }
            self = .nsValue(value)
        } else if let value = try? container.decode(Date.self, forKey: .date) {
            self = .date(value)
        } else if let value = try? container.decode(URL.self, forKey: .url) {
            self = .url(value)
        } else if let data = try? container.decode(Data.self, forKey: .attributedString) {
            let unarchiver = try NSKeyedUnarchiver(forReadingFrom: data)
            guard let value = unarchiver.decodeObject(forKey: CodingKeys.attributedString.rawValue) as? NSAttributedString else {
                throw DecodingError.typeMismatch(
                    NSAttributedString.self,
                    .init(codingPath: decoder.codingPath, debugDescription: "Could not decode attributed string!")
                )
            }
            self = .attributedString(value)
        } else {
            throw DecodingError.typeMismatch(
                AccessibilityCustomAttributes.self,
                .init(codingPath: decoder.codingPath, debugDescription: "Could not decode custom attributes!")
            )
        }
    }

    package func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case let .string(value):
            try container.encode(value, forKey: .string)
        case let .data(value):
            try container.encode(value, forKey: .data)
        case let .nsNumber(value):
            let archiver = NSKeyedArchiver(requiringSecureCoding: true)
            archiver.encode(value, forKey: CodingKeys.nsNumber.rawValue)
            try container.encode(archiver.encodedData, forKey: .nsNumber)
        case let .nsValue(value):
            let archiver = NSKeyedArchiver(requiringSecureCoding: true)
            archiver.encode(value, forKey: CodingKeys.nsValue.rawValue)
            try container.encode(archiver.encodedData, forKey: .nsValue)
        case let .date(value):
            try container.encode(value, forKey: .date)
        case let .url(value):
            try container.encode(value, forKey: .url)
        case let .attributedString(value):
            let archiver = NSKeyedArchiver(requiringSecureCoding: true)
            archiver.encode(value, forKey: CodingKeys.attributedString.rawValue)
            try container.encode(archiver.encodedData, forKey: .attributedString)
        case .object:
            break
        }
    }
}

extension AccessibilityCustomAttributes: Codable {}
