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
