//
//  Text+SizeFitting.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: 22A2F77020526CCA53FF38DE37184183 (SwiftUICore)

import Foundation
import OpenAttributeGraphShims

// MARK: - Text + textVariant

@available(OpenSwiftUI_v6_0, *)
extension Text {

    /// Controls the way text size variants are chosen.
    ///
    /// Certain types of text, such as ``Text(_:format:)``, can generate strings of
    /// different size to better fit the available space. By default, all text uses the
    /// widest available variant. Setting the variant to be
    /// ``TextVariantPreference/sizeDependent`` allows the text to take the available
    /// space into account when choosing what content to display.
    @available(OpenSwiftUI_v6_0, *)
    public func textVariant<V>(
        _ preference: V
    ) -> some View where V: TextVariantPreference {
        preference._preference.body(self)
    }
}

// MARK: - TextVariantPreference

/// A protocol for controlling the size variant of text views.
@available(OpenSwiftUI_v6_0, *)
public protocol TextVariantPreference {
    var _preference: _TextVariantPreference<Self> { get }
}

// MARK: - _TextVariantPreference

/// Internal requirement for ``TextVariantPreference``.
@available(OpenSwiftUI_v6_0, *)
public struct _TextVariantPreference<Preference>: Sendable where Preference: TextVariantPreference {
    @ViewBuilder
    fileprivate func body<V>(
        _ view: V
    ) -> some View where V: View {
        if Preference.self == SizeDependentTextVariant.self {
            view.modifier(VariantThatFitsModifier())
        } else {
            view
        }
    }
}

// MARK: - FixedTextVariant

/// The default text variant preference that chooses the largest available
/// variant.
@available(OpenSwiftUI_v6_0, *)
public struct FixedTextVariant: TextVariantPreference, Sendable {
    public var _preference: _TextVariantPreference<FixedTextVariant> {
        .init()
    }
}

// MARK: - SizeDependentTextVariant

/// The size dependent variant preference allows the text to take the available
/// space into account when choosing the variant to display.
@available(OpenSwiftUI_v6_0, *)
public struct SizeDependentTextVariant: TextVariantPreference, Sendable {
    public var _preference: _TextVariantPreference<SizeDependentTextVariant> {
        .init()
    }
}

// MARK: - TextVariantPreference + fixed

@available(OpenSwiftUI_v6_0, *)
extension TextVariantPreference where Self == FixedTextVariant {

    /// The default text variant preference. It always chooses the largest available
    /// variant.
    public static var fixed: FixedTextVariant {
        .init()
    }
}

// MARK: - TextVariantPreference + sizeDependent

@available(OpenSwiftUI_v6_0, *)
extension TextVariantPreference where Self == SizeDependentTextVariant {

    /// The size dependent preference allows the text to take the available space into
    /// account when choosing the size variant to display.
    ///
    /// When a ``Text`` provides different size options for its content, the size
    /// dependent preference chooses the largest option that fits into the available
    /// space without truncating or clipping its content.
    ///
    /// - Note: Only use this option where needed as it incurs a performance cost on
    /// every ``Text`` it is applied to, even if the concrete text initializer cannot
    /// provide multiple size variants and there is no visual impact.
    ///
    /// ## Difference to ViewThatFits
    ///
    /// The ``sizeDependent`` text variant preference differs from ``ViewThatFits`` both
    /// in usage and in behavior. ``ViewThatFits`` chooses the first child where the
    /// **ideal** size fits the available space. For ``Text`` this means that it will
    /// only choose texts that can fit their contents into the available space **without
    /// a line break**. With this text variant preference, on the other hand, the
    /// largest variant is chosen that can fit the available space while respecting all
    /// the regular layout rules, such as ``EnvironmentValues/lineLimit``.
    ///
    /// To use ``ViewThatFits``, multiple different views have to be provided as the
    /// different size options. With this text variant preference, a single ``Text``
    /// provides the different size variants intrinsically. The way it generates these
    /// size variants and how many size variants are available depends on the text
    /// initializer used.
    public static var sizeDependent: SizeDependentTextVariant {
        .init()
    }
}

