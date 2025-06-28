//
//  Pair.swift
//  OpenSwiftUICore
//
//  Status: Complete
//  ID: DE8DAFA613257BEA44770487175C185C (SwiftUICore?)

// MARK: - Pairt [6.5.4]

package struct Pair<First, Second> {
    package var first: First
    package var second: Second

    package init(_ first: First, _ second: Second) {
        self.first = first
        self.second = second
    }

    private enum CodingKeys: CodingKey {
        case first
        case second
    }
}

extension Pair: Equatable where First: Equatable, Second: Equatable {
    package static func == (a: Pair<First, Second>, b: Pair<First, Second>) -> Bool {
        return a.first == b.first && a.second == b.second
    }
}

extension Pair: Hashable where First: Hashable, Second: Hashable {
    package func hash(into hasher: inout Hasher) {
        hasher.combine(first)
        hasher.combine(second)
    }

    package var hashValue: Int {
        var hasher = Hasher()
        hash(into: &hasher)
        return hasher.finalize()
    }
}

extension Pair: Codable where First: Decodable, First: Encodable, Second: Decodable, Second: Encodable {
    package func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(first, forKey: .first)
        try container.encode(second, forKey: .second)
    }

    package init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        first = try container.decode(First.self, forKey: .first)
        second = try container.decode(Second.self, forKey: .second)
    }
}
