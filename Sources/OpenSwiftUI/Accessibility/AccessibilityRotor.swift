//
//  AccessibilityRotor.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: WIP (TBA)
//  ID: 6BA91B5BDFC0375FD1779AFB4E576D1D (SwiftUI)

import Foundation
import OpenAttributeGraphShims
@_spi(ForOpenSwiftUIOnly)
public import OpenSwiftUICore

// MARK: - AccessibilitySystemRotor

/// Designates a Rotor that replaces one of the automatic, system-provided
/// Rotors with a developer-provided Rotor.
@available(OpenSwiftUI_v3_0, *)
public struct AccessibilitySystemRotor: Sendable {
    enum RawValue: Int, Sendable {
        case links
        case visitedLinks
        case headings
        case headingsLevel1
        case headingsLevel2
        case headingsLevel3
        case headingsLevel4
        case headingsLevel5
        case headingsLevel6
        case boldText
        case italicText
        case underlineText
        case misspelledWords
        case images
        case textFields
        case tables
        case lists
        case landmarks
    }

    var rawValue: RawValue

    /// System Rotors allowing users to iterate through links or visited links.
    public static func links(visited: Bool) -> AccessibilitySystemRotor {
        .init(rawValue: visited ? .visitedLinks : .links)
    }

    /// System Rotor allowing users to iterate through all links.
    public static var links: AccessibilitySystemRotor {
        .init(rawValue: .links)
    }

    /// System Rotors allowing users to iterate through all headings, of various
    /// heading levels.
    public static func headings(level: AccessibilityHeadingLevel) -> AccessibilitySystemRotor {
        .init(rawValue: RawValue(rawValue: Int(level.rawValue) + 2)!)
    }

    /// System Rotor allowing users to iterate through all headings.
    public static var headings: AccessibilitySystemRotor {
        .init(rawValue: .headings)
    }

    /// System Rotor allowing users to iterate through all the ranges of
    /// bolded text.
    public static var boldText: AccessibilitySystemRotor {
        .init(rawValue: .boldText)
    }

    /// System Rotor allowing users to iterate through all the ranges of
    /// italicized text.
    public static var italicText: AccessibilitySystemRotor {
        .init(rawValue: .italicText)
    }

    /// System Rotor allowing users to iterate through all the ranges of
    /// underlined text.
    public static var underlineText: AccessibilitySystemRotor {
        .init(rawValue: .underlineText)
    }

    /// System Rotor allowing users to iterate through all the ranges of
    /// mis-spelled words.
    public static var misspelledWords: AccessibilitySystemRotor {
        .init(rawValue: .misspelledWords)
    }

    /// System Rotor allowing users to iterate through all images.
    public static var images: AccessibilitySystemRotor {
        .init(rawValue: .images)
    }

    /// System Rotor allowing users to iterate through all text fields.
    public static var textFields: AccessibilitySystemRotor {
        .init(rawValue: .textFields)
    }

    /// System Rotor allowing users to iterate through all tables.
    public static var tables: AccessibilitySystemRotor {
        .init(rawValue: .tables)
    }

    /// System Rotor allowing users to iterate through all lists.
    public static var lists: AccessibilitySystemRotor {
        .init(rawValue: .lists)
    }

    /// System Rotor allowing users to iterate through all landmarks.
    public static var landmarks: AccessibilitySystemRotor {
        .init(rawValue: .landmarks)
    }
}

// MARK: - AccessibilityLinkElement

protocol AccessibilityLinkElement: AnyObject {
    var node: AccessibilityNode? { get }
    var range: NSRange { get }
}

// MARK: - AccessibilityLinkRotorBridge

protocol AccessibilityLinkRotorBridge: AnyObject {
    var node: AccessibilityNode? { get }
    var paragraphHash: Int { get set }
    var elements: [any AccessibilityLinkElement] { get set }

    static func linkElement(for node: AccessibilityNode, range: NSRange) -> any AccessibilityLinkElement
    func search(parameters: AccessibilityLinkRotorSearchParameters) -> (any AccessibilityLinkElement)?
    func update()
}

extension AccessibilityLinkRotorBridge {
    func search(parameters: AccessibilityLinkRotorSearchParameters) -> (any AccessibilityLinkElement)? {
        guard let current = parameters.currentElement,
              let index = elements.firstIndex(where: { $0 === current }) else {
            return parameters.isForward ? elements.first : elements.last
        }
        let nextIndex = parameters.isForward ? index + 1 : index - 1
        guard elements.indices.contains(nextIndex) else {
            return nil
        }
        return elements[nextIndex]
    }

    func update() {
        guard let node, let paragraph = node.resolvedAttributedLabel else {
            elements = []
            return
        }
        let hash = paragraph.hashValue
        guard hash != paragraphHash else {
            return
        }
        paragraphHash = hash
        elements.removeAll(keepingCapacity: true)
        paragraph.enumerateAttribute(.coreAXLink, in: NSRange(location: 0, length: paragraph.length)) { value, range, _ in
            if value as? Bool == true {
                elements.append(Self.linkElement(for: node, range: range))
            }
        }
    }
}

struct AccessibilityLinkRotorSearchParameters {
    var currentElement: (any AccessibilityLinkElement)?
    var isForward: Bool
}

// MARK: - AccessibilityRotorInfo [TBA]

struct AccessibilityRotorInfo {
    enum Designation {
        case user(Text)
        case system(AccessibilitySystemRotor)

        func uniqueID(in environment: EnvironmentValues) -> String {
            switch self {
            case let .user(label):
                "user_\(label.resolveString(in: environment, with: .includeAccessibility, idiom: nil))"
            case let .system(system):
                "system_\(system.rawValue)"
            }
        }
    }

    var designation: Designation
    var entries: WeakAttribute<AccessibilityRotorEntryList>?
    var id: Int?
}