// MARK: - TextSizeVariant

package struct TextSizeVariant: Comparable, Hashable, RawRepresentable {
    package var rawValue: Int

    package init(rawValue: Int) {
        self.rawValue = rawValue
    }

    package static let regular: TextSizeVariant = .init(rawValue: 0)

    package static let compact: TextSizeVariant = .init(rawValue: 1)

    package static let small: TextSizeVariant = .init(rawValue: 2)

    package static let tiny: TextSizeVariant = .init(rawValue: 3)

    package static func < (lhs: TextSizeVariant, rhs: TextSizeVariant) -> Bool {
        lhs.rawValue < rhs.rawValue
    }

    package var nextUp: TextSizeVariant? {
        if rawValue == 0 {
            return nil
        } else {
            return TextSizeVariant(rawValue: rawValue - 1)
        }
    }

    package var nextDown: TextSizeVariant {
        TextSizeVariant(rawValue: rawValue + 1)
    }
}

// MARK: - TextSizeVariant + Codable

extension TextSizeVariant: Codable {
    package init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(Int.self)
        self.init(rawValue: rawValue)
    }

    package func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }
}

// MARK: - SizeFittingTextResolver

protocol SizeFittingTextResolver {
    associatedtype Input
    associatedtype Engine: LayoutEngine

    mutating func shouldUpdate(for input: Input, inputChanged: Bool) -> Bool
    mutating func value(for input: Input) -> SizeFittingTextCacheValue<Engine>
    var narrowerVariant: Self { get }
}

// MARK: - TextSizeFittingLogic

protocol TextSizeFittingLogic {
    mutating func suggestedVariant(for proposedSize: _ProposedSize) -> TextSizeVariant?
    mutating func onInvalidation(of variant: TextSizeVariant)
}

// MARK: - ResolvedTextHelper + SizeFittingTextResolver

extension ResolvedTextHelper: SizeFittingTextResolver {
    typealias Input = (
        text: Text?,
        env: EnvironmentValues,
        renderer: TextRendererBoxBase?
    )

    typealias Engine = StyledTextLayoutEngine

    mutating func shouldUpdate(for input: Input, inputChanged: Bool) -> Bool {
        if inputChanged {
            if lastText != input.text {
                return true
            }
            if tracker.hasDifferentUsedValues(input.env.plist) {
                return true
            }
        }
        switch nextUpdate {
        case let .time(nextUpdate):
            return time >= nextUpdate
        case let .recipe(lastTime, lastDate, reduceFrequency, resolved):
            let nextUpdate = resolved.nextUpdate(
                after: lastTime,
                equivalentDate: lastDate,
                reduceFrequency: reduceFrequency
            )
            self.nextUpdate = .time(nextUpdate)
            return time >= nextUpdate
        case .none:
            return false
        }
    }

    mutating func value(for input: Input) -> SizeFittingTextCacheValue<Engine> {
        let text = resolve(input.text, with: input.env, sizeFitting: true)!
        return SizeFittingTextCacheValue(
            text: text,
            engine: StyledTextLayoutEngine(text: text, renderer: input.renderer),
            renderer: input.renderer
        )
    }

    var narrowerVariant: ResolvedTextHelper {
        var result = self
        result.sizeVariant = sizeVariant.nextDown
        result.tracker.reset()
        result.lastText = nil
        result.nextUpdate = .time(.zero)
        return result
    }
}

// MARK: - SizeFittingTextCache

