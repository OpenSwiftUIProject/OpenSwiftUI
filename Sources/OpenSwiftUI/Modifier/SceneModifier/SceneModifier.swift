//
//  SceneModifier.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: 88477CCB0AEDAD452D0818B33FCEDC5F (SwiftUI)

import OpenAttributeGraphShims
import OpenSwiftUICore

// MARK: - _SceneModifier

@available(OpenSwiftUI_v2_0, *)
public protocol _SceneModifier {
    associatedtype Body: Scene

    @SceneBuilder
    func body(content: SceneContent) -> Body

    typealias SceneContent = _SceneModifier_Content<Self>

    static func _makeScene(
        modifier: _GraphValue<Self>,
        inputs: _SceneInputs,
        body: @escaping (_Graph, _SceneInputs) -> _SceneOutputs
    ) -> _SceneOutputs
}

// MARK: - PrimitiveSceneModifier

protocol PrimitiveSceneModifier: _SceneModifier where Body == Never {}

extension _SceneModifier {
    func sceneBodyError() -> Never {
        preconditionFailure("body() should not be called on \(self).")
    }
}

@available(OpenSwiftUI_v2_0, *)
extension _SceneModifier where Body == Never {
    public func body(content: SceneContent) -> Body {
        sceneBodyError()
    }
}

// MARK: - _GraphInputsModifier + _SceneModifier

@available(OpenSwiftUI_v2_0, *)
extension _SceneModifier where Self: _GraphInputsModifier, Body == Never {
    public static func _makeScene(
        modifier: _GraphValue<Self>,
        inputs: _SceneInputs,
        body: @escaping (_Graph, _SceneInputs) -> _SceneOutputs
    ) -> _SceneOutputs {
        var inputs = inputs
        _makeInputs(modifier: modifier, inputs: &inputs.base)
        return body(.init(), inputs)
    }
}

// MARK: - EmptyModifier + _SceneModifier

@available(OpenSwiftUI_v2_0, *)
extension EmptyModifier: _SceneModifier {
    @MainActor
    @preconcurrency
    public static func _makeScene(
        modifier: _GraphValue<EmptyModifier>,
        inputs: _SceneInputs,
        body: @escaping (_Graph, _SceneInputs) -> _SceneOutputs
    ) -> _SceneOutputs {
        body(.init(), inputs)
    }
}

// MARK: - Scene + modifier

@available(OpenSwiftUI_v2_0, *)
extension Scene {
    @inlinable
    @MainActor
    @preconcurrency
    internal func modifier<T>(_ modifier: T) -> ModifiedContent<Self, T> {
        return .init(content: self, modifier: modifier)
    }
}

@_spi(Private)
@available(OpenSwiftUI_v4_0, *)
extension Scene {
    @_spi(Private)
    nonisolated public func sceneModifier<T>(_ modifier: T) -> ModifiedContent<Self, T> {
        self.modifier(modifier)
    }
}

// MARK: - ModifiedContent + Scene & _SceneModifier

@available(OpenSwiftUI_v2_0, *)
extension ModifiedContent: Scene where Content: Scene, Modifier: _SceneModifier {
    nonisolated public static func _makeScene(
        scene: _GraphValue<Self>,
        inputs: _SceneInputs
    ) -> _SceneOutputs {
        Modifier._makeScene(
            modifier: scene[offset: { .of(&$0.modifier) }],
            inputs: inputs
        ) {
            Content._makeScene(
                scene: scene[offset: { .of(&$0.content) }],
                inputs: $1
            )
        }
    }

    @MainActor
    @preconcurrency
    public var body: Body {
        sceneBodyError()
    }
}

@available(OpenSwiftUI_v2_0, *)
extension ModifiedContent: _SceneModifier where Content: _SceneModifier, Modifier: _SceneModifier {
    public static func _makeScene(
        modifier: _GraphValue<Self>,
        inputs: _SceneInputs,
        body: @escaping (_Graph, _SceneInputs) -> _SceneOutputs
    ) -> _SceneOutputs {
        Modifier._makeScene(
            modifier: modifier[offset: { .of(&$0.modifier) }],
            inputs: inputs
        ) {
            Content._makeScene(
                modifier: modifier[offset: { .of(&$0.content) }],
                inputs: $1,
                body: body
            )
        }
    }
}

// MARK: - _SceneModifier + concat

@available(OpenSwiftUI_v2_0, *)
extension _SceneModifier {
    @inlinable
    internal func concat<T>(_ modifier: T) -> ModifiedContent<Self, T> {
        return .init(content: self, modifier: modifier)
    }
}

// MARK: - _SceneModifier_Content

@available(OpenSwiftUI_v2_0, *)
@MainActor
@preconcurrency
public struct _SceneModifier_Content<Modifier>: PrimitiveScene where Modifier: _SceneModifier {
    nonisolated public static func _makeScene(
        scene: _GraphValue<Self>,
        inputs: _SceneInputs
    ) -> _SceneOutputs {
        var inputs = inputs
        guard let body = inputs.popLast(BodyInput.self) else {
            return .init()
        }
        return body(.init(), inputs)
    }

    fileprivate struct BodyInput: SceneInput {
        typealias BodyInputElement = (_Graph, _SceneInputs) -> _SceneOutputs

        static var defaultValue: Stack<BodyInputElement> { .init() }
    }
}

@available(*, unavailable)
extension _SceneModifier_Content: Sendable {}

// MARK: - _SceneModifier default implementation

@available(OpenSwiftUI_v2_0, *)
extension _SceneModifier {
    public static func _makeScene(
        modifier: _GraphValue<Self>,
        inputs: _SceneInputs,
        body: @escaping (_Graph, _SceneInputs) -> _SceneOutputs
    ) -> _SceneOutputs {
        let fields = DynamicPropertyCache.fields(of: Self.self)
        var inputs = inputs
        let (scene, buffer) = makeBody(modifier: modifier, inputs: &inputs.base, fields: fields)
        inputs.append(body, to: _SceneModifier_Content<Self>.BodyInput.self)
        let outputs = Body._makeScene(scene: scene, inputs: inputs)
        if let buffer {
            buffer.traceMountedProperties(to: modifier, fields: fields)
        }
        return outputs
    }

    private static func makeBody(
        modifier: _GraphValue<Self>,
        inputs: inout _GraphInputs,
        fields: DynamicPropertyCache.Fields
    ) -> (_GraphValue<Body>, _DynamicPropertyBuffer?) {
        precondition(
            Metadata(Self.self).isValueType,
            "view modifiers must be value types: \(Self.self)"
        )
        let accessor = AppModifierBodyAccessor<Self>()
        return accessor.makeBody(container: modifier, inputs: &inputs, fields: fields)
    }
}

// MARK: - AppModifierBodyAccessor

private struct AppModifierBodyAccessor<Modifier>: BodyAccessor where Modifier: _SceneModifier {
    typealias Container = Modifier

    typealias Body = Modifier.Body

    func updateBody(of container: Container, changed: Bool) {
        guard changed else {
            return
        }
        setBody {
            container.body(content: .init())
        }
    }
}
