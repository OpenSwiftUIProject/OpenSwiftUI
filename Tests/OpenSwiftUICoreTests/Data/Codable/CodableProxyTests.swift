//
//  CodableProxyTests.swift
//  OpenSwiftUICoreTests
//
//  Author: GitHub Copilot with Claude Sonnet 4.5

import Foundation
import OpenSwiftUICore
import Testing

struct CodableProxyTests {

    // MARK: - ProxyCodable

    struct ProxyCodableTests {
        enum TestEnum: String, Codable, CodableByProxy {
            case first
            case second
        }

        @Test
        func encodingAndDecoding() throws {
            let original = ProxyCodable(wrappedValue: TestEnum.first)
            let encoder = JSONEncoder()
            let data = try encoder.encode(original)
            let decoder = JSONDecoder()
            let decoded = try decoder.decode(ProxyCodable<TestEnum>.self, from: data)

            #expect(decoded.wrappedValue == .first)
        }

        @Test
        func projectedValue() {
            let wrapped = ProxyCodable(wrappedValue: TestEnum.second)
            #expect(wrapped.projectedValue.wrappedValue == .second)
        }

        @Test
        func equatable() {
            let first = ProxyCodable(wrappedValue: TestEnum.first)
            let second = ProxyCodable(wrappedValue: TestEnum.second)
            let anotherFirst = ProxyCodable(wrappedValue: TestEnum.first)

            #expect(first == anotherFirst)
            #expect(first != second)
        }

        @Test
        func hashable() {
            let first = ProxyCodable(wrappedValue: TestEnum.first)
            let anotherFirst = ProxyCodable(wrappedValue: TestEnum.first)

            var hasher1 = Hasher()
            first.hash(into: &hasher1)
            var hasher2 = Hasher()
            anotherFirst.hash(into: &hasher2)

            #expect(hasher1.finalize() == hasher2.finalize())
        }
    }

    // MARK: - RawRepresentableProxy

    struct RawRepresentableProxyTests {
        enum TestEnum: String {
            case value1
            case value2
        }

        @Test
        func encodingAndDecoding() throws {
            let proxy = RawRepresentableProxy(TestEnum.value1)
            let encoder = JSONEncoder()
            let data = try encoder.encode(proxy)
            let decoder = JSONDecoder()
            let decoded = try decoder.decode(RawRepresentableProxy<TestEnum>.self, from: data)

            #expect(decoded.base == .value1)
        }

        @Test
        func invalidRawValueThrows() throws {
            let invalidJSON = "\"invalidValue\"".data(using: .utf8)!
            let decoder = JSONDecoder()

            #expect(throws: Error.self) {
                try decoder.decode(RawRepresentableProxy<TestEnum>.self, from: invalidJSON)
            }
        }

