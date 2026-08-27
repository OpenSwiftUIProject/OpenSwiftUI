//
//  ForegroundLayerEffect.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: BCBFDABE28FEE061FC04EF9B5F079DC4 (SwiftUICore)

package import Foundation
import OpenAttributeGraphShims

// MARK: - _ForegroundLayerViewModifier

@available(OpenSwiftUI_v2_0, *)
@frozen
@MainActor
@preconcurrency
public struct _ForegroundLayerViewModifier: RendererEffect {
    @inlinable
    public init() {}

    package func effectValue(size: CGSize) -> DisplayList.Effect {
        .properties(.foregroundLayer)
    }
}

extension View {
    @inline(__always)
    package func foregroundLayer() -> some View {
        modifier(_ForegroundLayerViewModifier())
    }
}

// MARK: - _ForegroundLayerColorMatrixEffect

@available(OpenSwiftUI_v2_0, *)
@frozen
public struct _ForegroundLayerColorMatrixEffect: MultiViewModifier, PrimitiveViewModifier {
    public var foreground: _ColorMatrix

    public var background: _ColorMatrix

    @inlinable
    public init(
        foreground: _ColorMatrix = .init(),
        background: _ColorMatrix = .init()
    ) {
        (self.foreground, self.background) = (foreground, background)
    }

    private var levelEffect: _ForegroundLayerLevelColorMatrixEffect {
        _ForegroundLayerLevelColorMatrixEffect(
            [.none: background, .primary: foreground]
        )
    }

    nonisolated public static func _makeView(
        modifier: _GraphValue<Self>,
        inputs: _ViewInputs,
        body: @escaping (_Graph, _ViewInputs) -> _ViewOutputs
    ) -> _ViewOutputs {
        _ForegroundLayerLevelColorMatrixEffect._makeView(
            modifier: modifier[\.levelEffect],
            inputs: inputs,
            body: body
        )
    }
}

extension View {
    @inline(__always)
    package func foregroundLayerColorMatrix(
        foreground: _ColorMatrix,
        background: _ColorMatrix
    ) -> some View {
        modifier(
            _ForegroundLayerColorMatrixEffect(
                foreground: foreground,
                background: background
            )
        )
    }
}

// MARK: - _ForegroundLayerLevel

@_spi(Private)
@available(OpenSwiftUI_v6_0, *)
public struct _ForegroundLayerLevel: Equatable, Hashable, Sendable {
    package var properties: DisplayList.Properties

    package init(_ properties: DisplayList.Properties) {
        self.properties = properties.intersection(Self.all.properties)
    }

    private init(unchecked properties: DisplayList.Properties) {
        self.properties = properties
    }

    public static let none = _ForegroundLayerLevel([])

    public static let primary = _ForegroundLayerLevel(.foregroundLayer)

    public static let secondary = _ForegroundLayerLevel(.secondaryForegroundLayer)

    public static let tertiary = _ForegroundLayerLevel(.tertiaryForegroundLayer)

    public static let quaternary = _ForegroundLayerLevel(.quaternaryForegroundLayer)

    private static let all = _ForegroundLayerLevel(
        unchecked: [
            .foregroundLayer,
            .secondaryForegroundLayer,
            .tertiaryForegroundLayer,
            .quaternaryForegroundLayer,
        ]
    )

    public func hash(into hasher: inout Hasher) {
        hasher.combine(properties.rawValue)
    }

    public static func == (a: _ForegroundLayerLevel, b: _ForegroundLayerLevel) -> Bool {
        a.properties.rawValue == b.properties.rawValue
    }
}

// MARK: - _ForegroundLayerLevelViewModifier

@_spi(Private)
@available(OpenSwiftUI_v6_0, *)
@MainActor
@preconcurrency
public struct _ForegroundLayerLevelViewModifier: RendererEffect {
    private var level: _ForegroundLayerLevel

    public init(level: _ForegroundLayerLevel) {
        self.level = level
    }

    package func effectValue(size: CGSize) -> DisplayList.Effect {
        .properties(level.properties)
    }
}

