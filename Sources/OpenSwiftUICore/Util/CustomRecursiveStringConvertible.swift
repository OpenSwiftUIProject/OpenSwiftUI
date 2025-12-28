//
//  CustomRecursiveStringConvertible.swift
//  OpenSwiftUICore
//
//  Status: WIP
//  Audited for 6.5.4
//  ID: 2DFA09903A864CB0F038E089ECDB7AF8 (SwiftUICore)

import Foundation

// MARK: - CustomRecursiveStringConvertible [WIP]

package protocol CustomRecursiveStringConvertible {
    var descriptionName: String { get }

    var descriptionAttributes: [(name: String, value: String)] { get }

    var defaultDescriptionAttributes: Set<DefaultDescriptionAttribute> { get }

    var descriptionChildren: [any CustomRecursiveStringConvertible] { get }

    var hideFromDescription: Bool { get }
}

extension CustomRecursiveStringConvertible {
    package var defaultDescriptionAttributes: Set<DefaultDescriptionAttribute> {
        DefaultDescriptionAttribute.all
    }

    package var descriptionChildren: [any CustomRecursiveStringConvertible] {
        []
    }

    package var hideFromDescription: Bool {
       false
    }
}

extension CustomRecursiveStringConvertible {
    package var descriptionName: String {
        recursiveDescriptionName(Self.self)
    }

    package var descriptionAttributes: [(name: String, value: String)] {
        []
    }

    package var recursiveDescription: String {
        _recursiveDescription(indent: 0, rounded: false)
    }

    package var roundedRecursiveDescription: String {
        _recursiveDescription(indent: 0, rounded: true)
    }

    package func _recursiveDescription(
        indent: Int,
        rounded: Bool
    ) -> String {
        _openSwiftUIUnimplementedFailure()
    }

    package var topLevelAttributes: [(name: String, value: String)] {
        _openSwiftUIUnimplementedFailure()
    }
}

// MARK: - BridgeStringConvertible

package protocol BridgeStringConvertible {
    var bridgeDescriptionChildren: [any CustomRecursiveStringConvertible] { get }
}

extension BridgeStringConvertible {
    package var bridgeDescriptionChildren: [any CustomRecursiveStringConvertible] { [] }
}

// MARK: - CustomRecursiveStringConvertible Helpers [WIP]

package func recursiveDescriptionName(_ type: any Any.Type) -> String {
    _openSwiftUIUnimplementedFailure()
}

extension String {
    package func tupleOfDoubles() -> [(label: String, value: Double)]? {
        guard let first, first == "(",
              let last, last == ")"
        else { return nil }

        func decomposeTuple() -> (labels: [String], values: [String]) {
            let inner = dropFirst().dropLast()
            let parts = inner.split(separator: ",", omittingEmptySubsequences: true)
            var labels: [String] = []
            var values: [String] = []
            for part in parts {
                if let colonIndex = part.firstIndex(of: ":") {
                    let label = String(part[..<colonIndex]).trimmingCharacters(in: .whitespaces)
                    let value = String(part[part.index(after: colonIndex)...]).trimmingCharacters(in: .whitespaces)
                    labels.append(label)
                    values.append(value)
                } else {
                    labels.append("")
                    values.append(part.trimmingCharacters(in: .whitespaces))
                }
            }
            return (labels: labels, values: values)
        }

        let (labels, values) = decomposeTuple()
        var doubles: [Double] = []
        for valueString in values {
            guard let value = Double(valueString) else {
                return nil
            }
            doubles.append(value)
        }
        guard labels.count == doubles.count else { return nil }
        return zip(labels, doubles).map { (label: $0, value: $1) }
    }
}

extension Sequence where Element == (name: String, value: String) {
    package func roundedAttributes() -> [(name: String, value: String)] {
        preconditionFailure("TODO")
    }
}

extension Color.Resolved {
    package var name: String? {
        _openSwiftUIUnimplementedFailure()
    }
}

private func colorNameForColorComponents(_ r: Float, _ g: Float, _ b: Float, _ a: Float) -> String? {
    nil
}
