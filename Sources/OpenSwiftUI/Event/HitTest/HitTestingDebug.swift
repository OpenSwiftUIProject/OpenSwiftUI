//
//  HitTestingDebug.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: WIP
//  ID: DB5E6F06E13FF0259F656B4E03BE4F79 (SwiftUI)

import COpenSwiftUI
@_spi(ForOpenSwiftUIOnly)
import OpenSwiftUICore

// MARK: - HitTestTracing

private protocol HitTestTracing {
    var propertiesAffectingHitTest: [(key: String?, value: String)] { get }
    func isEqual(to other: Self) -> Bool
}

// MARK: - HitTestTrace

private struct HitTestTrace<Value> where Value: HitTestTracing {
    let value: Value
    let name: String
    let identifier: String
    let point: CGPoint
    let result: Value?
    let children: [HitTestTrace<Value>]

    func map<Other: HitTestTracing>(_ transform: (Value) -> Other) -> HitTestTrace<Other> {
        HitTestTrace<Other>(
            value: transform(value),
            name: name,
            identifier: identifier,
            point: point,
            result: result.map(transform),
            children: children.map { $0.map(transform) }
        )
    }

    func recursiveDescription(annotating values: [Value], depth: Int = 0) -> String {
        let annotated = values.contains { value.isEqual(to: $0) }
        let prefix = String(repeating: annotated ? "├─" : "│ ", count: depth)
            + (annotated ? "▶" : result == nil ? "✕" : "✓")
        let properties = value.propertiesAffectingHitTest.map { key, value in
            key.map { "\($0): \(value)" } ?? value
        }
        let description = "\(name)(\(([identifier] + properties).joined(separator: ", ")))"
        return (["\(prefix) \(point) \(description)"] + children.map {
            $0.recursiveDescription(annotating: values, depth: depth + 1)
        }).joined(separator: "\n")
    }
}

