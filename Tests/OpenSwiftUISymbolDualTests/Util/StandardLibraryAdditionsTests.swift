//
//  StandardLibraryAdditionsTests.swift
//  OpenSwiftUISymbolDualTests

#if canImport(SwiftUI, _underlyingVersion: 6.5.4)
import Testing

// MARK: - BidirectionalCollectionInsertionSortTests

extension BidirectionalCollection where Self: MutableCollection {
    @_silgen_name("OpenSwiftUITestStub_BidirectionalCollectionInsertionSortBy")
    mutating func insertionSort(by areInIncreasingOrder: (Element, Element) throws -> Bool) rethrows
}

struct BidirectionalCollectionInsertionSortTests {
    @Test
    func alreadySorted() {
        var array = [1, 2, 3, 4, 5]
        array.insertionSort()
        #expect(array == [1, 2, 3, 4, 5])
    }

    @Test
    func reverseSorted() {
        var array = [5, 4, 3, 2, 1]
        array.insertionSort()
        #expect(array == [1, 2, 3, 4, 5])
    }

    @Test
    func randomOrder() {
        var array = [3, 1, 4, 1, 5, 9, 2, 6, 5, 3]
        array.insertionSort()
        #expect(array == [1, 1, 2, 3, 3, 4, 5, 5, 6, 9])
    }

    @Test
    func customComparison() {
        var array = [1, 2, 3, 4, 5]
        array.insertionSort(by: >)
        #expect(array == [5, 4, 3, 2, 1])
    }

    @Test
    func stringArray() {
        var array = ["zebra", "apple", "banana", "cherry"]
        array.insertionSort()
        #expect(array == ["apple", "banana", "cherry", "zebra"])
    }

    @Test
    func structComparison() {
        struct Person: Comparable {
            let name: String
            let age: Int

            static func < (lhs: Person, rhs: Person) -> Bool {
                lhs.age < rhs.age
            }

            static func == (lhs: Person, rhs: Person) -> Bool {
                lhs.name == rhs.name && lhs.age == rhs.age
            }
        }

        var people = [
            Person(name: "Alice", age: 30),
            Person(name: "Bob", age: 25),
            Person(name: "Charlie", age: 35),
        ]

        people.insertionSort()

        #expect(people[0].name == "Bob")
        #expect(people[1].name == "Alice")
        #expect(people[2].name == "Charlie")
    }

    @Test
    func arraySliceSort() {
        var array = [5, 1, 4, 2, 3]
        var slice = array[1 ... 3]
        slice.insertionSort()

        array[1 ... 3] = slice
        #expect(array == [5, 1, 2, 4, 3])
    }

    @Test
    func throwingComparison() {
        enum V: Equatable, CustomStringConvertible {
            case value(Int)
            case invalid

            var description: String {
                guard case let .value(value) = self else { return "invalid" }
                return value.description
            }
        }

        enum ComparisonError: Error {
            case invalid
        }
        var array: [V] = [.value(5), .value(4), .invalid, .value(2), .value(1)]
        do {
            try array.insertionSort { first, second in
                guard case let .value(firstValue) = first,
                      case let .value(secondValue) = second
                else {
                    throw ComparisonError.invalid
                }
                return firstValue < secondValue
            }
        } catch {
            #expect(error is ComparisonError)
        }
        #expect(array == [.value(4), .value(5), .invalid, .value(2), .value(1)])
    }

    @Test("Verify self[insertionIndex] = currentElement")
    func throwingComparison2() {
        enum V: Equatable, CustomStringConvertible {
            case value(Int)
            case invalid

            var description: String {
                guard case let .value(value) = self else { return "invalid" }
                return value.description
            }
        }

        enum ComparisonError: Error {
            case invalid
        }
        var array: [V] = [.value(5), .value(4), .invalid, .value(2), .value(1)]
        do {
            try array.insertionSort { first, second in
                guard case let .value(firstValue) = first,
                      case let .value(secondValue) = second
                else {
                    if first == .invalid, second == .value(4) {
                        throw ComparisonError.invalid
                    } else {
                        return true
                    }
                }
                return firstValue < secondValue
            }
        } catch {
            #expect(error is ComparisonError)
        }
        #expect(array == [.value(4), .invalid, .value(5), .value(2), .value(1)])
    }
}

#endif
