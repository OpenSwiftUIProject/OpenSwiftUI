//
//  OpacityEffect.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: 34FFA2034B9AD53E0463E3971529C5A1 (SwiftUICore)

package import OpenCoreGraphicsShims
package import OpenAttributeGraphShims

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

    package static var isScrapeable: Bool { true }

    package var scrapeableContent: ScrapeableContent.Content? {
        .opacity(opacity)
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
            inputs.opacityAccessibilityProvider.makeOpacity(
                effect: modifier.value,
                inputs: inputs,
                outputs: &outputs
            )
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
    /// visible.](OpenSwiftUI-View-opacity)
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

@available(OpenSwiftUI_v4_0, *)
extension ShapeStyle where Self == AnyShapeStyle {
    /// Returns a new style based on the current style that multiplies
    /// by `opacity` when drawing.
    ///
    /// In most contexts the current style is the foreground but e.g.
    /// when setting the value of the background style, that becomes
    /// the current implicit style.
    ///
    /// For example, a circle filled with the current foreground
    /// style at fifty-percent opacity:
    ///
    ///     Circle().fill(.opacity(0.5))
    ///
    @_alwaysEmitIntoClient
    public static func opacity(_ opacity: Double) -> some ShapeStyle {
        _OpacityShapeStyle(style: _ImplicitShapeStyle(), opacity: Float(opacity))
    }
}

// MARK: - _OpacityShapeStyle

@available(OpenSwiftUI_v3_0, *)
@frozen
public struct _OpacityShapeStyle<Style>: ShapeStyle, PrimitiveShapeStyle where Style: ShapeStyle {
    public var style: Style

    public var opacity: Float

    @inlinable
    public init(style: Style, opacity: Float) {
        self.style = style
        self.opacity = opacity
    }

    public func _apply(to shape: inout _ShapeStyle_Shape) {
        guard opacity != 1 else {
            style._apply(to: &shape)
            return
        }
        switch shape.operation {
        case .prepareText:
            shape.result = .preparedText(.foregroundKeyColor)
        case let .resolveStyle(name, levels):
            style._apply(to: &shape)
            shape.stylePack.modify(name: name, levels: levels) { style in
                style.applyOpacity(opacity)
            }
        case .fallbackColor:
            style._apply(to: &shape)
            if case let .color(color) = shape.result {
                shape.result = .color(color.opacity(Double(opacity)))
            }
        case .copyStyle:
            style.mapCopiedStyle(in: &shape) { style in
                _OpacityShapeStyle<AnyShapeStyle>(style: style, opacity: opacity)
            }
        case .modifyBackground, .multiLevel:
            style._apply(to: &shape)
        case .primaryStyle:
            break
        }
    }

    public static func _apply(to type: inout _ShapeStyle_ShapeType) {
        Style._apply(to: &type)
    }
}

// MARK: - _OpacitiesShapeStyle

@_spi(Private)
@available(OpenSwiftUI_v3_0, *)
@frozen
public struct _OpacitiesShapeStyle<Style>: ShapeStyle, PrimitiveShapeStyle where Style: ShapeStyle {
    public var style: Style

    public var opacities: [Double]

    @inlinable
    public init(style: Style, opacities: [Double]) {
        self.style = style
        self.opacities = opacities
    }

    public func _apply(to shape: inout _ShapeStyle_Shape) {
        switch shape.operation {
        case .prepareText:
            shape.result = .preparedText(.foregroundKeyColor)
        case let .resolveStyle(name, levels):
            shape.operation = .resolveStyle(name: name, levels: 0..<1)
            style._apply(to: &shape)
            let style = shape.stylePack[name, 0]
            for level in levels {
                let index = min(level, opacities.count - 1)
                let opacity = index >= 0 ? opacities[index] : 1.0
                shape.stylePack[name, level] = style.applyingOpacity(Float(opacity))
            }
        case let .fallbackColor(level):
            shape.operation = .fallbackColor(level: 0)
            style._apply(to: &shape)
            if case let .color(color) = shape.result {
                let index = min(level, opacities.count - 1)
                let opacity = index >= 0 ? opacities[index] : 1.0
                shape.result = .color(color.opacity(opacity))
            }
        case .copyStyle:
            style.mapCopiedStyle(in: &shape) { style in
                _OpacitiesShapeStyle<AnyShapeStyle>(style: style, opacities: opacities)
            }
        case .modifyBackground:
            style._apply(to: &shape)
        case .multiLevel:
            shape.result = .bool(true)
        case .primaryStyle:
            break
        }
    }

    public static func _apply(to type: inout _ShapeStyle_ShapeType) {
        Style._apply(to: &type)
    }
}

// MARK: - OpacityTransition

/// A transition from transparent to opaque on insertion, and from opaque to
/// transparent on removal.
@available(OpenSwiftUI_v5_0, *)
@MainActor
@preconcurrency
public struct OpacityTransition: Transition {
    public init() {
        _openSwiftUIEmptyStub()
    }

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

// MARK: - OpacityAccessibilityProvider

package protocol OpacityAccessibilityProvider {
    static func makeOpacity(
        effect: @autoclosure () -> Attribute<_OpacityEffect>,
        inputs: _ViewInputs,
        outputs: inout _ViewOutputs
    )
}

// MARK: - EmptyOpacityAccessibilityProvider

struct EmptyOpacityAccessibilityProvider: OpacityAccessibilityProvider {
    static func makeOpacity(
        effect: @autoclosure () -> Attribute<_OpacityEffect>,
        inputs: _ViewInputs,
        outputs: inout _ViewOutputs
    ) {
        _openSwiftUIEmptyStub()
    }
}

// MARK: - OpacityAccessibilityProviderKey

extension _GraphInputs {
    private struct OpacityAccessibilityProviderKey: GraphInput {
        static let defaultValue: (any OpacityAccessibilityProvider.Type) = EmptyOpacityAccessibilityProvider.self
    }

    package var opacityAccessibilityProvider: (any OpacityAccessibilityProvider.Type) {
        get { self[OpacityAccessibilityProviderKey.self] }
        set { self[OpacityAccessibilityProviderKey.self] = newValue }
    }
}

extension _ViewInputs {
    package var opacityAccessibilityProvider: (any OpacityAccessibilityProvider.Type) {
        get { base.opacityAccessibilityProvider }
        set { base.opacityAccessibilityProvider = newValue }
    }
}
