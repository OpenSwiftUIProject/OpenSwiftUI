//
//  TextLayoutBackend.swift
//  OpenSwiftUICore

package import Foundation
package import OpenSwiftUITextLayout

/// A font request for a UI framework that does not use CoreText descriptors.
package typealias TextLayoutFont = OpenSwiftUITextLayout.TextLayoutFont
package typealias TextLayoutBackend = OpenSwiftUITextLayout.TextLayoutBackend
package typealias TextLayoutInstance = OpenSwiftUITextLayout.TextLayoutInstance

extension TextLayoutFont.Design {
    init(_ design: Font.Design) {
        self = switch design {
        case .default: .default
        case .serif: .serif
        case .rounded: .rounded
        case .monospaced: .monospaced
        }
    }
}

extension EnvironmentValues {
    private struct TextLayoutBackendKey: EnvironmentKey {
        static let defaultValue: (any TextLayoutBackend)? = nil
    }

    package var textLayoutBackend: (any TextLayoutBackend)? {
        get { self[TextLayoutBackendKey.self] }
        set { self[TextLayoutBackendKey.self] = newValue }
    }
}

/// Keeps layout and display-list rendering backed by the same paragraph instance.
package final class BackendResolvedStyledText: ResolvedStyledText {
    package let layout: any TextLayoutInstance

    init(runs: [TextLayoutRun], backend: any TextLayoutBackend,
         properties: TextLayoutProperties, archiveOptions: ArchivedViewInput.Value,
         isCollapsible: Bool) {
        let alignment: TextLayoutOptions.Alignment = switch properties.multilineTextAlignment {
        case .leading: .leading
        case .center: .center
        case .trailing: .trailing
        }
        let options = TextLayoutOptions(lineLimit: properties.lineLimit, alignment: alignment,
                                        rightToLeft: properties.layoutDirection == .rightToLeft)
        layout = backend.makeLayout(runs: runs, options: options)
        if properties.truncationMode != .tail || properties.minScaleFactor != 1 || properties.lineSpacing != 0 {
            Log.internalWarning("Text backend currently supports tail truncation, natural line spacing and unscaled fonts only")
        }
        super.init(
            storage: NSAttributedString(string: runs.map(\.string).joined()),
            layoutProperties: properties, layoutMargins: .zero, stylePadding: .zero,
            archiveOptions: archiveOptions, isCollapsible: isCollapsible,
            features: [], suffix: .none, attachments: .init(), styles: [],
            transitions: [], scaleFactorOverride: nil
        )
    }

    override package var majorAxis: Axis { .vertical }
    override package func drawingScale(size: CGSize) -> CGFloat { 1 }
    override package func resetCache() { layout.resetCache() }
    override package func spacing() -> Spacing { Spacing() }
    override package func sizeThatFits(_ proposedSize: _ProposedSize) -> CGSize {
        layout.metrics(in: proposedSize.fixingUnspecifiedDimensions(at: .infinity)).size
    }
    override package func size(in request: CGSize) -> CGSize { layout.metrics(in: request).size }
    override package func size(in request: CGSize, context: TextDrawingContext) -> CGSize { size(in: request) }
    override package func truncates(in proposedSize: _ProposedSize) -> Bool {
        layout.metrics(in: proposedSize.fixingUnspecifiedDimensions(at: .infinity)).hasTruncatedRanges
    }
    override package func metrics(in size: CGSize, layoutMargins: EdgeInsets?) -> NSAttributedString.Metrics {
        let result = layout.metrics(in: size)
        return NSAttributedString.Metrics(size: result.size, scale: 1,
            firstBaseline: result.firstBaseline, lastBaseline: result.lastBaseline,
            baselineAdjustment: 0, requestedWidth: size.width, numberOfLines: UInt(result.numberOfLines),
            hasTruncatedRanges: result.hasTruncatedRanges)
    }
    override package func explicitAlignment(_ key: AlignmentKey, at size: CGSize) -> CGFloat? {
        if key == VerticalAlignment.firstTextBaseline.key { return layout.metrics(in: size).firstBaseline }
        if key == VerticalAlignment.lastTextBaseline.key { return layout.metrics(in: size).lastBaseline }
        return nil
    }
    override package func linkURL(at point: CGPoint, in size: CGSize) -> URL? { nil }
    override package func draw(in drawingArea: CGRect, with measuredSize: CGSize,
                              applyingMarginOffsets: Bool, containsResolvable: Bool,
                              context: TextDrawingContext, renderer: TextRendererBoxBase? = nil) {
        Log.internalWarning("Backend text must be drawn by its UI framework display-list renderer")
    }
}

