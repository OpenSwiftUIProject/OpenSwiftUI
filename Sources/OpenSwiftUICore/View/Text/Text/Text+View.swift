//
//  Text+View.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: WIP
//  ID: 641995D812913A47B866B20B88782376 (SwiftUICore)

import OpenAttributeGraphShims
public import OpenCoreGraphicsShims

// MARK: - Text + View [WIP]

@available(OpenSwiftUI_v1_0, *)
extension Text: UnaryView, PrimitiveView {
    public nonisolated static func _makeView(
        view: _GraphValue<Self>,
        inputs: _ViewInputs
    ) -> _ViewOutputs {
        if let representation = inputs.requestedTextRepresentation,
           representation.shouldMakeRepresentation(inputs: inputs) {
            var outputs = makeCommonAttributes(view: view, inputs: inputs)
            let options = representation.representationOptions(inputs: inputs)
            _openSwiftUIUnimplementedWarning()
            return outputs
        } else {
            return makeCommonAttributes(view: view, inputs: inputs)
        }
    }

    private static func makeCommonAttributes(
        view: _GraphValue<Self>,
        inputs: _ViewInputs
    ) -> _ViewOutputs {
        .init()
    }
}

// MARK: - TextLayoutProperties

@_spi(Private)
@available(OpenSwiftUI_v3_0, *)
public struct TextLayoutProperties: Equatable {
    public var lineLimit: Int?

    package var lowerLineLimit: Int?

    public var truncationMode: Text.TruncationMode = .tail

    public var multilineTextAlignment: TextAlignment = .leading

    public var layoutDirection: LayoutDirection = .leftToRight

    package var transitionStyle: ContentTransition.Style = .default

    public var minScaleFactor: CGFloat = 1.0

    public var lineSpacing: CGFloat = .zero

    public var lineHeightMultiple: CGFloat = .zero

    public var maximumLineHeight: CGFloat = MaximumLineHeightKey.defaultValue

    public var minimumLineHeight: CGFloat = MinimumLineHeightKey.defaultValue

    public var hyphenationFactor: CGFloat = .zero

    package var hyphenationDisabled: Bool = false

    package var writingMode: Text.WritingMode = .horizontalTopToBottom

    package var bodyHeadOutdent: CGFloat = .zero

    package var pixelLength: CGFloat = 1.0

    package var textSizing: Text.Sizing = .standard

    private var textShape: TextShape = .bounds

    private struct Flags: OptionSet {
        var rawValue: UInt8

        static let widthIsFlexible = Flags(rawValue: 1 << 0)

        static let sizeFitting = Flags(rawValue: 1 << 1)
    }

    private var flags: Flags = []

    package var widthIsFlexible: Bool {
        get { flags.contains(.widthIsFlexible) }
        set { flags.setValue(newValue, for: .widthIsFlexible) }
    }

    package var sizeFitting: Bool {
        get { flags.contains(.sizeFitting) }
        set { flags.setValue(newValue, for: .sizeFitting) }
    }

    package init() {
        _openSwiftUIEmptyStub()
    }

    public init(_ env: EnvironmentValues) {
        self = env[Key.self]
    }

    private struct Key: DerivedEnvironmentKey {
        static func value(in environment: EnvironmentValues) -> TextLayoutProperties {
            TextLayoutProperties(from: environment)
        }
    }

    init(from env: EnvironmentValues) {
        lineLimit = env.lineLimit
        lowerLineLimit = env.lowerLineLimit
        truncationMode = env.truncationMode
        multilineTextAlignment = env.multilineTextAlignment
        layoutDirection = env.layoutDirection
        transitionStyle = env.contentTransitionStyle
        minScaleFactor = env.minimumScaleFactor
        lineSpacing = env.lineSpacing
        lineHeightMultiple = env.lineHeightMultiple
        maximumLineHeight = env.maximumLineHeight
        minimumLineHeight = env.minimumLineHeight
        hyphenationFactor = env.hyphenationFactor
        hyphenationDisabled = env.hyphenationDisabled
        writingMode = env.writingMode
        bodyHeadOutdent = env.bodyHeadOutdent
        pixelLength = env.pixelLength
        textSizing = env.textSizing
        textShape = env.textShape
        // TODO: flags
    }

