//
//  CoreFoundationNonDarwinShimsTests.swift
//  OpenSwiftUICoreTests

#if !canImport(Darwin)
import CoreFoundation
import Foundation
@testable import OpenSwiftUICore
import Testing

private final class Value: CFCompatObject {
    let number: Int

    init(_ number: Int) {
        self.number = number
        super.init()
    }

    override func isEqual(_ object: Any?) -> Bool {
        guard let other = object as? Value else { return false }
        return other.number == number
    }

    override var hash: Int {
        number.hashValue
    }
}

private let key: NSAttributedString.Key = .init("OpenSwiftUITests.CFCompatObject")

struct CoreFoundationNonDarwinShimsTests {
    @Test
    func cfEqualUsesIsEqual() {
        #expect(CFEqual(Value(1), Value(1)))
        #expect(!CFEqual(Value(1), Value(2)))
    }

    @Test
    func cfHashUsesHash() {
        #expect(CFHash(Value(1)) == CFHash(Value(1)))
        #expect(CFHash(Value(1)) == CFHashCode(bitPattern: 1.hashValue))
    }

    @Test
    func attributeRunsMergeOnEqualValues() {
        let string = NSMutableAttributedString(string: "Hello")
        string.addAttribute(key, value: Value(1), range: NSRange(location: 0, length: 2))
        string.addAttribute(key, value: Value(1), range: NSRange(location: 2, length: 3))
        #expect(string.runs().count == 1)
    }

    @Test
    func attributeRunsSplitOnDifferentValues() {
        let string = NSMutableAttributedString(string: "Hello")
        string.addAttribute(key, value: Value(1), range: NSRange(location: 0, length: 2))
        string.addAttribute(key, value: Value(2), range: NSRange(location: 2, length: 3))
        #expect(string.runs().count == 2)
    }
}
#endif
