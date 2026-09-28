//
//  AccessibilityVisibility.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete

package struct AccessibilityVisibility: OptionSet, Hashable, Codable {
    package enum Resolved: Int, Codable {
        case element
        case containerElement
        case container
        case hidden
    }

    package let rawValue: UInt32

    package init(rawValue: UInt32) {
        self.rawValue = rawValue
    }

    package static let element = Self(rawValue: 1 << 0)
    package static let container = Self(rawValue: 1 << 1)
    package static let hidden = Self(rawValue: 1 << 2)
    package static let transparent = Self(rawValue: 1 << 3)
    package static let ignored = Self(rawValue: 1 << 4)
    package static let host = Self(rawValue: 1 << 5)
    package static let childrenIgnored = Self(rawValue: 1 << 6)
    package static let stack = Self(rawValue: 1 << 7)
}

extension AccessibilityVisibility {
    package static var `default`: Self { [] }

    package static var containerElement: Self { [.element, .container] }
}

extension AccessibilityVisibility {
    package init(_ value: Resolved) {
        switch value {
        case .element: self = .element
        case .containerElement: self = .containerElement
        case .container: self = .container
        case .hidden: self = .hidden
        }
    }
}

package typealias AccessibilityVisibilityStorage = AccessibilityNullableOptionSet<AccessibilityVisibility>

extension AccessibilityNullableOptionSet where T == AccessibilityVisibility {
    package var resolvesToHidden: Bool {
        self[.hidden] ?? value.contains(.transparent)
    }

    package var resolved: AccessibilityVisibility.Resolved? {
        if resolvesToHidden {
            return .hidden
        } else if value.contains(.ignored) {
            return .container
        } else if value.contains(.childrenIgnored) {
            return .element
        } else if value.contains(.element) {
            return value.contains(.container) ? .containerElement : .element
        } else if value.contains(.container) {
            return .container
        } else {
            return nil
        }
    }

    package var shouldApplyPlatformElementOverride: (isAXElement: Bool, isAXElementsHidden: Bool) {
        let specified = value.union(mask)
        return (
            specified.contains(.element) || specified.contains(.container) || resolvesToHidden,
            !specified.intersection([.hidden, .transparent]).isEmpty
        )
    }
}