class SizeFittingTextCache<Resolver, Logic>
    where Resolver: SizeFittingTextResolver, Logic: TextSizeFittingLogic {
    private struct CacheEntry {
        var resolver: Resolver
        var lastValue: SizeFittingTextCacheValue<Resolver.Engine>?
        var inputChanged = false

        init(resolver: Resolver) {
            self.resolver = resolver
        }

        mutating func withValue<Result>(
            for input: Resolver.Input,
            onChange: () -> Void,
            execute: (inout SizeFittingTextCacheValue<Resolver.Engine>) throws -> Result
        ) rethrows -> Result {
            var result = result(for: input)
            defer { lastValue = result.value }
            if result.changed {
                onChange()
            }
            return try execute(&result.value)
        }

        mutating func result(
            for input: Resolver.Input
        ) -> (value: SizeFittingTextCacheValue<Resolver.Engine>, changed: Bool) {
            let result: (value: SizeFittingTextCacheValue<Resolver.Engine>, changed: Bool)
            if let lastValue,
               !resolver.shouldUpdate(for: input, inputChanged: inputChanged) {
                result = (lastValue, false)
            } else {
                result = (resolver.value(for: input), true)
            }
            lastValue = result.value
            inputChanged = false
            return result
        }

        var narrowerVariant: CacheEntry {
            var result = CacheEntry(resolver: resolver.narrowerVariant)
            result.inputChanged = inputChanged
            return result
        }
    }

    private var sizeVariantCache = ClosestFitCache<TextSizeVariant>(capacity: 10)
    private var exhaustedWidthVariants = false
    private var resultCache: [CacheEntry]
    var logic: Logic
    private var _input: Resolver.Input

    var input: (value: Resolver.Input, changed: Bool) {
        get { (_input, false) }
        set {
            if newValue.changed {
                for index in resultCache.indices {
                    resultCache[index].inputChanged = true
                }
            }
            _input = newValue.value
        }
    }

    init(resolver: Resolver, logic: Logic, initialInput: Resolver.Input) {
        resultCache = [CacheEntry(resolver: resolver)]
        self.logic = logic
        _input = initialInput
    }

    func withValue<Result>(
        for proposal: _ProposedSize,
        compute: (inout SizeFittingTextCacheValue<Resolver.Engine>) throws -> Result
    ) rethrows -> Result {
        let variant = sizeVariant(for: proposal)
        return try resultCache[variant.rawValue].withValue(
            for: _input,
            onChange: { _openSwiftUIEmptyStub() },
            execute: { try compute(&$0) }
        )
    }

    func withResolver<Result>(
        for proposal: _ProposedSize,
        compute: (inout Resolver) throws -> Result
    ) rethrows -> Result {
        let variant = sizeVariant(for: proposal)
        var entry = resultCache[variant.rawValue]
        defer { resultCache[variant.rawValue] = entry }
        return try compute(&entry.resolver)
    }

    private func sizeVariant(for proposal: _ProposedSize) -> TextSizeVariant {
        if let suggested = suggestedVariant(for: proposal) {
            return suggested
        }
        return sizeVariantCache(for: proposal) { candidate in
            var variant = candidate ?? .regular
            if withValue(for: variant, compute: { $0.fits(proposal) }) {
                while let wider = variant.nextUp {
                    guard withValue(for: wider, compute: { $0.fits(proposal) }) else {
                        break
                    }
                    variant = wider
                }
                return variant
            }
            var narrowerVariantsMightExist: Bool {
                variant.rawValue < resultCache.count - 1 || !exhaustedWidthVariants
            }
            variant = variant.nextDown
            while narrowerVariantsMightExist {
                if withValue(for: variant, compute: { $0.fits(proposal) }) {
                    break
                }
                variant = variant.nextDown
            }
            return TextSizeVariant(rawValue: min(variant.rawValue, resultCache.count - 1))
        }
    }

    private func suggestedVariant(for proposal: _ProposedSize) -> TextSizeVariant? {
        var logic = self.logic
        guard let suggested = logic.suggestedVariant(for: proposal) else {
            return nil
        }
        var changed = false
        let fits = withValue(
            for: suggested,
            onChange: { changed = true },
            compute: { $0.fits(proposal) }
        )
        guard changed else {
            return fits ? suggested : nil
        }
        logic = self.logic
        guard let updated = logic.suggestedVariant(for: proposal) else {
            return nil
        }
        if updated == suggested {
            return updated
        }
        return withValue(for: updated, compute: { $0.fits(proposal) }) ? updated : nil
    }

    private func withValue<Result>(
        for variant: TextSizeVariant,
        onChange notify: @escaping () -> Void = { _openSwiftUIEmptyStub() },
        compute: (inout SizeFittingTextCacheValue<Resolver.Engine>) throws -> Result
    ) rethrows -> Result {
        func onChange(for variant: TextSizeVariant) -> () -> Void {
            {
                self.logic.onInvalidation(of: variant)
                notify()
            }
        }
        if variant.rawValue < resultCache.count {
            let input = _input
            let onChange = onChange(for: variant)
            return try resultCache[variant.rawValue].withValue(
                for: input,
                onChange: onChange,
                execute: { try compute(&$0) }
            )
        }
        var currentVariant: TextSizeVariant {
            TextSizeVariant(rawValue: resultCache.count - 1)
        }
        while !exhaustedWidthVariants, currentVariant < variant {
            let nextVariant = currentVariant.nextDown
            var entry = resultCache[currentVariant.rawValue].narrowerVariant
            let isUnique = entry.withValue(
                for: _input,
                onChange: onChange(for: nextVariant),
                execute: { $0.text.features.contains(.isUniqueSizeVariant) }
            )
            if isUnique {
                resultCache.append(entry)
            } else {
                exhaustedWidthVariants = true
            }
        }
        let input = _input
        let variant = currentVariant
        let onChange = onChange(for: variant)
        return try resultCache[variant.rawValue].withValue(
            for: input,
            onChange: onChange,
            execute: { try compute(&$0) }
        )
    }
}

