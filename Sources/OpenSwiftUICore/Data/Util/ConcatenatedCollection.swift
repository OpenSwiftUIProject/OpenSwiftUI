//
//  ConcatenatedCollection.swift
//  OpenSwiftUICore
//
//  Status: Complete
//  Audited for 6.4.41

// MARK: - ConcatenatedCollectionIndexRepresentation

/// Internal representation for tracking position within a concatenated collection.
///
/// This enum represents whether an index points to an element in the first or second
/// collection of a concatenated collection.
package enum _ConcatenatedCollectionIndexRepresentation<I1, I2> where I1: Comparable, I2: Comparable {
    /// Index points to an element in the first collection.
    case first(I1)
    /// Index points to an element in the second collection.
    case second(I2)
}

// MARK: - ConcatenatedCollectionIndex

/// An index type for concatenated collections.
///
/// This index type tracks position within a concatenated collection by maintaining
/// information about which underlying collection contains the element and the
/// position within that collection.
///
/// ## Topics
///
/// ### Creating Indices
/// - ``init(first:)``
/// - ``init(second:)``
///
/// ### Instance Properties
/// - ``_position``
package struct ConcatenatedCollectionIndex<C1, C2>: Comparable where C1: Collection, C2: Collection {
    /// Creates an index pointing to an element in the first collection.
    ///
    /// - Parameter i: The index within the first collection.
    package init(first i: C1.Index) {
        _position = .first(i)
    }

    /// Creates an index pointing to an element in the second collection.
    ///
    /// - Parameter i: The index within the second collection.
    package init(second i: C2.Index) {
        _position = .second(i)
    }

    /// The underlying position representation.
    ///
    /// This property indicates whether the index points to an element in the first
    /// or second collection, along with the specific index within that collection.
    package let _position: _ConcatenatedCollectionIndexRepresentation<C1.Index, C2.Index>

    /// Compares two concatenated collection indices for ordering.
    ///
    /// Indices in the first collection are always considered less than indices
    /// in the second collection. Within the same collection, the comparison
    /// delegates to the underlying collection's index comparison.
    ///
    /// - Parameters:
    ///   - lhs: The left-hand side index.
    ///   - rhs: The right-hand side index.
    /// - Returns: `true` if `lhs` is less than `rhs`, `false` otherwise.
    package static func < (lhs: ConcatenatedCollectionIndex<C1, C2>, rhs: ConcatenatedCollectionIndex<C1, C2>) -> Bool {
        switch (lhs._position, rhs._position) {
        case (.first, .second):
            return true
        case (.second, .first):
            return false
        case let (.first(lhsIndex), .first(rhsIndex)):
            return lhsIndex < rhsIndex
        case let (.second(lhsIndex), .second(rhsIndex)):
            return lhsIndex < rhsIndex
        }
    }

    /// Checks two concatenated collection indices for equality.
    ///
    /// Two indices are equal if they point to the same collection (first or second)
    /// and have equal underlying indices within that collection.
    ///
    /// - Parameters:
    ///   - lhs: The left-hand side index.
    ///   - rhs: The right-hand side index.
    /// - Returns: `true` if the indices are equal, `false` otherwise.
    package static func == (lhs: ConcatenatedCollectionIndex<C1, C2>, rhs: ConcatenatedCollectionIndex<C1, C2>) -> Bool {
        switch (lhs._position, rhs._position) {
        case let (.first(lhsIndex), .first(rhsIndex)):
            return lhsIndex == rhsIndex
        case let (.second(lhsIndex), .second(rhsIndex)):
            return lhsIndex == rhsIndex
        default:
            return false
        }
    }
}

// MARK: - ConcatenatedCollection

