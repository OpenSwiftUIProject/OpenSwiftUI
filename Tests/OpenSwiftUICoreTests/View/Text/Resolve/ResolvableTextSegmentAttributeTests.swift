//
//  ResolvableTextSegmentAttributeTests.swift
//  OpenSwiftUICoreTests

import Foundation
@_spi(ForOpenSwiftUIOnly) @testable import OpenSwiftUICore
import Testing

struct ResolvableTextSegmentAttributeTests {
    @Test
    func legacySegmentIdentityAndRequiredAttributes() {
        let first = ResolvableTextSegmentAttribute.legacySegment(
            resolvableAttributeKey: TestResolvable.attribute,
            length: 4
        )
        let second = ResolvableTextSegmentAttribute.legacySegment(
            resolvableAttributeKey: TestResolvable.attribute,
            length: 4
        )

        #expect(first != second)
        #expect(first.isAttributeRequiredForResolution(
            .resolvableTextSegment,
            includeNonFunctionalAttributes: false
        ))
        #expect(first.isAttributeRequiredForResolution(
            .updateSchedule,
            includeNonFunctionalAttributes: false
        ))
        #expect(first.isAttributeRequiredForResolution(
            TestResolvable.attribute,
            includeNonFunctionalAttributes: false
        ))
        #expect(first.isAttributeRequiredForResolution(
            NSAttributedString.Key("unrelated"),
            includeNonFunctionalAttributes: true
        ))
        #expect(!first.isAttributeRequiredForResolution(
            NSAttributedString.Key("unrelated"),
            includeNonFunctionalAttributes: false
        ))

        #expect(first == first)
    }

    @Test
    func staticSegmentResolvesContentAndMetadata() throws {
        var properties = Text.ResolvedProperties()
        let resolved = try #require(ResolvableTextSegmentAttribute.buildStaticTextSegment(
            for: TestResolvable(text: "initial"),
            style: Text.Style(),
            environment: EnvironmentValues(),
            includeDefaultAttributes: false,
            options: [],
            properties: &properties
        ))
        #expect(resolved.string == "initial")
        #expect(properties.features.contains(.attachments))
        #expect(resolved.attribute(
            .resolvableTextSegment,
            at: 0,
            effectiveRange: nil
        ) == nil)

        properties = Text.ResolvedProperties()
        let metadata = try #require(ResolvableTextSegmentAttribute.buildStaticTextSegment(
            for: TestResolvable(text: "initial"),
            style: Text.Style(),
            environment: EnvironmentValues(),
            includeDefaultAttributes: false,
            options: Text.ResolveOptions(rawValue: 1 << 2),
            properties: &properties
        ))
        #expect(metadata.string == String.nsAttachment)
    }

    @Test
    func dynamicSegmentTogglesAttributesAndIdentity() throws {
        var properties = Text.ResolvedProperties()
        let string = try #require(ResolvableTextSegmentAttribute.buildDynamicTextSegment(
            for: TestResolvable(text: "initial", kern: 3),
            style: Text.Style(),
            environment: EnvironmentValues(),
            includeDefaultAttributes: false,
            options: Text.ResolveOptions(rawValue: 1 << 7),
            properties: &properties
        ))
        let first = try #require(string.attribute(
            NSAttributedString.Key.resolvableTextSegment,
            at: 0,
            effectiveRange: nil
        ) as? ResolvableTextSegmentAttribute.Value)
        #if canImport(Darwin)
        #expect((string.attribute(
            .kitKern,
            at: 0,
            effectiveRange: nil
        ) as? NSNumber)?.doubleValue == 3)
        #endif

        ResolvableTextSegmentAttribute.toggleAttributes(in: string)
        let second = try #require(string.attribute(
            NSAttributedString.Key.resolvableTextSegment,
            at: 0,
            effectiveRange: nil
        ) as? ResolvableTextSegmentAttribute.Value)
        #expect(second != first)
        #expect(string.string == "initial")
        #if canImport(Darwin)
        #expect(string.attribute(
            .kitKern,
            at: 0,
            effectiveRange: nil
        ) == nil)
        #endif

        ResolvableTextSegmentAttribute.toggleAttributes(in: string)
        let third = try #require(string.attribute(
            NSAttributedString.Key.resolvableTextSegment,
            at: 0,
            effectiveRange: nil
        ) as? ResolvableTextSegmentAttribute.Value)
        #expect(third != second)
        #expect(string.string == "initial")
        #if canImport(Darwin)
        #expect((string.attribute(
            .kitKern,
            at: 0,
            effectiveRange: nil
        ) as? NSNumber)?.doubleValue == 3)
        #endif
    }

    @Test
    func updateReplacesSegmentsInReverseOrder() throws {
        var properties = Text.ResolvedProperties()
        let first = try #require(ResolvableTextSegmentAttribute.buildDynamicTextSegment(
            for: OrderTrackingResolvable(
                identifier: "first",
                initialText: "first-initial",
                updatedText: "1"
            ),
            style: Text.Style(),
            environment: EnvironmentValues(),
            includeDefaultAttributes: false,
            options: [],
            properties: &properties
        ))
        let second = try #require(ResolvableTextSegmentAttribute.buildDynamicTextSegment(
            for: OrderTrackingResolvable(
                identifier: "second",
                initialText: "second-initial",
                updatedText: "22"
            ),
            style: Text.Style(),
            environment: EnvironmentValues(),
            includeDefaultAttributes: false,
            options: [],
            properties: &properties
        ))
        first.append(second)
        OrderTrackingResolvable.resetResolutionOrder()

        ResolvableTextSegmentAttribute.update(
            first,
            in: ResolvableStringResolutionContext(
                environment: EnvironmentValues(),
                maximumWidth: 7
            )
        )

        #expect(OrderTrackingResolvable.resolutionOrder == ["second", "first"])
        #expect(first.string == "122")
        for location in 0 ..< first.length {
            #expect(first.attribute(
                OrderTrackingResolvable.attribute,
                at: location,
                effectiveRange: nil
            ) is OrderTrackingResolvable)
            #expect(first.attribute(
                .resolvableTextSegment,
                at: location,
                effectiveRange: nil
            ) is ResolvableTextSegmentAttribute.Value)
        }
    }

    @Test
    func updatableSegmentUsesSizeVariantAndTracksExactness() throws {
        var compactEnvironment = EnvironmentValues()
        compactEnvironment.textSizeVariant = .compact
        var compactProperties = Text.ResolvedProperties()
        let compact = try #require(ResolvableTextSegmentAttribute.buildDynamicTextSegment(
            for: SizeVariantResolvable(text: "unselected"),
            style: Text.Style(),
            environment: compactEnvironment,
            includeDefaultAttributes: false,
            options: [],
            properties: &compactProperties
        ))
        #expect(compact.string == "compact")
        #expect(compactProperties.features.contains(.isUniqueSizeVariant))

        var smallEnvironment = EnvironmentValues()
        smallEnvironment.textSizeVariant = .small
        var smallProperties = Text.ResolvedProperties()
        let small = try #require(ResolvableTextSegmentAttribute.buildDynamicTextSegment(
            for: SizeVariantResolvable(text: "unselected"),
            style: Text.Style(),
            environment: smallEnvironment,
            includeDefaultAttributes: false,
            options: [],
            properties: &smallProperties
        ))
        #expect(small.string == "small")
        #expect(!smallProperties.features.contains(.isUniqueSizeVariant))
    }

    @Test
    func updateScheduleCombinesResolvableSegmentsAndCachesResult() throws {
        let firstDate = Date(timeIntervalSinceReferenceDate: 10)
        let secondDate = Date(timeIntervalSinceReferenceDate: 20)
        let thirdDate = Date(timeIntervalSinceReferenceDate: 30)
        let fourthDate = Date(timeIntervalSinceReferenceDate: 40)
        var properties = Text.ResolvedProperties()
        let string = try #require(ResolvableTextSegmentAttribute.buildDynamicTextSegment(
            for: ScheduledResolvable(
                text: "first",
                dates: [firstDate, thirdDate]
            ),
            style: Text.Style(),
            environment: EnvironmentValues(),
            includeDefaultAttributes: false,
            options: [],
            properties: &properties
        ))
        let second = try #require(ResolvableTextSegmentAttribute.buildDynamicTextSegment(
            for: ScheduledResolvable(
                text: "second",
                dates: [secondDate, thirdDate, fourthDate]
            ),
            style: Text.Style(),
            environment: EnvironmentValues(),
            includeDefaultAttributes: false,
            options: [],
            properties: &properties
        ))
        string.append(second)

        let schedule = try #require(string.resolveUpdateSchedule(recalculate: true))
        #expect(Array(schedule.entries(from: firstDate, mode: .normal)) == [
            firstDate,
            secondDate,
            thirdDate,
            fourthDate,
        ])
        #expect(string.isDynamic)

        let cachedSchedule = try #require(string.resolveUpdateSchedule(recalculate: false))
        #expect(Array(cachedSchedule.entries(from: firstDate, mode: .normal)) == [
            firstDate,
            secondDate,
            thirdDate,
            fourthDate,
        ])
    }

    @Test
    func recalculatingUpdateScheduleRemovesStaleCache() throws {
        let string = NSMutableAttributedString(string: "static")
        string.addAttribute(
            .updateSchedule,
            value: ExplicitTimelineSchedule([
                Date(timeIntervalSinceReferenceDate: 10),
            ]),
            range: string.range
        )
        #expect(string.resolveUpdateSchedule(recalculate: false) != nil)

        #expect(string.resolveUpdateSchedule(recalculate: true) == nil)
        #expect(!string.isDynamic)
    }

    #if canImport(Darwin)
    @Test
    func platformAttributeResolverFiltersDefaultValues() {
        let container = AttributeContainer()
        var baseResolver = PlatformAttributeResolver(
            content: "content",
            style: Text.Style(),
            environment: EnvironmentValues(),
            options: Text.ResolveOptions(rawValue: 1 << 1),
            defaultAttributes: [:],
            properties: Text.ResolvedProperties()
        )
        let includingDefaults = baseResolver.platformAttributes(
            for: container,
            includeDefaultValueAttributes: true
        )
        #expect(!includingDefaults.isEmpty)
        #expect(baseResolver.properties.features.contains(.keyColor))

        var filteringResolver = PlatformAttributeResolver(
            content: "content",
            style: Text.Style(),
            environment: EnvironmentValues(),
            options: Text.ResolveOptions(rawValue: 1 << 1),
            defaultAttributes: includingDefaults,
            properties: Text.ResolvedProperties()
        )
        let excludingDefaults = filteringResolver.platformAttributes(
            for: container,
            includeDefaultValueAttributes: false
        )
        #expect(excludingDefaults.isEmpty)
    }

    @Test
    func platformAttributeResolverPrefersResolvedPlatformAttributeOnConflict() {
        var style = Text.Style()
        style.baselineOffset = 2
        let container = AttributeContainer([
            .kitBaselineOffset: CGFloat(1),
        ])
        var resolver = PlatformAttributeResolver(
            content: "content",
            style: style,
            environment: EnvironmentValues(),
            options: [],
            defaultAttributes: [:],
            properties: Text.ResolvedProperties()
        )

        let attributes = resolver.platformAttributes(
            for: container,
            includeDefaultValueAttributes: true
        )

        #expect((attributes[.kitBaselineOffset] as? NSNumber)?.doubleValue == 2)
    }
    #endif
}

