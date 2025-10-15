//
//  OpacityEffect.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: WIP
//  ID: 34FFA2034B9AD53E0463E3971529C5A1 (SwiftUICore)

package import OpenCoreGraphicsShims
import OpenAttributeGraphShims

// MARK: - _OpacityEffect

@available(OpenSwiftUI_v1_0, *)
@frozen
@MainActor
@preconcurrency
public struct _OpacityEffect: RendererEffect, Equatable {
    public var opacity: Double

    @inlinable
    nonisolated public init(opacity: Double) {
        self.opacity = opacity
    }

    public var animatableData: Double {
        get { opacity }
        set { opacity = newValue }
    }

    package func effectValue(size: CGSize) -> DisplayList.Effect {
        .opacity(Float(opacity))
    }

    nonisolated public static func _makeView(
        modifier: _GraphValue<Self>,
        inputs: _ViewInputs,
        body: @escaping (_Graph, _ViewInputs) -> _ViewOutputs
    ) -> _ViewOutputs {
        makeRendererEffect(effect: modifier, inputs: inputs) { graph, inputs in
            var outputs = body(graph, inputs)
            if inputs.preferences.requiresViewResponders {
                let responder = OpacityViewResponder(inputs: inputs)
                outputs.preferences.viewResponders = Attribute(
                    OpacityResponderFilter(
                        effect: modifier.value,
                        children: .init(outputs.preferences.viewResponders),
                        responder: responder
                    )
                )
            }
            return outputs
        }
    }
}

// MARK: - View + opacity

@available(OpenSwiftUI_v1_0, *)
extension View {

    /// Sets the transparency of this view.
    ///
    /// Apply opacity to reveal views that are behind another view or to
    /// de-emphasize a view.
    ///
    /// When applying the `opacity(_:)` modifier to a view that has already had
    /// its opacity transformed, the modifier multiplies the effect of the
    /// underlying opacity transformation.
    ///
    /// The example below shows yellow and red rectangles configured to overlap.
    /// The top yellow rectangle has its opacity set to 50%, allowing the
    /// occluded portion of the bottom rectangle to be visible:
    ///
    ///     struct Opacity: View {
    ///         var body: some View {
    ///             VStack {
    ///                 Color.yellow.frame(width: 100, height: 100, alignment: .center)
    ///                     .zIndex(1)
    ///                     .opacity(0.5)
    ///
    ///                 Color.red.frame(width: 100, height: 100, alignment: .center)
    ///                     .padding(-40)
    ///             }
    ///         }
    ///     }
    ///
    /// ![Two overlaid rectangles, where the topmost has its opacity set to 50%,
    /// which allows the occluded portion of the bottom rectangle to be
    /// visible.](OpenSwiftUI-View-opacity.png)
    ///
    /// - Parameter opacity: A value between 0 (fully transparent) and 1 (fully
    ///   opaque).
    ///
    /// - Returns: A view that sets the transparency of this view.
    @inlinable
    nonisolated public func opacity(_ opacity: Double) -> some View {
        modifier(_OpacityEffect(opacity: opacity))
    }
}

// MARK: OpacityRendererEffect

@MainActor
@preconcurrency
package struct OpacityRendererEffect: RendererEffect {
    package var opacity: Double

    package init(opacity: Double) {
        self.opacity = opacity
    }

    package init(isHidden: Bool) {
        self.opacity = isHidden ? 0.0 : 1.0
    }

    package var animatableData: Double {
        get { opacity }
        set { opacity = newValue }
    }

    package func effectValue(size: CGSize) -> DisplayList.Effect {
        .opacity(Float(opacity))
    }

    nonisolated package static func _makeView(
        modifier: _GraphValue<Self>,
        inputs: _ViewInputs,
        body: @escaping (_Graph, _ViewInputs) -> _ViewOutputs
    ) -> _ViewOutputs {
        makeRendererEffect(effect: modifier, inputs: inputs, body: body)
    }
}

