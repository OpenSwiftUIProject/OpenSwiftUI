//
//  AnimatableArray.swift
//  OpenSwiftUICore
//
//  Audited for 6.0.87
//  Status: Complete

package struct AnimatableArray<Element>: VectorArithmetic where Element: VectorArithmetic {
    package var elements: [Element]
    
    package init(_ elements: [Element]) {
        self.elements = elements
    }
    
    package static var zero: AnimatableArray<Element> { .init([]) }
    
    package static func += (lhs: inout AnimatableArray<Element>, rhs: AnimatableArray<Element>) {
        let count = Swift.min(lhs.elements.count, rhs.elements.count)
        for i in 0..<count {
            lhs.elements[i] += rhs.elements[i]
        }
    }
    
    package static func -= (lhs: inout AnimatableArray<Element>, rhs: AnimatableArray<Element>) {
        let count = Swift.min(lhs.elements.count, rhs.elements.count)
        for i in 0..<count {
            lhs.elements[i] -= rhs.elements[i]
        }
    }
    
    @_transparent
    package static func + (lhs: AnimatableArray<Element>, rhs: AnimatableArray<Element>) -> AnimatableArray<Element> {
        var result = lhs
        result += rhs
        return result
    }
    
    @_transparent
    package static func - (lhs: AnimatableArray<Element>, rhs: AnimatableArray<Element>) -> AnimatableArray<Element> {
        var result = lhs
        result -= rhs
        return result
    }
    
    package mutating func scale(by rhs: Double) {
        for i in elements.indices {
            elements[i].scale(by: rhs)
        }
    }
    
    package var magnitudeSquared: Double {
        elements.reduce(0) { partialResult, element in
            partialResult + element.magnitudeSquared
        }
    }
}

extension Array where Element: Animatable {
    package var animatableData: AnimatableArray<Element.AnimatableData> {
        get { AnimatableArray(map(\.animatableData)) }
        set {
            let count = Swift.min(count, newValue.elements.count)
            for i in 0..<count {
                self[i].animatableData = newValue.elements[i]
            }
        }
    }
}