        @Test
        func codingProxy() {
            let value = TestEnum.value2
            let proxy = value.codingProxy

            #expect(proxy.base == .value2)
        }
    }

    // MARK: - CodableRawRepresentable

    struct CodableRawRepresentableTests {
        enum Status: Int {
            case inactive = 0
            case active = 1
        }

        @Test
        func encodingAndDecoding() throws {
            let wrapped = CodableRawRepresentable(wrappedValue: Status.active)
            let encoder = JSONEncoder()
            let data = try encoder.encode(wrapped)
            let decoder = JSONDecoder()
            let decoded = try decoder.decode(CodableRawRepresentable<Status>.self, from: data)

            #expect(decoded.wrappedValue == .active)
        }

        @Test
        func invalidRawValueThrows() throws {
            let invalidJSON = "99".data(using: .utf8)!
            let decoder = JSONDecoder()

            #expect(throws: Error.self) {
                try decoder.decode(CodableRawRepresentable<Status>.self, from: invalidJSON)
            }
        }

        @Test
        func equatable() {
            let active1 = CodableRawRepresentable(wrappedValue: Status.active)
            let active2 = CodableRawRepresentable(wrappedValue: Status.active)
            let inactive = CodableRawRepresentable(wrappedValue: Status.inactive)

            #expect(active1 == active2)
            #expect(active1 != inactive)
        }

        @Test
        func hashable() {
            let active = CodableRawRepresentable(wrappedValue: Status.active)
            let anotherActive = CodableRawRepresentable(wrappedValue: Status.active)

            var hasher1 = Hasher()
            active.hash(into: &hasher1)
            var hasher2 = Hasher()
            anotherActive.hash(into: &hasher2)

            #expect(hasher1.finalize() == hasher2.finalize())
        }
    }

    // MARK: - CodableOptional

    struct CodableOptionalTests {
        enum TestValue: String, CodableByProxy {
            case test
        }

        @Test
        func encodingSomeValue() throws {
            let optional = CodableOptional(TestValue.test)
            let encoder = JSONEncoder()
            let data = try encoder.encode(optional)
            let decoder = JSONDecoder()
            let decoded = try decoder.decode(CodableOptional<TestValue>.self, from: data)

            #expect(decoded.base == .test)
        }

        @Test
        func encodingNilValue() throws {
            let optional = CodableOptional<TestValue>(nil)
            let encoder = JSONEncoder()
            let data = try encoder.encode(optional)
            let decoder = JSONDecoder()
            let decoded = try decoder.decode(CodableOptional<TestValue>.self, from: data)

            #expect(decoded.base == nil)
        }

        @Test
        func optionalCodingProxy() {
            let someValue: TestValue? = .test
            let proxy = someValue.codingProxy

            #expect(proxy.base == .test)
        }

        @Test
        func nilCodingProxy() {
            let nilValue: TestValue? = nil
            let proxy = nilValue.codingProxy

            #expect(proxy.base == nil)
        }
    }

    // MARK: - Array + CodableByProxy

    struct ArrayCodableByProxyTests {
        enum TestEnum: String, CodableByProxy {
            case a
            case b
            case c
        }

        @Test
        func codingProxy() {
            let array: [TestEnum] = [.a, .b, .c]
            let proxy = array.codingProxy

            #expect(proxy.count == 3)
            #expect(proxy[0].base == .a)
            #expect(proxy[1].base == .b)
            #expect(proxy[2].base == .c)
        }

        @Test
        func unwrap() {
            let proxies = [
                RawRepresentableProxy(TestEnum.a),
                RawRepresentableProxy(TestEnum.b)
            ]
            let unwrapped = [TestEnum].unwrap(codingProxy: proxies)

            #expect(unwrapped == [.a, .b])
        }
    }

    // MARK: - JSONCodable

    struct JSONCodableTests {
        @Test
        func encodingAndDecodingDictionary() throws {
            let dict: [String: Any] = ["key": "value", "number": 42]
            let codable = JSONCodable(dict)
            let encoder = JSONEncoder()
            let data = try encoder.encode(codable)
            let decoder = JSONDecoder()
            let decoded = try decoder.decode(JSONCodable<[String: Any]>.self, from: data)

            #expect((decoded.base["key"] as? String) == "value")
            #expect((decoded.base["number"] as? Int) == 42)
        }

        @Test
        func encodingAndDecodingArray() throws {
            let array: [Any] = ["string", 123, true]
            let codable = JSONCodable(array)
            let encoder = JSONEncoder()
            let data = try encoder.encode(codable)
            let decoder = JSONDecoder()
            let decoded = try decoder.decode(JSONCodable<[Any]>.self, from: data)

            #expect((decoded.base[0] as? String) == "string")
            #expect((decoded.base[1] as? Int) == 123)
            #expect((decoded.base[2] as? Bool) == true)
        }

        @Test
        func invalidTypeThrows() throws {
            let stringJSON = "\"not a dictionary\"".data(using: .utf8)!
            let decoder = JSONDecoder()

            #expect(throws: Error.self) {
                try decoder.decode(JSONCodable<[String: Any]>.self, from: stringJSON)
            }
        }
    }

    // MARK: - NSAttributedString.Key

    struct NSAttributedStringKeyTests {
        @Test
        func codingProxy() {
            let key = NSAttributedString.Key.foregroundColor
            let proxy = key.codingProxy

            #expect(proxy.base == .foregroundColor)
        }

        @Test
        func encodingAndDecoding() throws {
            let key = NSAttributedString.Key.font
            let proxy = key.codingProxy
            let encoder = JSONEncoder()
            let data = try encoder.encode(proxy)
            let decoder = JSONDecoder()
            let decoded = try decoder.decode(RawRepresentableProxy<NSAttributedString.Key>.self, from: data)

            #expect(decoded.base == .font)
        }
    }
}