/// A collection that presents two collections as a single, unified collection.
///
/// `ConcatenatedCollection` allows you to treat two separate collections as if they
/// were a single collection, with elements from the first collection appearing before
/// elements from the second collection. Both collections must have the same element type.
///
/// ## Overview
///
/// When you create a concatenated collection, you can iterate through it, access elements
/// by index, and perform other collection operations as if it were a single collection:
///
/// ```swift
/// let first = [1, 2, 3]
/// let second = [4, 5, 6]
/// let concatenated = ConcatenatedCollection(_base1: first, base2: second)
///
/// for element in concatenated {
///     print(element) // Prints: 1, 2, 3, 4, 5, 6
/// }
/// ```
///
/// ## Performance Characteristics
///
/// - **Index operations**: O(1) for most operations
/// - **Element access**: O(1) - delegates to underlying collections
/// - **Iteration**: O(n) - visits each element once
///
/// When both underlying collections conform to `RandomAccessCollection`, the concatenated
/// collection also provides random access capabilities with efficient index arithmetic.
///
/// ## Topics
///
/// ### Creating Concatenated Collections
/// - ``init(_base1:base2:)``
/// - ``concatenate(_:_:)``
///
/// ### Collection Properties
/// - ``startIndex``
/// - ``endIndex``
/// - ``subscript(_:)``
///
/// ### Collection Methods
/// - ``index(after:)``
///
/// ### Type Aliases
/// - ``Index``
/// - ``Element``
/// - ``Indices``
/// - ``Iterator``
/// - ``SubSequence``
package struct ConcatenatedCollection<C1, C2>: Collection where C1: Collection, C2: Collection, C1.Element == C2.Element {
    /// The first collection in the concatenation.
    package let _base1: C1

    /// The second collection in the concatenation.
    package let _base2: C2

    /// Creates a concatenated collection from two collections.
    ///
    /// - Parameters:
    ///   - _base1: The first collection, whose elements will appear first.
    ///   - base2: The second collection, whose elements will appear after the first.
    package init(_base1: C1, base2: C2) {
        self._base1 = _base1
        self._base2 = base2
    }

    /// The position of the first element in the concatenated collection.
    ///
    /// If the first collection is not empty, this returns an index pointing to its
    /// start. Otherwise, it returns an index pointing to the start of the second collection.
    ///
    /// - Complexity: O(1)
    package var startIndex: ConcatenatedCollection<C1, C2>.Index {
        if !_base1.isEmpty {
            return Index(first: _base1.startIndex)
        } else {
            return Index(second: _base2.startIndex)
        }
    }

    /// The position one past the last element in the concatenated collection.
    ///
    /// This always points to the end of the second collection, regardless of
    /// whether the first collection is empty.
    ///
    /// - Complexity: O(1)
    package var endIndex: ConcatenatedCollection<C1, C2>.Index {
        Index(second: _base2.endIndex)
    }

    /// Accesses the element at the specified index.
    ///
    /// - Parameter i: The index of the element to access.
    /// - Returns: The element at the specified index.
    /// - Complexity: O(1)
    package subscript(i: ConcatenatedCollection<C1, C2>.Index) -> C1.Element {
        switch i._position {
        case let .first(index):
            return _base1[index]
        case let .second(index):
            return _base2[index]
        }
    }

    /// Returns the index immediately after the given index.
    ///
    /// This method handles transitions between the two underlying collections.
    /// When advancing past the end of the first collection, it automatically
    /// transitions to the start of the second collection.
    ///
    /// - Parameter i: A valid index of the collection.
    /// - Returns: The index immediately after `i`.
    /// - Complexity: O(1)
    package func index(after i: ConcatenatedCollection<C1, C2>.Index) -> ConcatenatedCollection<C1, C2>.Index {
        switch i._position {
        case let .first(index):
            let nextIndex = _base1.index(after: index)
            if nextIndex == _base1.endIndex {
                return Index(second: _base2.startIndex)
            } else {
                return Index(first: nextIndex)
            }
        case let .second(index):
            return Index(second: _base2.index(after: index))
        }
    }

    package typealias Index = ConcatenatedCollectionIndex<C1, C2>

    package typealias Element = C1.Element

    package typealias Indices = DefaultIndices<ConcatenatedCollection<C1, C2>>

    package typealias Iterator = IndexingIterator<ConcatenatedCollection<C1, C2>>

    package typealias SubSequence = Slice<ConcatenatedCollection<C1, C2>>
}

// MARK: - ConcatenatedCollection + Bidirectional & Random Access Support

/// Extension providing bidirectional and random access collection capabilities.
///
/// When both underlying collections conform to `RandomAccessCollection`, the concatenated
/// collection also provides efficient random access operations including backwards iteration
/// and index offsetting.
extension ConcatenatedCollection: BidirectionalCollection, RandomAccessCollection where C1: RandomAccessCollection, C2: RandomAccessCollection {
    /// Returns the index immediately before the given index.
    ///
    /// This method handles transitions between the two underlying collections.
    /// When moving backward from the start of the second collection, it automatically
    /// transitions to the end of the first collection.
    ///
    /// - Parameter i: A valid index of the collection (not `startIndex`).
    /// - Returns: The index immediately before `i`.
    /// - Complexity: O(1)
    package func index(before i: ConcatenatedCollection<C1, C2>.Index) -> ConcatenatedCollection<C1, C2>.Index {
        switch i._position {
        case let .first(index):
            return Index(first: _base1.index(before: index))
        case let .second(index):
            if index == _base2.startIndex {
                return Index(first: _base1.index(before: _base1.endIndex))
            } else {
                return Index(second: _base2.index(before: index))
            }
        }
    }

    package func index(_ i: ConcatenatedCollection<C1, C2>.Index, offsetBy n: Int) -> ConcatenatedCollection<C1, C2>.Index {
        if n == 0 {
            return i
        } else if n > 0 {
            return _offsetForward(i, by: n)
        } else {
            return _offsetBackward(i, by: -n)
        }
    }

    package func _offsetForward(_ i: ConcatenatedCollection<C1, C2>.Index, by n: Int) -> ConcatenatedCollection<C1, C2>.Index {        
        switch i._position {
        case let .first(index):
            let remainingInFirst = _base1.distance(from: index, to: _base1.endIndex)
            if n < remainingInFirst {
                return Index(first: _base1.index(index, offsetBy: n))
            } else {
                let offsetInSecond = n - remainingInFirst
                return Index(second: _base2.index(_base2.startIndex, offsetBy: offsetInSecond))
            }
        case let .second(index):
            return Index(second: _base2.index(index, offsetBy: n))
        }
    }