// MARK: - SizeFittingTextCacheValue

struct SizeFittingTextCacheValue<Engine> where Engine: LayoutEngine {
    var text: ResolvedStyledText
    var engine: Engine
    var renderer: TextRendererBoxBase?

    fileprivate mutating func fits(_ proposal: _ProposedSize) -> Bool {
        guard !truncates(in: proposal) else {
            return false
        }
        let axis: Axis = text.layoutProperties.writingMode == .horizontalTopToBottom
            ? .horizontal
            : .vertical
        guard let limit = proposal[axis] else {
            return true
        }
        var candidate = proposal
        candidate[axis] = nil
        let length = engine.lengthThatFits(candidate, in: axis)
        guard length > limit else {
            return true
        }
        candidate[axis] = length - 1
        if (candidate.width ?? .infinity) <= (proposal.width ?? .infinity),
           (candidate.height ?? .infinity) <= (proposal.height ?? .infinity) {
            return true
        }
        return !truncates(in: candidate)
    }

    private func truncates(in proposal: _ProposedSize) -> Bool {
        let size: CGSize
        if let renderer {
            size = renderer.sizeThatFits(
                proposal: ProposedViewSize(proposal),
                text: TextProxy(text: text)
            )
        } else if proposal.width == nil, proposal.height == nil {
            return false
        } else {
            size = proposal.fixingUnspecifiedDimensions(
                at: CGSize(width: CGFloat.infinity, height: CGFloat.infinity)
            )
        }
        return text.metrics(in: size, layoutMargins: nil).hasTruncatedRanges
    }
}

// MARK: - ClosestFitCache

struct ClosestFitCache<Value> where Value: Equatable {
    let capacity: Int
    var entries: [(proposal: _ProposedSize, value: Value)] = []

    mutating func callAsFunction(
        for proposal: _ProposedSize,
        makeValue: (Value?) throws -> Value
    ) rethrows -> Value {
        let width = proposal.width ?? .infinity
        let height = proposal.height ?? .infinity
        var closestIndex: Int?
        var closestDistance = CGFloat.infinity
        for index in entries.indices {
            let entry = entries[index]
            let entryWidth = entry.proposal.width ?? .infinity
            let entryHeight = entry.proposal.height ?? .infinity
            guard entryWidth <= width, entryHeight <= height else {
                continue
            }
            let distance = entryWidth == .infinity && entryHeight == .infinity
                ? 0
                : min(width - entryWidth, height - entryHeight)
            guard distance < closestDistance else {
                continue
            }
            closestIndex = index
            closestDistance = distance
            if entry.proposal == proposal {
                break
            }
        }
        let value = try makeValue(closestIndex.map { entries[$0].value })
        if let closestIndex, entries[closestIndex].value == value {
            if closestIndex != 0 {
                entries.swapAt(closestIndex, closestIndex - 1)
            }
        } else if entries.count < capacity {
            entries.append((proposal, value))
        } else {
            entries[entries.count - 1] = (proposal, value)
        }
        return value
    }
}

