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

// MARK: - recursiveDescriptionName

package func recursiveDescriptionName(_ type: any Any.Type) -> String {
    var name = "\(type)"
    if name.first == "(" {
        var substring = name.dropFirst()
        if let spaceIndex = substring.firstIndex(of: " ") {
            substring.removeSubrange(spaceIndex...)
        }
        name = String(substring)
    }
    if let angleIndex = name.firstIndex(of: "<") {
        name = String(name[..<angleIndex])
    }
    return name
}

// MARK: - String + Extension

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

    fileprivate func escapeXML() -> String {
        var result = ""
        result.reserveCapacity(count)
        for char in self {
            switch char {
            case "\"": result.append("&quot;")
            case "&": result.append("&amp;")
            case "'": result.append("&apos;")
            case "<": result.append("&lt;")
            case ">": result.append("&gt;")
            case "\n": result.append("\\n")
            case "\r": result.append("\\r")
            default: result.append(char)
            }
        }
        return result
    }
}

// MARK: - Sequence.roundedAttributes [?]

extension Sequence where Element == (name: String, value: String) {
    package func roundedAttributes() -> [(name: String, value: String)] {
        map { (name, value) in
            if let doubleValue = Double(value) {
                let rounded = round(doubleValue * 256.0) / 256.0
                return (name: name, value: rounded.description)
            } else if let tupleValues = value.tupleOfDoubles() {
                let roundedTuple = tupleValues.map { (label: $0.label, value: round($0.value * 256.0) / 256.0) }
                if roundedTuple.count == 4,
                   name.range(of: "color", options: .caseInsensitive) != nil
                {
                    let floats = roundedTuple.map { Float($0.value) }
                    if let colorName = colorNameForColorComponents(floats[0], floats[1], floats[2], floats[3]) {
                        return (name: name, value: colorName)
                    }
                }
                let parts: [String] = roundedTuple.map { item in
                    if item.label.isEmpty {
                        return "\(item.value)"
                    } else {
                        return "\(item.label): \(item.value)"
                    }
                }
                return (name: name, value: "(" + parts.joined(separator: ", ") + ")")
            } else {
                return (name, value)
            }
        }
    }
}

// MARK: - Color.Resolved.name

extension Color.Resolved {
    package var name: String? {
        @inline(__always)
        func quantize(_ value: Float) -> Float {
            round(value * 256.0) / 256.0
        }
        return colorNameForColorComponents(
            quantize(linearRed),
            quantize(linearGreen),
            quantize(linearBlue),
            quantize(opacity)
        )
    }
}

private func colorNameForColorComponents(_ r: Float, _ g: Float, _ b: Float, _ a: Float) -> String? {
    if r == 0 && g == 0 && b == 0 {
        if a == 0 {
            return "clear"
        } else if a == 1 {
            return "black"
        }
    }
    if r == 1 && g == 1 && b == 1 && a == 1 {
        return "white"
    } else if r == 8.0 / 256.0 && g == 8.0 / 256.0 && b == 8.0 / 256.0 && a == 1 {
        return "gray"
    } else if r == 1 && g == 0 && b == 0 && a == 1 {
        return "red"
    } else if r == 1 && g == 11.0 / 256.0 && b == 11.0 / 256.0 && a == 1 {
        return "system-red"
    } else if r == 1 && g == 15.0 / 256.0 && b == 11.0 / 256.0 && a == 1 {
        return "system-red-dark"
    } else if r == 0 && g == 1 && b == 0 && a == 1 {
        return "green"
    } else if r == 0 && g == 0 && b == 1 && a == 1 {
        return "blue"
    } else if r == 1 && g == 1 && b == 0 && a == 1 {
        return "yellow"
    } else if r == 55.0 / 256.0 && g == 0 && b == 55.0 / 256.0 && a == 1 {
        return "purple"
    } else if r == 1 && g == 55.0 / 256.0 && b == 0 && a == 1 {
        return "orange"
    } else if r == 0 && g == 1 && b == 1 && a == 1 {
        return "teal"
    } else if r == 55.0 / 256.0 && g == 55.0 / 256.0 && b == 1 && a == 1 {
        return "indigo"
    } else if r == 1 && g == 0 && b == 55.0 / 256.0 && a == 1 {
        return "pink"
    } else if r == 12.0 / 256.0 && g == 12.0 / 256.0 && b == 14.0 / 256.0 && a == 64.0 / 256.0 {
        return "brown"
    } else if r == 12.0 / 256.0 && g == 12.0 / 256.0 && b == 14.0 / 256.0 && a == 76.0 / 256.0 {
        return "placeholder-text"
    } else {
        return nil
    }
}
