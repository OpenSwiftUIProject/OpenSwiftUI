//
//  Text+View.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: WIP
//  ID: 641995D812913A47B866B20B88782376 (SwiftUICore)

import Foundation
import OpenAttributeGraphShims
public import OpenCoreGraphicsShims
import UIFoundation_Private

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

// MARK: - AccessibilityStyledTextContentView

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
        self.text = text
        self.unresolvedText = unresolvedText
        self.renderer = renderer
        self.needsDrawingGroup = needsDrawingGroup
    }

    package var body: some View {
        Provider.makeView(
            content: StyledTextContentView(
                text: text,
                renderer: renderer,
                needsDrawingGroup: needsDrawingGroup
            ),
            text: unresolvedText,
            resolved: text
        )
    }
}

// MARK: - StyledTextContentView [Blocked by Shape and TextRendererBoxBase]

package struct StyledTextContentView: UnaryView, PrimitiveView, ShapeStyledLeafView {
    package var text: ResolvedStyledText
    package var renderer: TextRendererBoxBase?
    package var needsDrawingGroup: Bool

    package init(
        text: ResolvedStyledText,
        renderer: TextRendererBoxBase? = nil,
        needsDrawingGroup: Bool = false
    ) {
        self.text = text
        self.renderer = renderer
        self.needsDrawingGroup = needsDrawingGroup
    }

    package static var animatesSize: Bool {
        false
    }

    package func shape(in size: CGSize) -> FramedShape {
        let frame = if let renderer {
            // TODO
            CGRect.zero
        } else {
            CGRect(origin: .zero, size: size)
        }
        let shape: ShapeStyle.RenderedShape.Shape = .text(self)
        return (shape, frame)
    }

    nonisolated package static func _makeView(
        view: _GraphValue<Self>,
        inputs: _ViewInputs
    ) -> _ViewOutputs {
        // TODO
        .init()
    }

    package typealias Body = Never

    package typealias ShapeUpdateData = Void

    private struct ArchivedTransitionEnvironment: Rule, AsyncAttribute {
        @Attribute var view: StyledTextContentView
        @Attribute var environment: EnvironmentValues

        var value: EnvironmentValues {
            _openSwiftUIUnimplementedWarning()
            return environment
        }
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
        widthIsFlexible = switch env.textJustification.storage {
        case .full(let full): full.flexible
        case .none: false
        }
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

// MARK: - TextLayoutProperties + ProtobufMessage [TODO]

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
// FIXME:

@available(OpenSwiftUI_v6_0, *)
@usableFromInline
package class ResolvedStyledText: CustomStringConvertible {
    var layoutProperties: TextLayoutProperties = .init()

    @usableFromInline
    package var description: String {
        _openSwiftUIUnimplementedFailure()
    }
}

extension ResolvedStyledText {
    package class StringDrawing {}
}

// MARK: - TextDrawingContext

#if !canImport(Darwin)
class NSStringDrawingContext {}
#endif

@_spi(ForOpenSwiftUIOnly)
@available(OpenSwiftUI_v6_0, *)
final public class TextDrawingContext {
    @AtomicBox
    var ctx: NSStringDrawingContext

    init(ctx: NSStringDrawingContext) {
        self.ctx = ctx
    }

    static let shared: TextDrawingContext = {
        let ctx = NSStringDrawingContext()
        #if canImport(Darwin)
        ctx.wrapsForTruncationMode = true
        ctx.wantsBaselineOffset = true
        ctx.wantsScaledLineHeight = true
        ctx.wantsScaledBaselineOffset = true
        ctx.cachesLayout = true
        #endif
        return TextDrawingContext(ctx: ctx)
    }()
}

@_spi(ForOpenSwiftUIOnly)
@available(*, unavailable)
extension TextDrawingContext: Sendable {}

//extension ResolvedStyledText {
//    package static func styledText(
//        storage: NSAttributedString?,
//        layoutProperties: TextLayoutProperties,
//        layoutMargins: EdgeInsets?,
//        stylePadding: EdgeInsets,
//        archiveOptions: ArchivedViewInput.Value,
//        isCollapsible: Bool,
//        features: Text.ResolvedProperties.Features,
//        suffix: ResolvedTextSuffix,
//        attachments: Text.ResolvedProperties.CustomAttachments,
//        styles: [_ShapeStyle_Pack.Style],
//        transitions: [Text.ResolvedProperties.Transition],
//        scaleFactorOverride: CGFloat?,
//        isInitialResolution: Bool = true
//    ) -> ResolvedStyledText
//
//    package static func styledText(
//        storage: NSAttributedString?,
//        stylePadding: EdgeInsets = EdgeInsets(),
//        layoutProperties: TextLayoutProperties,
//        archiveOptions: ArchivedViewInput.Value = .init(),
//        isCollapsible: Bool = false,
//        features: Text.ResolvedProperties.Features = .init(),
//        suffix: ResolvedTextSuffix = .none,
//        attachments: Text.ResolvedProperties.CustomAttachments = .init(),
//        styles: [_ShapeStyle_Pack.Style] = .init(),
//        transitions: [Text.ResolvedProperties.Transition] = .init()
//    ) -> ResolvedStyledText
//
//    package static func styledText(
//        storage: NSAttributedString?,
//        stylePadding: EdgeInsets = EdgeInsets(),
//        environment: EnvironmentValues,
//        archiveOptions: ArchivedViewInput.Value = .init(),
//        isCollapsible: Bool = false,
//        features: Text.ResolvedProperties.Features = .init(),
//        suffix: ResolvedTextSuffix = .none,
//        attachments: Text.ResolvedProperties.CustomAttachments = .init(),
//        styles: [_ShapeStyle_Pack.Style] = .init(),
//        transitions: [Text.ResolvedProperties.Transition] = .init(),
//        writingMode: Text.WritingMode? = nil,
//        sizeFitting: Bool = false
//    ) -> ResolvedStyledText
//}

// MARK: - CodableResolvedStyledText [WIP]

struct CodableResolvedStyledText: ProtobufMessage {
    var base: ResolvedStyledText

    init(from decoder: inout ProtobufDecoder) throws {
        _openSwiftUIUnimplementedFailure()
    }

    func encode(to encoder: inout ProtobufEncoder) throws {
        _openSwiftUIUnimplementedFailure()
    }
}

// MARK: - ResolvedTextHelper [WIP] SizeFittingTextResolver

struct ResolvedTextHelper {
    enum NextUpdate {
        case time(Time)
        case recipe(lastTime: Time, lastDate: Date, reduceFrequency: Bool, resolved: ResolvedStyledText)
        case none
    }

    var _time: Attribute<Time>
    var _referenceDate: WeakAttribute<Date?>
    let includeDefaultAttributes: Bool
    let allowsKeyColors: Bool
    let archiveOptions: ArchivedViewInput.Value
    let features: Text.ResolvedProperties.Features
    let attachmentsAsAuxiliaryMetadata: Bool
    let idiom: AnyInterfaceIdiom
    let tracker: PropertyList.Tracker
    var lastText: Text?
    var nextUpdate: ResolvedTextHelper.NextUpdate
    var sizeVariant: TextSizeVariant
}

//extension ResolvedTextHelper: SizeFittingTextResolver {
//    typealias Input = (text: Text?, env: EnvironmentValues, renderer: TextRendererBoxBase?)
//    typealias Engine = StyledTextLayoutEngine
//}

// TextChildQuery

// ResolvedOptionalTextFilter

// DynamicTextView

// StyledTextLayoutEngine TODO

struct StyledTextLayoutEngine: LayoutEngine {
    var text: ResolvedStyledText
    var renderer: TextRendererBoxBase?

    func spacing() -> Spacing {
//        text
        .init()
    }

    func sizeThatFits(_ proposedSize: _ProposedSize) -> CGSize {
        .zero
    }
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