@_spi(Private)
@available(*, unavailable)
extension _ForegroundLayerLevelViewModifier: Sendable {}

extension View {
    @inline(__always)
    package func foregroundLayerLevel(_ level: _ForegroundLayerLevel) -> some View {
        modifier(_ForegroundLayerLevelViewModifier(level: level))
    }
}

// MARK: - _ForegroundLayerLevelColorMatrixEffect

@_spi(Private)
@available(OpenSwiftUI_v6_0, *)
@MainActor
@preconcurrency
public struct _ForegroundLayerLevelColorMatrixEffect: MultiViewModifier, PrimitiveViewModifier {
    @frozen
    public struct Options: OptionSet {
        public let rawValue: UInt32

        public init(rawValue: UInt32) {
            self.rawValue = rawValue
        }

        public static let premultiplied = Options(rawValue: 1 << 0)
    }

    fileprivate var matrices: [_ForegroundLayerLevel: _ColorMatrix]

    fileprivate var options: Options

    public init(
        _ matrices: [_ForegroundLayerLevel: _ColorMatrix],
        options: Options = .init()
    ) {
        self.matrices = matrices
        self.options = options
    }

    public init(
        level: _ForegroundLayerLevel,
        foreground: _ColorMatrix = .init(),
        background: _ColorMatrix = .init()
    ) {
        self.init(level: level, foreground: foreground, background: background, options: [])
    }

    public init(
        level: _ForegroundLayerLevel,
        foreground: _ColorMatrix = .init(),
        background: _ColorMatrix = .init(),
        options: Options
    ) {
        var matrices: [_ForegroundLayerLevel: _ColorMatrix] = [.none: background]
        if level != .none {
            matrices[level] = foreground
        }
        self.init(matrices, options: options)
    }

    nonisolated public static func _makeView(
        modifier: _GraphValue<Self>,
        inputs: _ViewInputs,
        body: @escaping (_Graph, _ViewInputs) -> _ViewOutputs
    ) -> _ViewOutputs {
        var outputs = body(_Graph(), inputs)
        if let displayList = outputs.displayList {
            outputs.displayList = Attribute(
                ForegroundLayerDisplayList(
                    effect: modifier.value,
                    content: .init(displayList),
                    effectVersion: .init()
                )
            )
        }
        return outputs
    }
}

@_spi(Private)
@available(*, unavailable)
extension _ForegroundLayerLevelColorMatrixEffect: Sendable {}

extension View {
    @inline(__always)
    package func foregroundLayerLevelColorMatrix(
        _ matrices: [_ForegroundLayerLevel: _ColorMatrix],
        options: _ForegroundLayerLevelColorMatrixEffect.Options = .init()
    ) -> some View {
        modifier(
            _ForegroundLayerLevelColorMatrixEffect(
                matrices,
                options: options
            )
        )
    }

    @inline(__always)
    package func foregroundLayerLevelColorMatrix(
        level: _ForegroundLayerLevel,
        foreground: _ColorMatrix = .init(),
        background: _ColorMatrix = .init(),
        options: _ForegroundLayerLevelColorMatrixEffect.Options = .init()
    ) -> some View {
        modifier(
            _ForegroundLayerLevelColorMatrixEffect(
                level: level,
                foreground: foreground,
                background: background,
                options: options
            )
        )
    }
}

// MARK: - ForegroundLayerDisplayList

@available(OpenSwiftUI_v6_0, *)
private struct ForegroundLayerDisplayList: StatefulRule, AsyncAttribute {
    typealias Value = DisplayList

    @Attribute var effect: _ForegroundLayerLevelColorMatrixEffect

    @OptionalAttribute var content: DisplayList?

    var effectVersion: DisplayList.Version

    mutating func updateValue() {
        guard var content else {
            value = DisplayList()
            return
        }
        let (effect, effectChanged) = $effect.changedValue()
        if effectChanged {
            effectVersion = DisplayList.Version(forUpdate: ())
        }
        content.insertLayerFilters(
            matrices: effect.matrices,
            version: effectVersion,
            premultiplied: effect.options.contains(.premultiplied)
        )
        value = content
    }
}
