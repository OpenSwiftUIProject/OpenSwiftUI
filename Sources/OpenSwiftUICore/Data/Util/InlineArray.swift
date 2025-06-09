//
//  InlineArray.swift
//  OpenSwiftUICore
//
//  Audited for 6.4.41
//  Status: Complete

// MARK: - ArrayWith2Inline

package struct ArrayWith2Inline<T> {
    package enum Storage {
        case empty
        case one(T)
        case two(T, T)
        case many(ContiguousArray<T>)
    }

    package typealias Element = T

    package var storage: ArrayWith2Inline<T>.Storage

    package init() {
        storage = .empty
    }

    package init(_ first: T) {
        storage = .one(first)
    }

    package init(_ first: T, _ second: T) {
        storage = .two(first, second)
    }

    package init<S>(_ s: S) where T == S.Element, S: Sequence {
        let underestimatedCount = s.underestimatedCount
        guard underestimatedCount < 3 else {
            let contiguousArray: ContiguousArray<T>
            if [T].self == S.self || ContiguousArray<T>.self == S.self {
                contiguousArray = .init(s)
            } else {
                var array: ContiguousArray<T> = ContiguousArray()
                array.reserveCapacity(underestimatedCount)
                array.append(contentsOf: s)
                contiguousArray = array
            }
            self.storage = .many(contiguousArray)
            return
        }
        var iterator = s.makeIterator()
        guard let one = iterator.next() else {
            self.storage = .empty
            return
        }
        guard let two = iterator.next() else {
            self.storage = .one(one)
            return
        }
        guard iterator.next() != nil else {
            self.storage = .two(one, two)
            return
        }
        self.storage = .many(ContiguousArray(s))
    }
}

// MARK: - ArrayWith2Inline + RandomAccessCollection, MutableCollection

extension ArrayWith2Inline: RandomAccessCollection, MutableCollection {
    package var startIndex: Int {
        0
    }

    package var endIndex: Int {
        switch storage {
        case .empty:
            return 0
        case .one:
            return 1
        case .two:
            return 2
        case let .many(array):
            return array.count
        }
    }

    package subscript(i: Int) -> T {
        get {
            switch storage {
            case .empty:
                preconditionFailure("ArrayWith2Inline index out of range")
            case .one(let element):
                guard i == 0 else { preconditionFailure("index out of range") }
                return element
            case .two(let first, let second):
                switch i {
                case 0: return first
                case 1: return second
                default: preconditionFailure("index out of range")
                }
            case .many(let array):
                return array[i]
            }
        }
        set {
            switch storage {
            case .empty:
                preconditionFailure("ArrayWith2Inline index out of range")
            case .one:
                guard i == 0 else { preconditionFailure("index out of range") }
                storage = .one(newValue)
            case .two(let first, let second):
                switch i {
                case 0: storage = .two(newValue, second)
                case 1: storage = .two(first, newValue)
                default: preconditionFailure("index out of range")
                }
            case .many(var array):
                array[i] = newValue
                storage = .many(array)
            }
        }
    }

    package func _copyToContiguousArray() -> ContiguousArray<ArrayWith2Inline<T>.Element> {
        switch storage {
        case let .many(array):
            array._copyToContiguousArray()
        default:
            ContiguousArray(lazy.map { $0 })
        }
    }
}

// MARK: - ArrayWith2Inline + UnsafeMutableBufferPointer

extension ArrayWith2Inline {
    @inline(__always)
    package mutating func withUnsafeMutableBufferPointer<R>(_ body: (inout UnsafeMutableBufferPointer<T>) throws -> R) rethrows -> R {
        // FIXME: To Be optimized
        switch storage {
        case .empty:
            var buffer = UnsafeMutableBufferPointer<T>(start: nil, count: 0)
            return try body(&buffer)
        case let .one(element):
            var element = element
            defer { storage = .one(element) }
            return try withUnsafeMutablePointer(to: &element) { pointer in
                var buffer = UnsafeMutableBufferPointer(start: pointer, count: 1)
                return try body(&buffer)
            }
        case let .two(first, second):
            var element = (first, second)
            defer { storage = .two(element.0, element.1) }
            return try withUnsafeMutablePointer(to: &element) { pointer in
                try pointer.withMemoryRebound(to: T.self, capacity: 2) { pointer in
                    var buffer = UnsafeMutableBufferPointer(start: pointer, count: 2)
                    return try body(&buffer)
                }
            }
        case let .many(array):
            var array = array
            defer { storage = .many(array) }
            return try array.withUnsafeMutableBufferPointer { buffer in
                try body(&buffer)
            }
        }
    }
}

// MARK: - ArrayWith2Inline + Array-like Operations

extension ArrayWith2Inline {
    package mutating func append(_ x: T) {
        switch storage {
        case .empty:
            storage = .one(x)
        case let .one(first):
            storage = .two(first, x)
        case let .two(first, second):
            storage = .many(ContiguousArray([first, second, x]))
        case var .many(array):
            array.append(x)
            storage = .many(array)
        }
    }

    package mutating func reserveCapacity(_ n: Int) {
        switch storage {
        case .empty: break
        default:
            if case let .many(array) = storage, array.capacity >= n {
                break
            }
            var array: ContiguousArray<T> = ContiguousArray()
            array.reserveCapacity(n)
            array.append(contentsOf: self)
        }
    }

    package mutating func removeAll(keepingCapacity: Bool = false) {
        switch storage {
        case var .many(array):
            if keepingCapacity {
                array.removeAll(keepingCapacity: true)
                storage = .many(array)
            } else {
                storage = .empty
            }
        default:
            storage = .empty
        }
    }
}

// MARK: - ArrayWith2Inline + RangeReplaceableCollection

extension ArrayWith2Inline: RangeReplaceableCollection {
    package mutating func replaceSubrange<C>(_ target: Range<Int>, with source: C) where T == C.Element, C: Collection {
        switch storage {
        case var .many(array):
            array.replaceSubrange(target, with: source)
            storage = .many(array)
        default:
            let prefix = self[..<target.lowerBound]
            let c1 = concatenate(prefix, source)
            if count == target.upperBound {
                self = ArrayWith2Inline(c1)
            } else {
                let suffix = self[target.upperBound...]
                let c2 = concatenate(c1, suffix)
                self = ArrayWith2Inline(c2)
            }
        }
    }
}

// MARK: - ArrayWith2Inline + Equatable

extension ArrayWith2Inline: Equatable where T: Equatable {
    package static func == (lhs: ArrayWith2Inline<T>, rhs: ArrayWith2Inline<T>) -> Bool {
        switch (lhs.storage, rhs.storage) {
        case (.empty, .empty):
            return true
        case let (.one(lhsElement), .one(rhsElement)):
            return lhsElement == rhsElement
        case let (.two(lhsFirst, lhsSecond), .two(rhsFirst, rhsSecond)):
            return lhsFirst == rhsFirst && lhsSecond == rhsSecond
        case let (.many(lhsArray), .many(rhsArray)):
            return lhsArray == rhsArray
        default:
            return false
        }
    }
}

// MARK: - ArrayWith2Inline + ExpressibleByArrayLiteral

extension ArrayWith2Inline: ExpressibleByArrayLiteral {
    package init(arrayLiteral: T...) {
        self.init(arrayLiteral)
    }
}
