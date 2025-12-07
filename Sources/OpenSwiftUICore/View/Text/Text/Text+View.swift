//
//  Text+View.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: WIP
//  ID: 641995D812913A47B866B20B88782376 (SwiftUICore)

package import Foundation
package import OpenAttributeGraphShims
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
        // TODO: TextAllowsSelection
        let textRenderer = inputs.textRenderer

        var features: ResolvedProperties.Features = inputs.archivedView.isArchived ? [] : .useTextSuffix
        if textRenderer.attribute != nil {
            features.formUnion([.customRenderer, .produceTextLayout])
        } else {
            if inputs.preferences.contains(Text.LayoutKey.self) {
                features.formUnion(.produceTextLayout)
            }
        }
        if inputs.prefersTextLayoutManager {
            features.formUnion(.useTextLayoutManager)
        }
        let resolvedText: Attribute<ResolvedStyledText>
        if inputs.variantThatFits {
            // TODO
            _openSwiftUIUnimplementedFailure()
        } else {
            let helper = ResolvedTextHelper(
                time: inputs.time,
                referenceDate: inputs.referenceDate,
                includeDefaultAttributes: true,
                allowsKeyColors: true,
                archiveOptions: inputs.archivedView,
                features: features,
                attachmentsAsAuxiliaryMetadata: inputs.hasWidgetMetadata,
                idiom: inputs.base.interfaceIdiom,
                lastText: nil,
                nextUpdate: .time(.zero),
                sizeVariant: .regular
            )
            resolvedText = Attribute(
                ResolvedTextFilter(
                    text: view.value,
                    environment: inputs.environment,
                    helper: helper
                )
            )
        }
        // FIXME
        var outputs: _ViewOutputs = .init()

        if let textAlwaysOnProvider = inputs.textAlwaysOnProvider {
            textAlwaysOnProvider.makeAlwaysOn(
                inputs: inputs,
                schedule: resolvedText.schedule,
                outputs: &outputs
            )
        }
        // FIXME
        return outputs
    }

    // TODO
    private struct MakeRepresentableContext {}
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

