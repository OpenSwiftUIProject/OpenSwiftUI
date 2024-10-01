//
//  Stack.swift
//  OpenSwiftUICore
//
//  Audited for RELEASE_2024
//  Status: Complete

package enum Stack<Value>: Sequence, IteratorProtocol {
    case empty
    indirect case node(value: Value, next: Stack<Value>)
    
    @inlinable
    package init() {
        self = .empty
    }
    
    package var top: Value? {
        switch self {
        case .empty:
            return nil
        case let .node(value, _):
            return value
        }
    }
    
    @inlinable
    package var count: Int {
        var iterator = makeIterator()
        var count = 0
        while (iterator.next() != nil) {
            count &+= 1
        }
        return count
    }
    
    @inlinable
    package var isEmpty: Bool {
        top == nil
    }
    
    @inlinable
    package mutating func push(_ value: Value) {
        self = .node(value: value, next: self)
    }

    @discardableResult
    @inlinable
    package mutating func pop() -> Value? {
        switch self {
        case .empty:
            return nil
        case let .node(value, next):
            self = next
            return value
        }
    }
    
    @inlinable
    package mutating func popAll() {
        self = .empty
    }
    
    package func map<T>(_ transform: (Value) -> T) -> Stack<T> {
        withUnsafeTemporaryAllocation(
            of: T.self,
            capacity: count
        ) { buffer in
            var iterator = makeIterator()
            var next: Value?
            var index = 0
            repeat {
                index &+= 1
                next = iterator.next()
                guard let next else { break }
                buffer.initializeElement(at: count - index, to: transform(next))
            } while true
            
            var stack = Stack<T>()
            for index in buffer.indices {
                stack.push(buffer[index])
            }
            return stack
        }
    }
    
    package mutating func next() -> Value? {
        pop()
    }
    
    package typealias Element = Value
    package typealias Iterator = Stack<Value>
}

extension Stack: Equatable where Value: Equatable {
    package static func == (a: Stack<Value>, b: Stack<Value>) -> Bool {
        switch (a, b) {
        case (.empty, .empty):
            return true
        case let (.node(valueA, nextA), .node(valueB, nextB)):
            return valueA == valueB && nextA == nextB
        default:
            return false
        }
    }
}

extension Stack: GraphReusable where Value: GraphReusable {
    @inlinable
    package static var isTriviallyReusable: Bool {
        Value.isTriviallyReusable
    }
    
    package mutating func makeReusable(indirectMap: IndirectAttributeMap) {
        guard !isEmpty else { return }
        self = map { value in
            var value = value
            value.makeReusable(indirectMap: indirectMap)
            return value
        }
    }
    
    package func tryToReuse(by other: Stack<Value>, indirectMap: IndirectAttributeMap, testOnly: Bool) -> Bool {
        var nodeA = self
        var nodeB = other
        repeat {
            let valueA = nodeA.pop()
            let valueB = nodeB.pop()
            if let valueA, let valueB {
                guard valueA.tryToReuse(by: valueB, indirectMap: indirectMap, testOnly: testOnly) else {
                    return false
                }
            } else if valueA == nil, valueB == nil {
                return true
            } else {
                ReuseTrace.traceReuseViewInputsDifferentFailure()
                return false
            }
        } while true
        return false
    }
}