extension BackendResolvedStyledText {
    static func resolve(_ text: Text, environment: EnvironmentValues,
                        backend: any TextLayoutBackend, options: Text.ResolveOptions,
                        idiom: AnyInterfaceIdiom?, archiveOptions: ArchivedViewInput.Value) -> ResolvedStyledText {
        var container = LayoutRuns(idiom: idiom)
        var options = options
        options.remove(.allowsKeyColors)
        options.remove(.foregroundKeyColor)
        text.resolve(into: &container, in: environment, with: options)
        return BackendResolvedStyledText(
            runs: container.runs, backend: backend, properties: TextLayoutProperties(environment),
            archiveOptions: archiveOptions, isCollapsible: text.isCollapsible()
        )
    }
}

private struct LayoutRuns: ResolvedTextContainer {
    var style = Text.Style()
    var idiom: AnyInterfaceIdiom?
    var runs: [TextLayoutRun] = []

    mutating func append<S: StringProtocol>(_ string: S, in env: EnvironmentValues,
        with options: Text.ResolveOptions, isUniqueSizeVariant: Bool) {
        var string = String(string).caseConvertedIfNeeded(env)
        if env.shouldRedactContent { string = String(repeating: "\u{2588}", count: string.count) }
        var font = (style.baseFont.resolve(in: env) ?? .body).resolveLayoutFont(in: env.fontResolutionContext)
        for modifier in env.fontModifiers where !style.clearedFontModifiers.contains(modifier.typeID) {
            modifier.modify(layoutFont: &font)
        }
        for modifier in style.fontModifiers { modifier.modify(layoutFont: &font) }
        var properties = Text.ResolvedProperties()
        let color = style.color.resolve(in: env, with: options, properties: &properties)
            ?? Color.primary.resolve(in: env)
        let rgba = TextLayoutColor(red: color.red, green: color.green, blue: color.blue, opacity: color.opacity)
        runs.append(TextLayoutRun(string: string, font: font, color: rgba,
                                  letterSpacing: style.tracking ?? style.kerning ?? 0))
    }

    mutating func append(_ attributedString: NSAttributedString, in env: EnvironmentValues,
        with options: Text.ResolveOptions, isUniqueSizeVariant: Bool) {
        attributedString.enumerateAttributes(in: NSRange(location: 0, length: attributedString.length)) {
            attributes, range, _ in
            let oldStyle = style
            var attributes = attributes
            attributes.transferAttributedStringStyles(to: &style)
            append(attributedString.attributedSubstring(from: range).string, in: env,
                   with: options, isUniqueSizeVariant: isUniqueSizeVariant)
            style = oldStyle
        }
    }

    mutating func append(_ image: Image.Resolved, in environment: EnvironmentValues, with options: Text.ResolveOptions) {
        Log.internalWarning("Text layout backend: inline images are not supported")
    }
    mutating func append(_ namedImage: Image.NamedResolved, in environment: EnvironmentValues, with options: Text.ResolveOptions) {
        Log.internalWarning("Text layout backend: inline named images are not supported")
    }
    mutating func append<R: ResolvableStringAttribute>(resolvable: R, in environment: EnvironmentValues,
        with options: Text.ResolveOptions, transition: ContentTransition?) {
        let context = ResolvableStringResolutionContext(referenceDate: nil, environment: environment, maximumWidth: nil)
        guard let string = resolvable.resolve(in: context) else { return }
        Log.internalWarning("Text layout backend resolves dynamic text on graph updates; scheduled refresh is not supported yet")
        append(String(string.characters), in: environment, with: options)
    }
}
