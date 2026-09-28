//
//  AccessibilityIdentifierStorage.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete

// MARK: - AccessibilityIdentifierStorage

package struct AccessibilityIdentifierStorage: Equatable {
    package enum Placement: Equatable {
        case assign
        case optional
        case suffix
    }

    let rawValue: String

    package let placement: Placement

    package init(_ value: String, placement: Placement = .assign) {
        rawValue = value
        self.placement = placement
    }

    package var value: String? {
        switch placement {
        case .assign, .optional:
            rawValue
        case .suffix:
            nil
        }
    }
}

// MARK: - AccessibilityIdentifierStorage + AccessibilityCombinable

extension AccessibilityIdentifierStorage: AccessibilityCombinable {
    package mutating func merge(with child: AccessibilityIdentifierStorage) -> Bool {
        switch (placement, child.placement) {
        case (.optional, .assign), (.optional, .suffix), (.suffix, .assign):
            self = child
            return true
        case (.assign, .suffix), (.suffix, .suffix):
            self = [self, child].joined() ?? self
            return true
        default:
            return false
        }
    }
}

// MARK: - RangeReplaceableCollection + AccessibilityIdentifierStorage

extension RangeReplaceableCollection where Element == AccessibilityIdentifierStorage {
    package func joined(separator: String = ".") -> AccessibilityIdentifierStorage? {
        let values = map { $0.rawValue }.filter { !$0.isEmpty }
        guard !values.isEmpty else {
            return nil
        }
        return AccessibilityIdentifierStorage(values.joined(separator: separator))
    }
}
