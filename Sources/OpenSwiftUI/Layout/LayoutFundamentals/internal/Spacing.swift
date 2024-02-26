//
//  Spacing.swift
//  OpenSwiftUI
//
//  Audited for RELEASE_2021
//  Status: TODO
//  ID: 127A76D3C8081D0134153BE9AE746714

#if canImport(Darwin)
import CoreGraphics
#else
import Foundation
#endif

struct Spacing {
    // TODO
    static let zero = Spacing(minima: [:])
    static let zeroHorizontal = Spacing(minima: [:])
    static let zeroVertical = Spacing(minima: [:])

    var minima: [Key: CGFloat]

    func distanceToSuccessorView(along axis: Axis, preferring spacing: Spacing) -> CGFloat? {
        if minima.count >= spacing.minima.count {
            switch axis {
            case .horizontal: _distance(from: .leading, to: .trailing, ofViewPreferring: spacing)
            case .vertical: _distance(from: .top, to: .bottom, ofViewPreferring: spacing)
            }
        } else {
            switch axis {
            case .horizontal: _distance(from: .trailing, to: .leading, ofViewPreferring: spacing)
            case .vertical: _distance(from: .bottom, to: .top, ofViewPreferring: spacing)
            }
        }
    }

    private func _distance(from: Edge, to: Edge, ofViewPreferring spacing: Spacing) -> CGFloat? {
        // TODO
        nil
    }

    func reset(_ edge: Edge.Set) {
        guard !edge.isEmpty else {
            return
        }
        // TODO
    }

    func clear(_ edge: Edge.Set) {
        guard !edge.isEmpty else {
            return
        }
        // TODO
    }

    func incorporate(_ edge: Edge.Set, of spacing: Spacing) {
        // TODO
    }
}

// MARK: - Spacing.Key

extension Spacing {
    struct Key: Hashable {
        var category: Category?
        var edge: Edge
    }
}

// MARK: - Spacing.Category

extension Spacing {
    struct Category: Hashable {
        let id: ObjectIdentifier
    }
}

extension Spacing.Category {
    private enum TextToText {}
    private enum TextBaseline {}
    private enum EdgeBelowText {}
    private enum EdgeAboveText {}
    static let textToText: Self = .init(id: .init(TextToText.self))
    static let textBaseline: Self = .init(id: .init(TextBaseline.self))
    static let edgeBelowText: Self = .init(id: .init(EdgeBelowText.self))
    static let edgeAboveText: Self = .init(id: .init(EdgeAboveText.self))
}
