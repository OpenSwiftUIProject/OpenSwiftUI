//
//  Stack.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
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

/// A fixed-capacity stack data structure that can hold up to 3 elements.
///
/// `Stack3` is a specialized stack implementation optimized for scenarios where
/// you need to store a small, fixed number of elements (maximum 3). It uses a
/// tuple-based storage mechanism for efficient memory usage and fast access.
///
/// The stack follows the last-in-first-out (LIFO) principle. When the stack
/// reaches its maximum capacity and a new element is pushed, the oldest element
/// is automatically removed to make room for the new one.
///
/// ## Example Usage
///
/// ```swift
/// var stack = Stack3<String>()
/// 
/// // Push elements
/// stack.push("first")
/// stack.push("second")
/// stack.push("third")
/// 
/// // Check if stack contains a value
/// let hasSecond = stack.contains("second") // true
/// 
/// // Pop elements (LIFO order)
/// let last = stack.pop() // "third"
/// let middle = stack.pop() // "second"
/// let first = stack.pop() // "first"
/// let empty = stack.pop() // nil
/// ```
///
/// - Note: This type is optimized for performance when working with a small,
///   bounded number of elements and is particularly useful in scenarios where
///   memory allocation needs to be minimized.
package struct Stack3<Value> where Value: Equatable {
    var store: (Value?, Value?, Value?)

    /// Creates a new, empty stack with capacity for 3 elements.
    ///
    /// The newly created stack contains no elements and is ready to accept
    /// up to 3 values via the `push(_:)` method.
    ///
    /// - Complexity: O(1)
    package init() {
        store = (nil, nil, nil)
    }

    /// Returns a Boolean value indicating whether the stack contains the specified element.
    ///
    /// This method searches through all stored elements in the stack and returns
    /// `true` if any of them is equal to the provided value.
    ///
    /// - Parameter value: The value to search for in the stack.
    /// - Returns: `true` if the stack contains the specified value; otherwise, `false`.
    /// - Complexity: O(1) - The stack has a fixed maximum size of 3 elements.
    ///
    /// ## Example
    ///
    /// ```swift
    /// var stack = Stack3<Int>()
    /// stack.push(10)
    /// stack.push(20)
    /// 
    /// let containsTen = stack.contains(10) // true
    /// let containsThirty = stack.contains(30) // false
    /// ```
    package func contains(_ value: Value) -> Bool {
        store.0 == value || store.1 == value || store.2 == value
    }

    /// Adds a new element to the top of the stack.
    ///
    /// If the stack is not at full capacity (less than 3 elements), the new
    /// element is added to the next available position. If the stack is already
    /// at maximum capacity, the oldest element is removed and all remaining
    /// elements are shifted to make room for the new element at the top.
    ///
    /// - Parameter value: The element to add to the stack.
    /// - Complexity: O(1)
    ///
    /// ## Behavior
    ///
    /// - **Empty stack**: Element goes to position 0
    /// - **One element**: Element goes to position 1
    /// - **Two elements**: Element goes to position 2
    /// - **Three elements**: Elements shift left, new element goes to position 2
    ///
    /// ## Example
    ///
    /// ```swift
    /// var stack = Stack3<String>()
    /// stack.push("A") // Stack: ["A", nil, nil]
    /// stack.push("B") // Stack: ["A", "B", nil]
    /// stack.push("C") // Stack: ["A", "B", "C"]
    /// stack.push("D") // Stack: ["B", "C", "D"] (A is removed)
    /// ```
    package mutating func push(_ value: Value) {
        if store.0 == nil {
            store.0 = value
        } else if store.1 == nil {
            store.1 = value
        } else if store.2 == nil {
            store.2 = value
        } else {
            store = (store.1, store.2, value)
        }
    }

    /// Removes and returns the element at the top of the stack.
    ///
    /// This method follows the last-in-first-out (LIFO) principle, removing
    /// the most recently added element first. The method searches from the
    /// highest position (position 2) down to the lowest position (position 0)
    /// and returns the first non-nil value found.
    ///
    /// - Returns: The element at the top of the stack, or `nil` if the stack is empty.
    /// - Complexity: O(1)
    ///
    /// ## Example
    ///
    /// ```swift
    /// var stack = Stack3<Int>()
    /// stack.push(1)
    /// stack.push(2)
    /// stack.push(3)
    /// 
    /// let first = stack.pop() // 3
    /// let second = stack.pop() // 2
    /// let third = stack.pop() // 1
    /// let fourth = stack.pop() // nil (stack is empty)
    /// ```
    package mutating func pop() -> Value? {
        if let value = store.2 {
            store.2 = nil
            return value
        } else if let value = store.1 {
            store.1 = nil
            return value
        } else if let value = store.0 {
            store.0 = nil
            return value
        } else {
            return nil
        }
    }
}
