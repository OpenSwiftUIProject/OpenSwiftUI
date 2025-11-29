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

//    public var truncationMode: Text.TruncationMode

    public var multilineTextAlignment: TextAlignment

    public var layoutDirection: LayoutDirection

    package var transitionStyle: ContentTransition.Style

    public var minScaleFactor: CGFloat

    public var lineSpacing: CGFloat

    public var lineHeightMultiple: CGFloat

    public var maximumLineHeight: CGFloat

    public var minimumLineHeight: CGFloat

    public var hyphenationFactor: CGFloat

//    package var writingMode: Text.WritingMode

    package var bodyHeadOutdent: CGFloat

    package var pixelLength: CGFloat

    package var textSizing: Text.Sizing

    package var widthIsFlexible: Bool {
        get { _openSwiftUIUnimplementedFailure() }
        set { _openSwiftUIUnimplementedFailure() }
    }

    package var sizeFitting: Bool {
        get { _openSwiftUIUnimplementedFailure() }
        set { _openSwiftUIUnimplementedFailure() }
    }

    package init() {
        _openSwiftUIUnimplementedFailure()

    }

    public init(_ env: EnvironmentValues) {
        _openSwiftUIUnimplementedFailure()

    }

    package func update(
        _ env: inout EnvironmentValues,
        from old: TextLayoutProperties
    ) {
        _openSwiftUIUnimplementedFailure()
    }

    public static func == (a: TextLayoutProperties, b: TextLayoutProperties) -> Bool {
        _openSwiftUIUnimplementedFailure()
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
