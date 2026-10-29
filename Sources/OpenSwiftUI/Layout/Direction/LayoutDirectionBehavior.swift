//
//  LayoutDirectionBehavior.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: 72C5A4740F0BD901F7ED529BBDFB6899 (SwiftUI)

import Foundation
import OpenAttributeGraphShims
import OpenCoreGraphicsShims
@_spi(ForOpenSwiftUIOnly)
public import OpenSwiftUICore

// MARK: - View + LayoutDirectionBehavior

@available(OpenSwiftUI_v5_0, *)
extension View {
    /// Sets the behavior of this view for different layout directions.
    ///
    /// Use `layoutDirectionBehavior(_:)` when you need the system to
    /// horizontally mirror the contents of the view when presented in a
    /// layout direction.
    ///
    /// To override the layout direction for a specific view, use the
    /// ``View/environment(_:_:)`` view modifier to explicitly override
    /// the ``EnvironmentValues/layoutDirection`` environment value for
    /// the view.
    ///
    /// - Parameter behavior: A LayoutDirectionBehavior value that indicates
    ///   whether this view should mirror in a particular layout direction. By
    ///   default, views will adjust their layouts automatically in a
    ///   right-to-left context and do not need to be mirrored.
    ///
    /// - Returns: A view that conditionally mirrors its contents
    ///   horizontally in a given layout direction.
    @inlinable
    nonisolated public func layoutDirectionBehavior(_ behavior: LayoutDirectionBehavior) -> some View {
        modifier(_LayoutDirectionBehaviorEffect(behavior: behavior))
    }
}

// MARK: - _LayoutDirectionBehaviorEffect

@available(OpenSwiftUI_v5_0, *)
@frozen
nonisolated public struct _LayoutDirectionBehaviorEffect: ViewModifier, MultiViewModifier, PrimitiveViewModifier {
    public var behavior: LayoutDirectionBehavior

    @inlinable
    public init(behavior: LayoutDirectionBehavior) {
        self.behavior = behavior
    }

    nonisolated public static func _makeView(
        modifier: _GraphValue<Self>,
        inputs: _ViewInputs,
        body: @escaping (_Graph, _ViewInputs) -> _ViewOutputs
    ) -> _ViewOutputs {
        let layoutDirection = inputs.layoutDirection
        var childInputs = inputs
        childInputs.environment = Attribute(FlipForRTLEnvironment(
            effect: modifier.value,
            environment: inputs.environment
        ))
        childInputs.transform = Attribute(FlipForRTLTransform(
            effect: modifier.value,
            size: inputs.animatedSize(),
            position: inputs.animatedPosition(),
            transform: inputs.transform,
            layoutDirection: layoutDirection
        ))
        let frame = Attribute(FlipForRTLFrame(
            effect: modifier.value,
            position: inputs.position,
            size: inputs.size,
            layoutDirection: layoutDirection,
            pixelLength: inputs.pixelLength
        ))
        childInputs.position = frame[keyPath: \.origin]
        childInputs.size = frame[keyPath: \.size]
        childInputs.containerPosition = Attribute(FlipForRTLContainerPosition(
            effect: modifier.value,
            containerPosition: inputs.containerPosition,
            layoutDirection: layoutDirection
        ))
        var outputs = body(_Graph(), childInputs)
        if inputs.preferences.requiresDisplayList {
            let identity = DisplayList.Identity()
            inputs.pushIdentity(identity)
            outputs.displayList = Attribute(FlipForRTLDisplayList(
                identity: identity,
                effect: modifier.value,
                position: inputs.animatedPosition(),
                size: inputs.animatedSize(),
                layoutDirection: layoutDirection,
                containerPosition: inputs.containerPosition,
                content: .init(outputs.displayList)
            ))
        }
        return outputs
    }
}

@available(OpenSwiftUI_v5_0, *)
extension _LayoutDirectionBehaviorEffect: Sendable {}

// MARK: - FlipForRTLContainerPosition

private struct FlipForRTLContainerPosition: Rule, AsyncAttribute {
    @Attribute var effect: _LayoutDirectionBehaviorEffect
    @Attribute var containerPosition: CGPoint
    @Attribute var layoutDirection: LayoutDirection

    var value: CGPoint {
        effect.behavior.shouldFlip(in: layoutDirection) ? .zero : containerPosition
    }
}

// MARK: - FlipForRTLFrame

private struct FlipForRTLFrame: Rule, AsyncAttribute {
    @Attribute var effect: _LayoutDirectionBehaviorEffect
    @Attribute var position: CGPoint
    @Attribute var size: ViewSize
    @Attribute var layoutDirection: LayoutDirection
    @Attribute var pixelLength: CGFloat

    var value: ViewFrame {
        var frame = ViewFrame(origin: position, size: size)
        if effect.behavior.shouldFlip(in: layoutDirection) {
            frame.round(toMultipleOf: pixelLength)
            frame.origin = .zero
        }
        return frame
    }
}

// MARK: - FlipForRTLTransform

private struct FlipForRTLTransform: Rule, AsyncAttribute {
    @Attribute var effect: _LayoutDirectionBehaviorEffect
    @Attribute var size: ViewSize
    @Attribute var position: CGPoint
    @Attribute var transform: ViewTransform
    @Attribute var layoutDirection: LayoutDirection

    var value: ViewTransform {
        let shouldFlip = effect.behavior.shouldFlip(in: layoutDirection)
        var transform = transform
        if shouldFlip {
            transform.resetPosition(position)
            transform.appendAffineTransform(
                CGAffineTransform(a: -1, b: 0, c: 0, d: 1, tx: size.width, ty: 0),
                inverse: true
            )
        }
        return transform
    }
}

// MARK: - FlipForRTLEnvironment

private struct FlipForRTLEnvironment: Rule, AsyncAttribute {
    @Attribute var effect: _LayoutDirectionBehaviorEffect
    @Attribute var environment: EnvironmentValues

    var value: EnvironmentValues {
        var environment = environment
        if case let .mirrors(direction) = effect.behavior {
            environment.layoutDirection = direction.opposite
        }
        return environment
    }
}

// MARK: - FlipForRTLDisplayList

private struct FlipForRTLDisplayList: Rule, AsyncAttribute {
    let identity: DisplayList.Identity
    @Attribute var effect: _LayoutDirectionBehaviorEffect
    @Attribute var position: CGPoint
    @Attribute var size: ViewSize
    @Attribute var layoutDirection: LayoutDirection
    @Attribute var containerPosition: CGPoint
    @OptionalAttribute var content: DisplayList?

    var value: DisplayList {
        let content = content ?? DisplayList()
        guard !content.isEmpty else {
            return DisplayList()
        }
        guard effect.behavior.shouldFlip(in: layoutDirection) else {
            return content
        }
        let transform = CGAffineTransform(a: -1, b: 0, c: 0, d: 1, tx: size.width, ty: 0)
        let origin = CGPoint(position - containerPosition)
        return DisplayList(DisplayList.Item(
            .effect(.transform(.affine(transform)), content),
            frame: CGRect(origin: origin, size: size.value),
            identity: identity,
            version: .init(forUpdate: ())
        ))
    }
}
