//
//  Stack.swift
//  OpenSwiftUICore
//
//  Audited for iOS 18.0
//  Status: Complete

/// A generic last-in-first-out (LIFO) stack data structure.
///
/// `Stack` provides efficient operations for adding and removing elements in a
/// last-in-first-out (LIFO) manner. Elements added to the stack using `push(_:)`
/// are removed using `pop()` in the reverse order they were added.
///
/// You can iterate through the elements of a stack from top to bottom.
///
///     var stack = Stack<Int>()
///     stack.push(1)
///     stack.push(2)
///     stack.push(3)
///
///     for element in stack {
///         print(element)
///     }
///
package enum Stack<Value>: Sequence, IteratorProtocol {
    /// An empty stack with no elements.
    case empty

    /// A stack node containing a value and a reference to the next node.
    indirect case node(value: Value, next: Stack<Value>)

    /// Creates a new, empty stack.
    @inlinable
    package init() {
        self = .empty
    }

    /// The element at the top of the stack.
    ///
    /// Returns `nil` if the stack is empty.
    package var top: Value? {
        switch self {
        case .empty:
            return nil
        case let .node(value, _):
            return value
        }
    }

    /// The number of elements in the stack.
    ///
    /// - Complexity: O(n), where n is the number of elements in the stack.
    @inlinable
    package var count: Int {
        var iterator = makeIterator()
        var count = 0
        while (iterator.next() != nil) {
            count &+= 1
        }
        return count
    }

    /// A Boolean value indicating whether the stack is empty.
    ///
    /// - Complexity: O(1)
    @inlinable
    package var isEmpty: Bool {
        top == nil
    }

    /// Adds a new element to the top of the stack.
    ///
    /// - Parameter value: The element to add to the stack.
    /// - Complexity: O(1)
    @inlinable
    package mutating func push(_ value: Value) {
        self = .node(value: value, next: self)
    }

    /// Removes and returns the element at the top of the stack.
    ///
    /// - Returns: The element at the top of the stack, or `nil` if the stack is empty.
    /// - Complexity: O(1)
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

    /// Removes all elements from the stack.
    ///
    /// - Complexity: O(1)
    @inlinable
    package mutating func popAll() {
        self = .empty
    }

    /// Returns a new stack containing the results of mapping the given closure over the elements.
    ///
    /// - Parameter transform: A mapping closure. `transform` accepts an element of this stack
    ///   as its parameter and returns a transformed value of the same or a different type.
    /// - Returns: A stack containing the transformed elements.
    /// - Complexity: O(n), where n is the number of elements in the stack.
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

    /// Advances to the next element and returns it, or `nil` if no next element exists.
    ///
    /// - Returns: The next element in the stack, or `nil` if the stack is empty.
    /// - Note: This is part of the `IteratorProtocol` implementation.
    package mutating func next() -> Value? {
        pop()
    }

    /// The type of element traversed by this stack.
    package typealias Element = Value

    /// The type of iterator that iterates over the stack's elements.
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
    }
}
