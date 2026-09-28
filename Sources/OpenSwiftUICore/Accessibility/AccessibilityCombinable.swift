//
//  AccessibilityCombinable.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete

// MARK: - AccessibilityCombinable

package protocol AccessibilityCombinable {
    @discardableResult
    mutating func merge(with child: Self) -> Bool
}

extension AccessibilityCombinable {
    package func combined(with child: Self) -> Self {
        var result = self
        result.merge(with: child)
        return result
    }
}

// MARK: - Optional + AccessibilityCombinable

extension Optional: AccessibilityCombinable where Wrapped: AccessibilityCombinable {
    @discardableResult
    package mutating func merge(with child: Wrapped?) -> Bool {
        switch (self, child) {
        case (_, .none):
            return false
        case (.none, .some):
            self = child
            return true
        case (.some(let lhs), .some(let rhs)):
            var value = lhs
            let result = value.merge(with: rhs)
            self = value
            return result
        }
    }
}

// MARK: - Array + AccessibilityCombinable

extension Array: AccessibilityCombinable {
    @discardableResult
    package mutating func merge(with child: [Element]) -> Bool {
        let oldCount = count
        append(contentsOf: child)
        return count != oldCount
    }
}
