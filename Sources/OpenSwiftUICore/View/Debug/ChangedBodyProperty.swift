//
//  ChangedBodyProperty.swift
//  OpenSwiftUI
//
//  Audited for RELEASE_2021
//  Status: Complete

internal import OpenGraphShims
import Foundation

// MARK: - changedBodyProperties

package func changedBodyProperties<Body>(of type: Body.Type) -> [String] {
    #if canImport(Darwin)
    var index = 0
    repeat {
        let options = [
            Graph.descriptionFormat.takeUnretainedValue(): "stack/frame",
            "frame_index": index,
        ] as NSDictionary
        guard let description = Graph.description(nil, options: options),
              let dict = description.takeUnretainedValue() as? [String: Any],
              let nodeID = dict["node-id"] as? UInt32,
              let selfType = dict["self-type"] as? BodyAccessorRule.Type,
              selfType.container == Body.self
        else {
            index &+= 1
            continue
        }
        var properties: [String] = []
        let attribute = AnyAttribute(rawValue: nodeID)
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
                case let .product(fields):
                    guard let field = fields.first(where: { $0.offset == offset }),
                          let name = field.name,
                          let property = String(cString: name, encoding: .utf8)
                    else {
                        properties.append("@\(offset)")
                        return
                    }
                    properties.append(property)
                case .sum:
                    properties.append("@\(offset)")
                }
            }
        }
        return properties
    } while index != 32
    #endif
    return []
}

// MARK: - printChanges

package func printChangedBodyProperties<Body>(of type: Body.Type) {
    let properties = changedBodyProperties(of: type)
    var result = OGTypeID(type).description
    if properties.isEmpty {
        result.append(": unchanged.")
    } else {
        result.append(": \(properties.joined(separator: ", ")) changed.")
    }
    print(result)
}

// MARK: - logChanges

// Audited for RELEASE_2023

#if OPENSWIFTUI_SWIFT_LOG
import Logging

extension Logger {
    static let changeBodyPropertiesLogger = Logger(subsystem: "org.OpenSwiftUIProject.OpenSwiftUI", category: "Changed Body Properties")
}
#else
import os.log

@available(iOS 14.0, macOS 11, *)
extension Logger {
    static let changeBodyPropertiesLogger = Logger(subsystem: "org.OpenSwiftUIProject.OpenSwiftUI", category: "Changed Body Properties")
}

extension OSLog {
    static let changeBodyPropertiesLogger = OSLog(subsystem: "org.OpenSwiftUIProject.OpenSwiftUI", category: "Changed Body Properties")
}
#endif

package func logChangedBodyProperties<Body>(of type: Body.Type) {
    let properties = changedBodyProperties(of: type)
    let result = OGTypeID(type).description
    if properties.isEmpty {
        #if OPENSWIFTUI_SWIFT_LOG
        Logger.changeBodyPropertiesLogger.info("\(result): unchanged.")
        #else
        if #available(iOS 14.0, macOS 11, *) {
            Logger.changeBodyPropertiesLogger.info("\(result, privacy: .public): unchanged.")
        } else {
            os_log("%{public}s: unchanged.", log: .changeBodyPropertiesLogger, type: .info, result)
        }
        #endif
    } else {
        #if OPENSWIFTUI_SWIFT_LOG
        Logger.changeBodyPropertiesLogger.info("\(result): \(properties.joined(separator: ", ")) changed.")
        #else
        if #available(iOS 14.0, macOS 11, *) {
            Logger.changeBodyPropertiesLogger.info("\(result, privacy: .public): \(properties.joined(separator: ", "), privacy: .public) changed.")
        } else {
            os_log("%{public}s: %{public}s changed.", log: .changeBodyPropertiesLogger, type: .info, result, properties.joined(separator: ", "))
        }
        #endif
    }
}
