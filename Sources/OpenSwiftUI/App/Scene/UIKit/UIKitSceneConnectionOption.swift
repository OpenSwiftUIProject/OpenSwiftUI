//
//  UIKitSceneConnectionOption.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: BA34A6F3A0251F524C88D21E37A272CE (SwiftUI)

#if os(iOS) || os(visionOS)
import OpenAttributeGraphShims
@_spi(Private)
import OpenSwiftUICore
import UIKit

// FIXME: UIKit private Swift API

public protocol UISceneConnectionOptionDefinition {
    associatedtype Payload: Codable
    associatedtype SceneType
    associatedtype SceneDelegate
    associatedtype SceneDelegateMethod
    static var sceneDelegateMethod: (SceneDelegate) -> SceneDelegateMethod { get }
    static func invokeSceneDelegate(_ method: SceneDelegateMethod, scene: SceneType, payload: Payload) -> Void
    static func didFinishHandling(payload: Payload, for scene: SceneType) -> Void
}

public enum UISceneConnectionOptionDefinitionError: Error {
    case invalidAction
    case definitionNotFound
    case missingDefinitionID
    case missingPayloadData
    case nonConformingDelegate
    case minimumSceneTypeNotSatisfied
}

public struct UISceneConnectionOptionDefinitionIdentifier {
    public let identifierString: String
    public let mangledName: String
}

// MARK: - AnyConnectionOptionActionBox

class AnyConnectionOptionActionBox {
    func dispatch<P>(_ payload: P) where P: Codable {
        _openSwiftUIBaseClassAbstractMethod()
    }
}

// MARK: - ConnectionOptionActionBox

class ConnectionOptionActionBox<Definition>: AnyConnectionOptionActionBox where Definition: UISceneConnectionOptionDefinition {
    var action: (Definition.Payload) -> Void

    init(action: @escaping (Definition.Payload) -> Void) {
        self.action = action
    }
    
    override func dispatch<T: Codable>(_ payload: T) {
        action(unsafeBitCast(payload, to: Definition.Payload.self))
    }
}

// MARK: - ConnectionOptionPayloadStorage

struct ConnectionOptionPayloadStorage {
    var types: [any UISceneConnectionOptionDefinition.Type]
    var actions: [ObjectIdentifier: [AnyConnectionOptionActionBox]]

    mutating func merge(_ other: ConnectionOptionPayloadStorage) {
        var typeSet = Set(types.map(ObjectIdentifier.init))

        for type in other.types {
            let id = ObjectIdentifier(type)
            guard !typeSet.contains(id) else {
                return
            }
            types.append(type)
            typeSet.insert(id)
        }
        actions.merge(other.actions) { existing, new in
            existing + new // [Q]
        }
    }
}

// MARK: - ConnectionOptionPayloadStoragePreferenceKey

struct ConnectionOptionPayloadStoragePreferenceKey: HostPreferenceKey {
    static var defaultValue: ConnectionOptionPayloadStorage = .init(types: [], actions: [:])

    static func reduce(value: inout ConnectionOptionPayloadStorage, nextValue: () -> ConnectionOptionPayloadStorage) {
        value.merge(nextValue())
    }
}

// MARK: - ConnectionOptionPayloadSceneModifier

private struct ConnectionOptionPayloadSceneModifier<Definition>: PrimitiveSceneModifier where Definition: UISceneConnectionOptionDefinition {
    var action: (Definition.Payload) -> Void

    static func _makeScene(
        modifier: _GraphValue<Self>,
        inputs: _SceneInputs,
        body: @escaping (_Graph, _SceneInputs) -> _SceneOutputs
    ) -> _SceneOutputs {
        var outputs = body(.init(), inputs)
        if inputs.preferences.requiresSceneList {
            outputs.preferences.sceneList = Attribute(
                UpdateSceneList(
                    modifier: modifier.value,
                    sceneList: .init(outputs.preferences.sceneList)
                )
            )
        }
        return outputs
    }
    
    struct UpdateSceneList: Rule {
        @Attribute var modifier: ConnectionOptionPayloadSceneModifier
        @OptionalAttribute var sceneList: SceneList?

        var value: SceneList {
            guard var sceneList else {
                return .init(items: [])
            }
            let actionBox = ConnectionOptionActionBox<Definition>(action: modifier.action)
            let updateItem = { (item: inout SceneList.Item) in
                item.connectionOptionPayloadStorage.types.append(Definition.self)
                item.connectionOptionPayloadStorage.actions[ObjectIdentifier(Definition.self), default: []].append(actionBox)
            }
            for index in sceneList.items.indices {
                updateItem(&sceneList.items[index])
            }
            return sceneList
        }
    }
}
#endif