    package func _offsetBackward(_ i: ConcatenatedCollection<C1, C2>.Index, by n: Int) -> ConcatenatedCollection<C1, C2>.Index {        
        switch i._position {
        case let .first(index):
            return Index(first: _base1.index(index, offsetBy: -n))
        case let .second(index):
            let distanceFromSecondStart = _base2.distance(from: _base2.startIndex, to: index)
            if n <= distanceFromSecondStart {
                return Index(second: _base2.index(index, offsetBy: -n))
            } else {
                let offsetInFirst = n - distanceFromSecondStart
                return Index(first: _base1.index(_base1.endIndex, offsetBy: -offsetInFirst))
            }
        }
    }
}

// MARK: - Concatenation Function

/// Creates a concatenated collection from two collections.
///
/// This function provides a convenient way to create a `ConcatenatedCollection` that presents
/// two separate collections as a single, unified collection. Elements from the first collection
/// appear before elements from the second collection.
///
/// ## Overview
///
/// Use this function when you need to combine two collections of the same element type:
///
/// ```swift
/// let numbers = [1, 2, 3]
/// let moreNumbers = [4, 5, 6]
/// let combined = concatenate(numbers, moreNumbers)
///
/// Array(combined) // [1, 2, 3, 4, 5, 6]
/// ```
///
/// The resulting collection maintains efficient access to elements and supports all collection
/// operations. When both input collections conform to `RandomAccessCollection`, the result
/// also provides random access capabilities.
///
/// ## Performance
///
/// - **Time complexity**: O(1) - creating the concatenated collection is constant time
/// - **Space complexity**: O(1) - no additional storage beyond references to input collections
///
/// The concatenated collection stores references to the original collections rather than
/// copying their elements, making creation very efficient regardless of collection size.
///
/// - Parameters:
///   - first: The first collection, whose elements will appear first in the result.
///   - second: The second collection, whose elements will appear after the first.
/// - Returns: A `ConcatenatedCollection` that presents both collections as a single collection.
///
/// - Note: Both collections must have the same `Element` type.
package func concatenate<C1, C2>(_ first: C1, _ second: C2) -> ConcatenatedCollection<C1, C2> where C1: Collection, C2: Collection, C1.Element == C2.Element {
    ConcatenatedCollection(_base1: first, base2: second)
}

// MARK: - Collection Extensions

extension Collection {
    /// Finds the partition point in a collection based on a predicate.
    ///
    /// This method uses binary search to efficiently find the first position where the predicate
    /// returns `true`, assuming the collection is partitioned such that all elements for which
    /// the predicate returns `false` appear before all elements for which it returns `true`.
    ///
    /// ## Overview
    ///
    /// The partition point is useful for finding insertion points in sorted collections or
    /// locating boundaries between different categories of elements:
    ///
    /// ```swift
    /// let numbers = [1, 3, 5, 8, 10, 12, 15]
    /// let insertionPoint = numbers.partitionPoint { $0 >= 9 }
    /// // insertionPoint points to the element 10 (index 4)
    /// 
    /// let mixed = ["apple", "banana", "zebra"]
    /// let boundary = mixed.partitionPoint { $0 > "m" }
    /// // boundary points to "zebra" (first element > "m")
    /// ```
    ///
    /// ## Algorithm
    ///
    /// This method implements an efficient binary search algorithm:
    /// 1. Starts with the entire collection range
    /// 2. Repeatedly divides the search space in half
    /// 3. Tests the predicate at the midpoint
    /// 4. Narrows the search to the appropriate half
    /// 5. Continues until the partition point is found
    ///
    /// ## Performance
    ///
    /// - **Time complexity**: O(log n) where n is the number of elements
    /// - **Space complexity**: O(1) - uses constant additional storage
    ///
    /// The binary search approach makes this method very efficient even for large collections,
    /// requiring only logarithmic time relative to the collection size.
    ///
    /// ## Preconditions
    ///
    /// For correct results, the collection must be partitioned with respect to the predicate:
    /// - All elements for which the predicate returns `false` must appear before
    /// - All elements for which the predicate returns `true`
    ///
    /// If this precondition is not met, the result is undefined.
    ///
    /// - Parameter predicate: A closure that takes an element and returns `true` if the element
    ///   should be considered part of the "true" partition, `false` otherwise.
    /// - Returns: The index of the first element for which `predicate` returns `true`, or
    ///   `endIndex` if no such element exists.
    /// - Throws: Rethrows any error thrown by the predicate.
    ///
    /// - Complexity: O(log n), where n is the length of the collection.
    package func partitionPoint(where predicate: (Element) throws -> Bool) rethrows -> Index {
        let count = count
        guard count >= 1 else {
            return startIndex
        }
        
        var low = startIndex
        var remaining = count
        
        while remaining > 0 {
            let half = remaining / 2
            let mid = index(low, offsetBy: half)
            
            if try predicate(self[mid]) {
                remaining = half
            } else {
                low = index(after: mid)
                remaining = remaining - half - 1
            }
        }
        return low
    }
}