private struct TestResolvable: ResolvableStringAttribute, ResolvableStringAttributeFamily, Codable {
    static let attribute = NSAttributedString.Key("OpenSwiftUI.TestResolvable")

    var text: String
    var kern: CGFloat? = nil

    func resolve(in context: ResolvableStringResolutionContext) -> AttributedString? {
        let text: String
        if let maximumWidth = context.maximumWidth {
            text = String(Int(maximumWidth))
        } else {
            text = self.text
        }
        var result = AttributedString(text)
        if let kern {
            result.openSwiftUI.kern = kern
        }
        return result
    }

    var schedule: ExplicitTimelineSchedule<[Date]>? {
        nil
    }

    var requiredFeatures: Text.ResolvedProperties.Features {
        .attachments
    }
}

private struct OrderTrackingResolvable: ResolvableStringAttribute, ResolvableStringAttributeFamily, Codable {
    static let attribute = NSAttributedString.Key("OpenSwiftUI.OrderTrackingResolvable")

    private static let resolutions = AtomicBox(wrappedValue: [String]())

    var identifier: String
    var initialText: String
    var updatedText: String

    static var resolutionOrder: [String] {
        resolutions.wrappedValue
    }

    static func resetResolutionOrder() {
        resolutions.access { $0.removeAll(keepingCapacity: true) }
    }