// MARK: - OpacityViewResponder

private final class OpacityViewResponder: DefaultLayoutViewResponder {
    var _opacity: Double

    override init(inputs: _ViewInputs) {
        _opacity = 1.0
        super.init(inputs: inputs)
    }

    override init(inputs: _ViewInputs, viewSubgraph: Subgraph) {
        _opacity = 1.0
        super.init(inputs: inputs, viewSubgraph: viewSubgraph)
    }

    override var opacity: Double { _opacity }

    override func containsGlobalPoints(
        _ points: [PlatformPoint],
        cacheKey: UInt32?,
        options: ViewResponder.ContainsPointsOptions
    ) -> ViewResponder.ContainsPointsResult {
        guard _opacity > 0 else {
            return .init(mask: [], priority: .zero, children: children)
        }
        return super.containsGlobalPoints(points, cacheKey: cacheKey, options: options)
    }

    override func extendPrintTree(string: inout String) {
        string.append("opacity \(_opacity)")
    }
}

// MARK: Transition + Opacity

@available(OpenSwiftUI_v1_0, *)
extension AnyTransition {

    /// A transition from transparent to opaque on insertion, and from opaque to
    /// transparent on removal.
    public static let opacity: AnyTransition = .init(OpacityTransition())
}

@available(OpenSwiftUI_v5_0, *)
extension Transition where Self == OpacityTransition {

    /// A transition from transparent to opaque on insertion, and from opaque to
    /// transparent on removal.
    @_alwaysEmitIntoClient
    @MainActor
    @preconcurrency
    public static var opacity: OpacityTransition {
      get { Self() }
    }
}

// MARK: _OpacityEffect + ProtobufMessage

extension _OpacityEffect: ProtobufMessage {
    package func encode(to encoder: inout ProtobufEncoder) throws {
        encoder.floatField(1, Float(opacity), defaultValue: 1.0)
    }

    package init(from decoder: inout ProtobufDecoder) throws {
        var opacity = 1.0
        while let field = try decoder.nextField() {
            switch field.tag {
            case 1: opacity = Double(try decoder.floatField(field))
            default: try decoder.skipField(field)
            }
        }
        self.init(opacity: opacity)
    }
}

// MARK: - ShapeStyle + _OpacityShapeStyle

// TODO: _OpacityShapeStyle

// TODO: _OpacitiesShapeStyle

// MARK: - OpacityTransition

/// A transition from transparent to opaque on insertion, and from opaque to
/// transparent on removal.
@available(OpenSwiftUI_v5_0, *)
public struct OpacityTransition: Transition {
    public init() {}

    public func body(
        content: OpacityTransition.Content,
        phase: TransitionPhase
    ) -> some View {
        content.modifier(
            OpacityRendererEffect(opacity: phase.isIdentity ? 1.0 : 0.0)
        )
    }

    public static let properties: TransitionProperties = .init(hasMotion: false)

    public func _makeContentTransition(
        transition: inout _Transition_ContentTransition
    ) {
        switch transition.operation {
        case .hasContentTransition:
            transition.result = .bool(false)
        case .effects:
            transition.result = .effects([.init(type: .opacity)])
        }
    }
}

@available(*, unavailable)
extension OpacityTransition: Sendable {}

// MARK: - OpacityResponderFilter

struct OpacityResponderFilter: StatefulRule {
    @Attribute var effect: _OpacityEffect
    @OptionalAttribute var children: [ViewResponder]?
    fileprivate let responder: OpacityViewResponder

    typealias Value = [ViewResponder]

    func updateValue() {
        responder._opacity = effect.opacity
        if let (children, changed) = $children?.changedValue(),
           changed {
            responder.children = children
        }
        if !hasValue {
            value = [responder]
        }
    }
}

// TODO: EmptyOpacityAccessibilityProvider

// TODO: _GraphInputs.OpacityAccessibilityProviderKey