// MARK: - StickyTextSizeFittingLogic

struct StickyTextSizeFittingLogic: TextSizeFittingLogic {
    var stickOnHorizontalGrowth = false
    var stickOnVerticalGrowth = false
    var committedValue: (sizeVariant: TextSizeVariant, proposal: _ProposedSize)?

    mutating func suggestedVariant(
        for proposedSize: _ProposedSize
    ) -> TextSizeVariant? {
        guard let committedValue else {
            return nil
        }
        guard stickOnHorizontalGrowth ||
                (proposedSize.width ?? .infinity) <=
                (committedValue.proposal.width ?? .infinity),
              stickOnVerticalGrowth ||
                (proposedSize.height ?? .infinity) <=
                (committedValue.proposal.height ?? .infinity)
        else {
            return nil
        }
        return committedValue.sizeVariant
    }

    mutating func onInvalidation(of variant: TextSizeVariant) {
        if committedValue?.sizeVariant == variant {
            committedValue = nil
        }
    }
}

// MARK: - SizeFittingTextLayoutComputer

struct SizeFittingTextLayoutComputer: StatefulRule, AsyncAttribute {
    @Attribute var text: Text
    @Attribute var environment: EnvironmentValues
    @WeakAttribute var renderer: TextRendererBoxBase?
    let cache: SizeFittingTextCache<ResolvedTextHelper, StickyTextSizeFittingLogic>

    typealias Value = LayoutComputer

    mutating func updateValue() {
        let (text, textChanged) = $text.changedValue()
        let (environment, environmentChanged) = $environment.changedValue()
        cache.input = (
            (text, environment, renderer),
            textChanged || environmentChanged
        )
        update(to: Engine(ctx: context, cache: cache))
    }

    private struct Engine<Resolver, Logic>: LayoutEngine
        where Resolver: SizeFittingTextResolver, Logic: TextSizeFittingLogic {
        let ctx: RuleContext<LayoutComputer>
        let cache: SizeFittingTextCache<Resolver, Logic>

        private func withValue<Result>(
            for proposal: _ProposedSize,
            _ body: (inout SizeFittingTextCacheValue<Resolver.Engine>) -> Result
        ) -> Result! {
            var result: Result!
            ctx.update {
                result = cache.withValue(for: proposal, compute: body)
            }
            return result
        }

        func layoutPriority() -> Double {
            withValue(for: .unspecified) { $0.engine.layoutPriority() }
        }

        func ignoresAutomaticPadding() -> Bool {
            withValue(for: .unspecified) { $0.engine.ignoresAutomaticPadding() }
        }

        func requiresSpacingProjection() -> Bool {
            withValue(for: .unspecified) { $0.engine.requiresSpacingProjection() }
        }

        func spacing() -> Spacing {
            withValue(for: .unspecified) { $0.engine.spacing() }
        }

        func sizeThatFits(_ proposal: _ProposedSize) -> CGSize {
            withValue(for: proposal) { $0.engine.sizeThatFits(proposal) }
        }

        func lengthThatFits(
            _ proposal: _ProposedSize,
            in axis: Axis
        ) -> CGFloat {
            withValue(for: proposal) {
                $0.engine.lengthThatFits(proposal, in: axis)
            }
        }

        func childGeometries(
            at parentSize: ViewSize,
            origin: CGPoint
        ) -> [ViewGeometry] {
            withValue(for: _ProposedSize(parentSize.value)) {
                $0.engine.childGeometries(at: parentSize, origin: origin)
            }
        }

        func explicitAlignment(
            _ key: AlignmentKey,
            at viewSize: ViewSize
        ) -> CGFloat? {
            withValue(for: _ProposedSize(viewSize.value)) {
                $0.engine.explicitAlignment(key, at: viewSize)
            }
        }

        var debugContentDescription: String? {
            let description = cache.withValue(for: .unspecified) {
                $0.engine.debugContentDescription ?? ""
            }
            return "SizeFittingTextLayoutComputer(\(description))"
        }
    }
}