    func resolve(in context: ResolvableStringResolutionContext) -> AttributedString? {
        guard context.maximumWidth != nil else {
            return AttributedString(initialText)
        }
        Self.resolutions.access { $0.append(identifier) }
        return AttributedString(updatedText)
    }

    var schedule: ExplicitTimelineSchedule<[Date]>? {
        nil
    }
}

private struct SizeVariantResolvable: ResolvableStringAttribute, ResolvableStringAttributeFamily, Codable {
    static let attribute = NSAttributedString.Key("OpenSwiftUI.SizeVariantResolvable")

    var text: String

    func resolve(in context: ResolvableStringResolutionContext) -> AttributedString? {
        AttributedString(text)
    }

    var schedule: ExplicitTimelineSchedule<[Date]>? {
        nil
    }

    func sizeVariant(_ sizeVariant: TextSizeVariant) -> (resolvable: Self, exact: Bool) {
        let text: String
        if sizeVariant == .compact {
            text = "compact"
        } else if sizeVariant == .small {
            text = "small"
        } else {
            text = "regular"
        }
        return (Self(text: text), sizeVariant == .compact)
    }
}

private struct ScheduledResolvable: ResolvableStringAttribute, ResolvableStringAttributeFamily, Codable {
    static let attribute = NSAttributedString.Key("OpenSwiftUI.ScheduledResolvable")

    var text: String
    var dates: [Date]

    func resolve(in context: ResolvableStringResolutionContext) -> AttributedString? {
        AttributedString(text)
    }

    var schedule: ExplicitTimelineSchedule<[Date]>? {
        ExplicitTimelineSchedule(dates)
    }
}
