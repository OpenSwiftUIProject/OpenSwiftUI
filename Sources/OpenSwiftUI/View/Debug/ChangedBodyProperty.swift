//
//  ChangedBodyProperty.swift
//  OpenSwiftUI
//
//  Audited for RELEASE_2021
//  Status: Complete

#if canImport(Darwin)
internal import OpenGraphShims
import Foundation

extension View {
    public static func _printChanges() {
        printChangedBodyProperties(of: Self.self)
    }
}

extension ViewModifier {
    public static func _printChanges() {
        printChangedBodyProperties(of: Self.self)
    }
}

func printChangedBodyProperties<Body>(of type: Body.Type) {
    let properties = changedBodyProperties(of: type)
    var result = OGTypeID(type).description
    if properties.isEmpty {
        result.append(": unchanged.")
    } else {
        result.append(": \(properties.joined(separator: ", ")) changed.")
    }
    print(result)
}

func changedBodyProperties<Body>(of type: Body.Type) -> [String] {
    var index = 0
    repeat {
        let options = [
            OGGraph.descriptionFormat.takeUnretainedValue(): "stack/frame",
            "frame_index": index
        ] as NSDictionary
        guard let description = OGGraph.description(nil, options: options),
              let dict = description.takeUnretainedValue() as? [String: Any],
              let nodeID = dict["node-id"] as? UInt32,
              let selfType = dict["self-type"] as? BodyAccessorRule.Type,
              selfType.container == Body.self
        else {
            index &+= 1
            continue
        }
        var properties: [String] = []
        let attribute = OGAttribute(rawValue: nodeID)
        let metaProperties = selfType.metaProperties(as: type, attribute: attribute)
        if !metaProperties.isEmpty, let inputs = dict["inputs"] as? [[String: Any]] {
            for metaProperty in metaProperties {
                for input in inputs {
                    guard let id = input["id"] as? UInt32,
                          id == metaProperty.1.rawValue,
                          let changed = input["changed"] as? Bool,
                          changed
                    else {
                        continue
                    }
                    properties.append(metaProperty.0)
                }
            }
        }
        if let buffer = selfType.buffer(as: type, attribute: attribute) {
            let fields = DynamicPropertyCache.fields(of: Body.self)
            buffer.applyChanged { offset in
                switch fields.layout {
                case .product(let fields):
                    guard let field = fields.first(where: { $0.offset == offset }),
                        let name = field.name,
                        let property = String(cString: name, encoding: .utf8) else {
                        properties.append("@\(offset)")
                        return
                    }
                    properties.append(property)
                    break
                case .sum(_, _):
                    properties.append("@\(offset)")
                    break
                }
            }
        }
        return properties
    } while (index != 32)
    return []
}
#endif