    package func update(
        _ env: inout EnvironmentValues,
        from old: TextLayoutProperties
    ) {
        if lineLimit != old.lineLimit {
            env.lineLimit = lineLimit
        }
        if lowerLineLimit != old.lowerLineLimit {
            env.lowerLineLimit = lowerLineLimit
        }
        if truncationMode != old.truncationMode {
            env.truncationMode = truncationMode
        }
        if multilineTextAlignment != old.multilineTextAlignment {
            env.multilineTextAlignment = multilineTextAlignment
        }
        if layoutDirection != old.layoutDirection {
            env.layoutDirection = layoutDirection
        }
        if minScaleFactor != old.minScaleFactor {
            env.minimumScaleFactor = minScaleFactor
        }
        if lineSpacing != old.lineSpacing {
            env.lineSpacing = lineSpacing
        }
        if lineHeightMultiple != old.lineHeightMultiple {
            env.lineHeightMultiple = lineHeightMultiple
        }
        if maximumLineHeight != old.maximumLineHeight {
            env.maximumLineHeight = maximumLineHeight
        }
        if minimumLineHeight != old.minimumLineHeight {
            env.minimumLineHeight = minimumLineHeight
        }
        if hyphenationFactor != old.hyphenationFactor {
            env.hyphenationFactor = hyphenationFactor
        }
        if hyphenationDisabled != old.hyphenationDisabled {
            env.hyphenationDisabled = hyphenationDisabled
        }
        if transitionStyle != old.transitionStyle {
            env.contentTransitionStyle = transitionStyle
        }
        if textSizing != old.textSizing {
            env.textSizing = textSizing
        }
        if writingMode != old.writingMode {
            env.writingMode = writingMode
        }
        if textShape != old.textShape {
            env.textShape = textShape
        }
    }
}

@_spi(Private)
@available(*, unavailable)
extension TextLayoutProperties: Sendable {}

@_spi(Private)
extension TextLayoutProperties: ProtobufMessage {
    package func encode(to encoder: inout ProtobufEncoder) throws {
        _openSwiftUIUnimplementedFailure()
    }

    package init(from decoder: inout ProtobufDecoder) throws {
        _openSwiftUIUnimplementedFailure()
    }
}

// MARK: - ResolvedTextFilter [WIP]

struct ResolvedTextFilter: StatefulRule, AsyncAttribute {
    @Attribute var text: Text
    @Attribute var environment: EnvironmentValues
    var helper: ResolvedTextHelper

    typealias Value = ResolvedStyledText

    func updateValue() {
        ResolvedStyledText()
    }
}

struct ResolvedTextHelper {

}

package class TextRendererBoxBase {}

package struct AccessibilityStyledTextContentView<Provider>: View where Provider: TextAccessibilityProvider {
    package var text: ResolvedStyledText

    package var unresolvedText: Text

    package var renderer: TextRendererBoxBase?

    package var needsDrawingGroup: Bool

    package init(
        text: ResolvedStyledText,
        unresolvedText: Text,
        renderer: TextRendererBoxBase? = nil,
        needsDrawingGroup: Bool = false
    ) {
        _openSwiftUIUnimplementedFailure()
    }

    package var body: some View {
        _openSwiftUIUnimplementedFailure()
    }
}

// FIXME:

@available(OpenSwiftUI_v6_0, *)
@usableFromInline
package class ResolvedStyledText: CustomStringConvertible {
    @usableFromInline
    package var description: String {
        _openSwiftUIUnimplementedFailure()
    }
}

extension ResolvedStyledText {
    package class StringDrawing {}
}


private struct TextFilter {

}

// FIXME

extension EnvironmentValues {
    private struct LineLimitKey: EnvironmentKey {
        static var defaultValue: Int? { nil }
    }

    public var lineLimit: Int? {
        get { self[LineLimitKey.self] }
        set { self[LineLimitKey.self] = newValue }
    }

    private struct LowerLineLimitKey: EnvironmentKey {
        static var defaultValue: Int? { nil }
    }

    package var lowerLineLimit: Int? {
        get { self[LowerLineLimitKey.self] }
        set { self[LowerLineLimitKey.self] = newValue }
    }
}

extension EnvironmentValues {
    var contentTransitionStyle: ContentTransition.Style {
        get { _openSwiftUIUnimplementedFailure() }
        set { _openSwiftUIUnimplementedFailure() }
    }
}
