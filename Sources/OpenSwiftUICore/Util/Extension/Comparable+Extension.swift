//
//  Comparable+Extension.swift
//  OpenSwiftUICore
//
//  Audited for iOS 18.0
//  Status: Complete

extension Comparable {
    @inlinable
    package func clamp(min minValue: Self, max maxValue: Self) -> Self {
        min(max(minValue, self), maxValue)
    }
    
    package mutating func formMin(_ other: Self) {
        self = min(self, other)
    }
    
    package mutating func formMax(_ other: Self) {
        self = max(self, other)
    }
    
    @inlinable
    package mutating func clamp(to limits: ClosedRange<Self>) {
        self = clamp(min: limits.lowerBound, max: limits.upperBound)
    }
    
    @inlinable
    package func clamped(to limits: ClosedRange<Self>) -> Self {
        var result = self
        result.clamp(to: limits)
        return result
    }
}

package func == <A, B, C, D>(
    lhs: ((A, B), (C, D)),
    rhs: ((A, B), (C, D))
) -> Bool where A: Equatable, B: Equatable, C: Equatable, D: Equatable {
    return lhs.0.0 == rhs.0.0 && lhs.0.1 == rhs.0.1 && lhs.1.0 == rhs.1.0 && lhs.1.1 == rhs.1.1
}

package func min<C>(_ a: C, ifPresent b: C?) -> C where C: Comparable {
    guard let b else { return a }
    return Swift.min(a, b)
}

package func max<C>(_ a: C, ifPresent b: C?) -> C where C: Comparable {
    guard let b else { return a }
    return Swift.max(a, b)
}