// MARK: - SizeFittingTextFilter [TBA]

struct SizeFittingTextFilter: StatefulRule, AsyncAttribute {
    @Attribute var size: ViewSize
    @Attribute var text: Text
    @Attribute var environment: EnvironmentValues
    let cache: SizeFittingTextCache<ResolvedTextHelper, StickyTextSizeFittingLogic>

    init(
        size: Attribute<ViewSize>,
        text: Attribute<Text>,
        environment: Attribute<EnvironmentValues>,
        time: Attribute<Time>,
        referenceDate: WeakAttribute<Date?>,
        includeDefaultAttributes: Bool,
        allowsKeyColors: Bool,
        archiveOptions: ArchivedViewInput.Value,
        features: Text.ResolvedProperties.Features,
        attachmentsAsAuxiliaryMetadata: Bool,
        idiom: AnyInterfaceIdiom
    ) {
        _size = size
        _text = text
        _environment = environment
        let helper = ResolvedTextHelper(
            time: time,
            referenceDate: referenceDate,
            includeDefaultAttributes: includeDefaultAttributes,
            allowsKeyColors: allowsKeyColors,
            archiveOptions: archiveOptions,
            features: features,
            attachmentsAsAuxiliaryMetadata: attachmentsAsAuxiliaryMetadata,
            idiom: idiom,
            lastText: nil,
            nextUpdate: .time(.zero),
            sizeVariant: .regular
        )
        cache = SizeFittingTextCache(
            resolver: helper,
            logic: StickyTextSizeFittingLogic(),
            initialInput: (nil, EnvironmentValues(), nil)
        )
    }

    typealias Value = ResolvedStyledText

    // NOTE: Forces the output’s mainRef to false, regardless of those inputs.
    static var flags: Flags { .asyncThread }

    mutating func updateValue() {
        value = cache.withValue(for: size.proposal) { $0.text }
        cache.withResolver(for: size.proposal) { helper in
            let nextUpdate: Time?
            switch helper.nextUpdate {
            case let .time(time):
                nextUpdate = time
            case let .recipe(lastTime, lastDate, reduceFrequency, resolved):
                let time = resolved.nextUpdate(
                    after: lastTime,
                    equivalentDate: lastDate,
                    reduceFrequency: reduceFrequency
                )
                helper.nextUpdate = .time(time)
                nextUpdate = time
            case .none:
                nextUpdate = nil
            }
            if let nextUpdate, helper.time < nextUpdate {
                ViewGraph.current.nextUpdate.views.at(nextUpdate)
            }
            cache.logic.committedValue = (helper.sizeVariant, size.proposal)
        }
    }
}

// MARK: - VariantThatFitsModifier

struct VariantThatFitsModifier: PrimitiveViewModifier, _GraphInputsModifier {
    static func _makeInputs(
        modifier: _GraphValue<Self>,
        inputs: inout _GraphInputs
    ) {
        inputs[VariantThatFitsFlag.self] = true
    }
}

// MARK: - _ViewInputs + VariantThatFitsFlag

struct VariantThatFitsFlag: ViewInputBoolFlag {}

extension _ViewInputs {
    @inline(__always)
    var variantThatFits: Bool {
        get { self[VariantThatFitsFlag.self] }
        set { self[VariantThatFitsFlag.self] = newValue }
    }
}

// MARK: - EnvironmentValues + textSizeVariant

extension EnvironmentValues {
    private struct TextSizeVariantKey: EnvironmentKey {
        static let defaultValue: TextSizeVariant = .regular
    }

    @inline(__always)
    var textSizeVariant: TextSizeVariant {
        get { self[TextSizeVariantKey.self] }
        set { self[TextSizeVariantKey.self] = newValue }
    }
}
