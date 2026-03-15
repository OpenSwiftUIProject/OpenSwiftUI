//
//  AccessibilityTechnologies.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: 0590C4C51604B1E3DCF5495DDA9D97C1 (SwiftUI)

// MARK: - AccessibilityTechnologies

/// Accessibility technologies available to the system.
@available(OpenSwiftUI_v3_0, *)
public struct AccessibilityTechnologies: SetAlgebra, Sendable {

    // MARK: - Static Properties

    /// The value that represents the VoiceOver screen reader, allowing use
    /// of the system without seeing the screen visually.
    public static let voiceOver: AccessibilityTechnologies = .init(list: [.voiceOver])

    /// The value that represents a Switch Control, allowing the use of the
    /// entire system using controller buttons, a breath-controlled switch or similar hardware.
    public static let switchControl: AccessibilityTechnologies = .init(list: [.switchControl])

    @_spi(Private)
    public static let fullKeyboardAccess: AccessibilityTechnologies = .init(list: [.fullKeyboardAccess])

    @_spi(Private)
    @available(OpenSwiftUI_v4_0, *)
    public static let voiceControl: AccessibilityTechnologies = .init(list: [.voiceControl])

    @_spi(Private)
    @available(OpenSwiftUI_v5_0, *)
    public static let hoverText: AccessibilityTechnologies = .init(list: [.hoverText])

    static let focusSupportingTechnologies: AccessibilityTechnologies = .init(technologySet: .focusSupportingTechnologies)

    // MARK: - Initializers

    private var technologySet: AccessibilityTechnologySet

    /// Creates a new accessibility technologies structure with an empy accessibility technology set.
    public init() {
        technologySet = []
    }

    package init(list: [AccessibilityTechnology]) {
        var set = AccessibilityTechnologySet()
        for technology in list {
            set.insert(.init(rawValue: 1 << technology.rawValue))
        }
        technologySet = set
    }

    private init(technologySet: AccessibilityTechnologySet) {
        self.technologySet = technologySet
    }

    // MARK: - SetAlgebra

    public func union(_ other: AccessibilityTechnologies) -> AccessibilityTechnologies {
        .init(technologySet: technologySet.union(other.technologySet))
    }

    public mutating func formUnion(_ other: AccessibilityTechnologies) {
        technologySet.formUnion(other.technologySet)
    }

    public func intersection(_ other: AccessibilityTechnologies) -> AccessibilityTechnologies {
        .init(technologySet: technologySet.intersection(other.technologySet))
    }

    public mutating func formIntersection(_ other: AccessibilityTechnologies) {
        technologySet.formIntersection(other.technologySet)
    }

    public func symmetricDifference(_ other: AccessibilityTechnologies) -> AccessibilityTechnologies {
        .init(technologySet: technologySet.symmetricDifference(other.technologySet))
    }

    public mutating func formSymmetricDifference(_ other: AccessibilityTechnologies) {
        technologySet.formSymmetricDifference(other.technologySet)
    }

    public func contains(_ member: AccessibilityTechnologies) -> Bool {
        technologySet.isSuperset(of: member.technologySet)
    }

    @discardableResult
    public mutating func insert(_ newMember: AccessibilityTechnologies) -> (inserted: Bool, memberAfterInsert: AccessibilityTechnologies) {
        let isNew = !technologySet.isSuperset(of: newMember.technologySet)
        technologySet.formUnion(newMember.technologySet)
        return (isNew, .init(technologySet: newMember.technologySet))
    }

    @discardableResult
    public mutating func remove(_ member: AccessibilityTechnologies) -> AccessibilityTechnologies? {
        guard technologySet.isSuperset(of: member.technologySet) else { return nil }
        technologySet.subtract(member.technologySet)
        return member
    }

    @discardableResult
    public mutating func update(with newMember: AccessibilityTechnologies) -> AccessibilityTechnologies? {
        let existing = technologySet.isSuperset(of: newMember.technologySet) ? newMember : nil
        technologySet.formUnion(newMember.technologySet)
        return existing
    }

    // MARK: - Equatable

    public static func == (lhs: AccessibilityTechnologies, rhs: AccessibilityTechnologies) -> Bool {
        lhs.technologySet == rhs.technologySet
    }
}

// MARK: - AccessibilityTechnologySet

private struct AccessibilityTechnologySet: OptionSet, Hashable, Codable {
    package var rawValue: UInt16

    package init(rawValue: UInt16) {
        self.rawValue = rawValue
    }

    var list: [AccessibilityTechnology] {
        AccessibilityTechnology.allCases.filter { technology in
            contains(AccessibilityTechnologySet(rawValue: 1 << technology.rawValue))
        }
    }

    static let focusSupportingTechnologies: AccessibilityTechnologySet = {
        var set = AccessibilityTechnologySet()
        for technology in AccessibilityTechnology.focusSupportingTechnologies {
            set.insert(.init(rawValue: 1 << technology.rawValue))
        }
        return set
    }()

    func assertAllSupportFocus() {
        for technology in list {
            guard technology.rawValue < 2 else {
                Log.runtimeIssues("Technology %@ does not support Accessibility focus!", [String(describing: technology)])
                continue
            }
        }
    }
}

// MARK: - AccessibilityTechnology

/// An assistive access technology.
package enum AccessibilityTechnology: UInt16, CaseIterable, Hashable {
    case voiceOver = 0
    case switchControl = 1
    case fullKeyboardAccess = 2
    case voiceControl = 3
    case hoverText = 4
    case assistiveAccess = 5

    package static let focusSupportingTechnologies: [AccessibilityTechnology] = allCases.filter { $0.rawValue <= 1 }
}