// MARK: - StyledTextContentView [WIP]

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
        var frame = CGRect(origin: .zero, size: size)
        if let renderer {
            frame = frame.outset(by: renderer.displayPadding)
        }
        let shape: ShapeStyle.RenderedShape.Shape = .text(self)
        return (shape, frame)
    }

    nonisolated package static func _makeView(
        view: _GraphValue<Self>,
        inputs: _ViewInputs
    ) -> _ViewOutputs {
        var newInputs = inputs
        if inputs.preferences.requiresViewResponders {
            newInputs.preferences.requiresViewResponders = false
        }
        let shapeStyles = inputs.resolvedShapeStyles(
            role: .stroke,
            mode: nil
        )
        var outputs: _ViewOutputs
        if inputs.preferences.requiresDisplayList {
            if inputs.archivedView.isArchived {
                newInputs.environment = Attribute(
                    ArchivedTransitionEnvironment(
                        view: view.value,
                        environment: inputs.environment
                    )
                )
                // TODO: ContentTransition
                _openSwiftUIUnimplementedWarning()
                // FIXME
                outputs = .init()
            } else {
                let group = _ShapeStyle_InterpolatorGroup()
                if inputs.needsGeometry {
                    newInputs.position = inputs.animatedPosition()
                }
                outputs = makeLeafView(
                    view: view,
                    inputs: newInputs,
                    styles: shapeStyles,
                    interpolatorGroup: group
                )
                // TODO: outputs.applyInterpolatorGroup
            }
        } else {
            outputs = makeLeafView(
                view: view,
                inputs: newInputs,
                styles: shapeStyles,
                interpolatorGroup: nil
            )
        }
        if inputs.requestsLayoutComputer {
            outputs.layoutComputer = Attribute(
                StyledTextLayoutComputer(textView: view.value)
            )
        }
        // TODO: Text.Layout.Key
        return outputs
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

// MARK: - ResolvedStyledText [WIP]

@available(OpenSwiftUI_v6_0, *)
@usableFromInline
package class ResolvedStyledText: CustomStringConvertible {
    final package var layoutProperties: TextLayoutProperties

    final package var layoutMargins: EdgeInsets

    final package var scaleFactorOverride: CGFloat? {
        didSet {
            // TODO
            _openSwiftUIUnimplementedWarning()
        }
    }

    package func resetCache() {
        _openSwiftUIUnimplementedFailure()
    }

    final package let storage: NSAttributedString?

    final package let stylePadding: EdgeInsets

    package var drawingMargins: EdgeInsets {
        _openSwiftUIUnimplementedFailure()
    }

    final package let isCollapsible: Bool

    final package let features: Text.ResolvedProperties.Features

    final package let styles: [_ShapeStyle_Pack.Style]

    final package let transitions: [Text.ResolvedProperties.Transition]

    final package var isDynamic: Bool {
        _openSwiftUIUnimplementedFailure()
    }

    final package var isEmpty: Bool {
        _openSwiftUIUnimplementedFailure()
    }

    final package var needsStyledRendering: Bool {
        _openSwiftUIUnimplementedFailure()
    }

    final package var needsRBDisplayList: Bool {
        _openSwiftUIUnimplementedFailure()
    }

    final package var maxFontMetrics: NSAttributedString.EncodedFontMetrics {
        _openSwiftUIUnimplementedFailure()
    }

    var schedule: (any TimelineSchedule)? {
        _openSwiftUIUnimplementedWarning()
        return nil
    }

    package init(
        storage: NSAttributedString?,
        layoutProperties: TextLayoutProperties,
        layoutMargins: EdgeInsets?,
        stylePadding: EdgeInsets,
        archiveOptions: ArchivedViewInput.Value,
        isCollapsible: Bool,
        features: Text.ResolvedProperties.Features,
        suffix: ResolvedTextSuffix,
        attachments: Text.ResolvedProperties.CustomAttachments,
        styles: [_ShapeStyle_Pack.Style],
        transitions: [Text.ResolvedProperties.Transition],
        scaleFactorOverride: CGFloat?
    ) {
        _openSwiftUIUnimplementedFailure()
    }

    package func lineHeightScalingAdjustment(
        lineHeightMultiple: CGFloat,
        maximumLineHeight: CGFloat,
        minimumLineHeight: CGFloat
    ) -> CGFloat {
        _openSwiftUIUnimplementedFailure()
    }

    final package func draw(
        in drawingArea: CGRect,
        with measuredSize: CGSize,
        applyingMarginOffsets: Bool = true,
        context: TextDrawingContext = .shared,
        renderer: TextRendererBoxBase? = nil
    ) {
        _openSwiftUIUnimplementedFailure()
    }

    package var majorAxis: Axis {
        _openSwiftUIUnimplementedFailure()
    }

    package func drawingScale(size: CGSize) -> CGFloat {
        _openSwiftUIUnimplementedFailure()
    }

    package func spacing() -> Spacing {
        _openSwiftUIUnimplementedFailure()
    }

    package func sizeThatFits(_ proposedSize: _ProposedSize) -> CGSize {
        _openSwiftUIUnimplementedFailure()
    }

    package func size(in request: CGSize) -> CGSize {
        _openSwiftUIUnimplementedFailure()
    }

    package func frameSize(in request: CGSize) -> CGSize {
        _openSwiftUIUnimplementedFailure()
    }

    package func size(
        in request: CGSize,
        context: TextDrawingContext
    ) -> CGSize {
        _openSwiftUIUnimplementedFailure()
    }

    package func explicitAlignment(
        _ k: AlignmentKey,
        at size: CGSize
    ) -> CGFloat? {
        _openSwiftUIUnimplementedFailure()
    }

    package func linkURL(
        at point: CGPoint,
        in size: CGSize
    ) -> URL? {
        _openSwiftUIUnimplementedFailure()
    }

    package func draw(
        in drawingArea: CGRect,
        with measuredSize: CGSize,
        applyingMarginOffsets: Bool,
        containsResolvable: Bool,
        context: TextDrawingContext,
        renderer: TextRendererBoxBase? = nil
    ) {
        _openSwiftUIUnimplementedFailure()
    }

    package func layoutValue(
        in drawingArea: CGRect,
        with measuredSize: CGSize,
        applyingMarginOffsets: Bool = true
    ) -> Text.Layout? {
        _openSwiftUIUnimplementedFailure()
    }

    final package func resolvedContent(in context: ResolvableStringResolutionContext) -> NSAttributedString? {
        _openSwiftUIUnimplementedFailure()
    }

    final package func resolvingContent(in context: ResolvableStringResolutionContext) -> ResolvedStyledText {
        _openSwiftUIUnimplementedFailure()
    }

    final package func nextUpdate(
        after time: Time,
        equivalentDate date: Date,
        reduceFrequency: Bool = false
    ) -> Time {
        _openSwiftUIUnimplementedFailure()
    }

//    final package var updatesAsynchronously: Bool {
//        _openSwiftUIUnimplementedFailure()
//    }

    @usableFromInline
    final package var description: String {
        _openSwiftUIUnimplementedFailure()
    }

    final package var accessibilityText: Text {
        _openSwiftUIUnimplementedFailure()
    }

//    final package var cgStyleHandler: RBCGStyleHandler? {
//        _openSwiftUIUnimplementedFailure()
//    }

    final package func makeRBDisplayList(
        for size: CGSize,
        renderer: TextRendererBoxBase?,
        deviceScale: CGFloat
    ) -> any RBDisplayListContents {
        _openSwiftUIUnimplementedFailure()
    }
}

extension ResolvedStyledText {
    package func textSizeCacheMetrics(in size: CGSize) -> (UInt?, CGSize) {
        _openSwiftUIUnimplementedFailure()
    }

    package func linkURLMetrics(
        in size: CGSize,
        layoutMargins: EdgeInsets
    ) -> CGFloat {
        _openSwiftUIUnimplementedFailure()
    }
}

@available(*, unavailable)
extension ResolvedStyledText: Sendable {}

extension ResolvedStyledText {
    package func firstBaseline(in size: CGSize) -> CGFloat {
        _openSwiftUIUnimplementedFailure()
    }

    package func lastBaseline(in size: CGSize) -> CGFloat {
        _openSwiftUIUnimplementedFailure()
    }

    package func frame(in request: CGSize) -> CGRect {
        _openSwiftUIUnimplementedFailure()
    }

    package func frameOffset() -> CGSize {
        _openSwiftUIUnimplementedFailure()
    }
}

extension ResolvedStyledText {
    // FIXME
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

// MARK: - ResolvedStyledText + Extension [WIP]

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

// MARK: - DynamicTextViewFactory [WIP]

struct DynamicTextViewFactory {
    var text: ResolvedStyledText
    var size: CGSize
    var identity: DisplayList.Identity
}

// MARK: - StyledTextLayoutComputer [WIP]

private struct StyledTextLayoutComputer: StatefulRule, AsyncAttribute {
    @Attribute var textView: StyledTextContentView

    typealias Value = LayoutComputer

    func updateValue() {
        // TODO
        _openSwiftUIUnimplementedFailure()
    }
}

// MARK: - TextLayoutQuery [WIP]

struct TextLayoutQuery {
    var _resolvedText: Attribute<ResolvedStyledText>
    var _position: Attribute<CGPoint>
    var _size: Attribute<CGSize>
    var _transform: Attribute<ViewTransform>

    var value: [Text.LayoutKey.AnchoredLayout] {
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
        _openSwiftUIUnimplementedFailure()
    }
}

// MARK: - ResolvedTextHelper [WIP]

struct ResolvedTextHelper {
    enum NextUpdate {
        case time(Time)
        case recipe(lastTime: Time, lastDate: Date, reduceFrequency: Bool, resolved: ResolvedStyledText)
        case none
    }

    @Attribute var time: Time
    @WeakAttribute var referenceDate: Date??
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

    init(
        time: Attribute<Time>,
        referenceDate: WeakAttribute<Date?>,
        includeDefaultAttributes: Bool,
        allowsKeyColors: Bool,
        archiveOptions: ArchivedViewInput.Value,
        features: Text.ResolvedProperties.Features,
        attachmentsAsAuxiliaryMetadata: Bool,
        idiom: AnyInterfaceIdiom,
        lastText: Text?,
        nextUpdate: ResolvedTextHelper.NextUpdate,
        sizeVariant: TextSizeVariant
    ) {
        self._time = time
        self._referenceDate = referenceDate
        self.includeDefaultAttributes = includeDefaultAttributes
        self.allowsKeyColors = allowsKeyColors
        self.archiveOptions = archiveOptions
        self.features = features
        self.attachmentsAsAuxiliaryMetadata = attachmentsAsAuxiliaryMetadata
        self.idiom = idiom
        self.tracker = .init()
        self.lastText = lastText
        self.nextUpdate = nextUpdate
        self.sizeVariant = sizeVariant
    }

    func resolve(
        _ text: Text?,
        with environment: EnvironmentValues,
        sizeFitting: Bool
    ) -> ResolvedStyledText? {
        // TODO
        _openSwiftUIUnimplementedWarning()
        return nil
    }
}

struct TextChildQuery<A> where A: TextAccessibilityProvider {
    var _resolvedText: Attribute<ResolvedStyledText>
    var _unresolvedText: Attribute<Text>
    var _renderer: WeakAttribute<TextRendererBoxBase>
    var _environment: Attribute<EnvironmentValues>
    var _position: Attribute<CGPoint>
    var _size: Attribute<ViewSize>
    var _transform: Attribute<ViewTransform>
    let parentID: ScrapeableID

    static func scrapeContent(from attribute: AnyAttribute) -> ScrapeableContent.Item? {
        _openSwiftUIUnimplementedFailure()
    }

    var unresolvedText: Text {
        _openSwiftUIUnimplementedFailure()
    }

    var renderer: Optional<TextRendererBoxBase> {
        _openSwiftUIUnimplementedFailure()
    }

    var environment: EnvironmentValues {
        _openSwiftUIUnimplementedFailure()
    }

    var value: some View {
        _openSwiftUIUnimplementedFailure()
    }
}

struct ResolvedOptionalTextFilter {
    var _text: Attribute<Optional<Text>>
    var _environment: Attribute<EnvironmentValues>
    var helper: ResolvedTextHelper

    func updateValue() {
        _openSwiftUIUnimplementedFailure()
    }
}

struct DynamicTextView {
    var text: ResolvedStyledText
    var size: CGSize

    static func _makeView(
        view: _GraphValue<DynamicTextView>,
        inputs: _ViewInputs
    ) -> _ViewOutputs {
        _openSwiftUIUnimplementedFailure()
    }
}

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
