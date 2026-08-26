//
//  ResolvableTextSegmentAttribute.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: E9C99F480CB4DD26488FF949B5D8B9E1 (SwiftUICore)

package import Foundation

// MARK: - NSAttributedString.Key + resolvableTextSegment

extension NSAttributedString.Key {
    package static let resolvableTextSegment: NSAttributedString.Key = .init(ResolvableTextSegmentAttribute.name)
}

// MARK: - ResolvableTextSegmentAttribute

package enum ResolvableTextSegmentAttribute: CodableAttributedStringKey {

    // MARK: - ResolvableTextSegmentAttribute.Value

    package struct Value: Codable, Hashable {
        private let uuid: UUID

        @CodableRawRepresentable
        private var resolvableAttributeKey: NSAttributedString.Key

        private var runs: [Run]

        fileprivate init(
            uuid: UUID,
            resolvableAttributeKey: NSAttributedString.Key,
            runs: [Run]
        ) {
            self.uuid = uuid
            self.resolvableAttributeKey = resolvableAttributeKey
            self.runs = runs
        }

        package func isAttributeRequiredForResolution(
            _ attribute: NSAttributedString.Key,
            includeNonFunctionalAttributes: Bool
        ) -> Bool {
            if attribute == .resolvableTextSegment ||
                attribute == .updateSchedule ||
                attribute == resolvableAttributeKey
            {
                return true
            }
            guard includeNonFunctionalAttributes else {
                return false
            }
            return runs.contains { run in
                run.attributesToApply[attribute] == nil &&
                    !run.attributeKeysToErase.contains(attribute)
            }
        }

        package static func == (lhs: Value, rhs: Value) -> Bool {
            lhs.uuid == rhs.uuid
        }

        package func hash(into hasher: inout Hasher) {
            hasher.combine(uuid)
        }

        func restoreDefault(
            in range: NSRange,
            of string: NSMutableAttributedString
        ) {
            for run in runs {
                let runRange = NSRange(
                    location: range.location + run.range.lowerBound,
                    length: run.range.upperBound - run.range.lowerBound
                )
                for key in run.attributeKeysToErase {
                    string.removeAttribute(key, range: runRange)
                }
                string.addAttributes(run.attributesToApply, range: runRange)
            }
        }

        func toggleAttributes(
            in range: NSRange,
            of string: NSMutableAttributedString
        ) {
            string.removeAttribute(.resolvableTextSegment, range: range)
            let targetRuns = string.runs(in: range)
            restoreDefault(in: range, of: string)
            let currentRuns = string.runs(in: range)
            var reverseRuns: [Run] = []
            reverseRuns.reserveCapacity(max(targetRuns.count, currentRuns.count))
            var currentRunIndex = 0
            for targetRun in targetRuns {
                while currentRunIndex < currentRuns.count {
                    let currentRun = currentRuns[currentRunIndex]
                    let intersection = NSIntersectionRange(targetRun.range, currentRun.range)
                    guard intersection.length != 0 else {
                        break
                    }
                    reverseRuns.append(Run(
                        range: NSRange(
                            location: intersection.location - range.location,
                            length: intersection.length
                        ),
                        oldAttributes: targetRun.attributes,
                        newAttributes: currentRun.attributes
                    ))
                    currentRunIndex += 1
                }
                currentRunIndex = max(currentRunIndex - 1, 0)
            }
            let value = Value(
                uuid: UUID(),
                resolvableAttributeKey: resolvableAttributeKey,
                runs: reverseRuns
            )
            string.addAttribute(.resolvableTextSegment, value: value, range: range)
        }

        func update(
            _ range: NSRange,
            of string: NSMutableAttributedString,
            in context: ResolvableStringResolutionContext
        ) {
            guard let attributeValue = string.attributes(at: range.location, effectiveRange: nil)[resolvableAttributeKey],
                  let resolvable = attributeValue as? any ResolvableStringAttribute,
                  let resolved = resolvable.resolve(in: context) else {
                Log.internalWarning(
                    "Unable to update ResolvableStringAttributein \(range) of \(string)\""
                )
                return
            }
            restoreDefault(in: range, of: string)
            string.removeAttribute(.resolvableTextSegment, range: range)
            string.removeAttribute(resolvableAttributeKey, range: range)
            let defaultAttributes = string.attributes(at: range.location, effectiveRange: nil)

            var resolvedString = String(resolved.characters)
            if context.environment.shouldRedactContent {
                resolvedString = String(repeating: "􀮷", count: resolvedString.count)
            }
            resolvedString = resolvedString.caseConvertedIfNeeded(context.environment)
            string.replaceCharacters(in: range, with: resolvedString)
            let attributedResolution = NSAttributedString(resolved)
            attributedResolution.enumerateAttributes(
                in: attributedResolution.range
            ) { attributes, runRange, _ in
                string.addAttributes(
                    attributes,
                    range: NSRange(
                        location: range.location + runRange.location,
                        length: runRange.length
                    )
                )
            }
            let newRange = NSRange(
                location: range.location,
                length: attributedResolution.length
            )
            let value = Value(
                uuid: UUID(),
                resolvableAttributeKey: resolvableAttributeKey,
                runs: string.runs(in: newRange).map { run in
                    Run(
                        range: NSRange(
                            location: run.range.location - newRange.location,
                            length: run.range.length
                        ),
                        oldAttributes: defaultAttributes,
                        newAttributes: run.attributes
                    )
                }
            )
            string.addAttribute(.resolvableTextSegment, value: value, range: newRange)
            string.addAttribute(resolvableAttributeKey, value: resolvable, range: newRange)
        }

        // MARK: - ResolvableTextSegmentAttribute.Run

        fileprivate struct Run: Codable {
            let range: Range<Int>

            @CodableNSAttributes
            var attributesToApply: [NSAttributedString.Key: Any]

            @ProxyCodable
            var attributeKeysToErase: [NSAttributedString.Key]

            init(
                range: NSRange,
                oldAttributes: [NSAttributedString.Key: Any],
                newAttributes: [NSAttributedString.Key: Any]
            ) {
                func areEqual(_ lhs: Any, _ rhs: Any) -> Bool {
                    func areEqual<T>(_ lhs: T, _ rhs: Any) -> Bool where T: Equatable {
                        guard let rhs = rhs as? T else {
                            return false
                        }
                        return lhs == rhs
                    }
                    guard let lhs = lhs as? any Equatable else {
                        return false
                    }
                    return areEqual(lhs, rhs)
                }

                self.range = range.lowerBound ..< range.upperBound
                guard !newAttributes.isEmpty else {
                    attributesToApply = [:]
                    attributeKeysToErase = []
                    return
                }
                var equalKeys: Set<NSAttributedString.Key> = []
                let attributesToApply = oldAttributes.filter { key, oldValue in
                    guard let newValue = newAttributes[key] else {
                        return true
                    }
                    guard areEqual(newValue, oldValue) else {
                        return true
                    }
                    equalKeys.insert(key)
                    return false
                }
                let attributeKeysToErase = newAttributes.keys.filter { key in
                    attributesToApply[key] == nil && !equalKeys.contains(key)
                }
                self.attributesToApply = attributesToApply
                self.attributeKeysToErase = attributeKeysToErase
            }
        }
    }

    package static let name: String = "OpenSwiftUI.resolvableTextSegment"
}

// MARK: - ResolvableTextSegmentAttribute + Updates

extension ResolvableTextSegmentAttribute {
    package static func legacySegment(
        resolvableAttributeKey: NSAttributedString.Key,
        length: Int
    ) -> Value {
        Value(
            uuid: UUID(),
            resolvableAttributeKey: resolvableAttributeKey,
            runs: [Value.Run(
                range: NSRange(location: 0, length: length),
                oldAttributes: [:],
                newAttributes: [:]
            )]
        )
    }

    package static func toggleAttributes(in string: NSMutableAttributedString) {
        string.enumerateAttribute(.resolvableTextSegment, in: string.range) { value, range, _ in
            guard let value = value as? Value else {
                return
            }
            value.toggleAttributes(in: range, of: string)
        }
    }

    package static func update(
        _ string: NSMutableAttributedString,
        in context: ResolvableStringResolutionContext
    ) {
        string.enumerateAttribute(
            .resolvableTextSegment,
            in: string.range,
            options: .reverse
        ) { value, range, _ in
            guard let value = value as? Value else {
                return
            }
            value.update(range, of: string, in: context)
        }
    }
}

// MARK: - ResolvableTextSegmentAttribute + Construction

extension ResolvableTextSegmentAttribute {
    package static func buildDynamicTextSegment<R>(
        for resolvable: R,
        style: Text.Style,
        environment: EnvironmentValues,
        includeDefaultAttributes: Bool,
        options: Text.ResolveOptions,
        properties: inout Text.ResolvedProperties
    ) -> NSMutableAttributedString? where R: ResolvableStringAttribute {
        if options.contains(.includeSupportForRepeatedResolution) {
            buildResolvableTextSegment(
                for: resolvable,
                style: style,
                environment: environment,
                includeDefaultAttributes: includeDefaultAttributes,
                options: options,
                properties: &properties
            )
        } else {
            buildUpdatableTextSegment(
                for: resolvable,
                style: style,
                environment: environment,
                includeDefaultAttributes: includeDefaultAttributes,
                options: options,
                properties: &properties
            )
        }
    }

    private static func buildResolvableTextSegment<R>(
        for resolvable: R,
        style: Text.Style,
        environment: EnvironmentValues,
        includeDefaultAttributes: Bool,
        options: Text.ResolveOptions,
        properties: inout Text.ResolvedProperties
    ) -> NSMutableAttributedString? where R: ResolvableStringAttribute {
        var variant = resolvable.sizeVariant(environment.textSizeVariant).resolvable
        guard let string = buildStaticTextSegment(
            for: resolvable,
            style: style,
            environment: environment,
            includeDefaultAttributes: includeDefaultAttributes,
            options: options,
            properties: &properties
        ) else {
            return nil
        }
        let content = string.string
        let defaultAttributes = style.nsAttributes(
            content: { content },
            environment: environment,
            includeDefaultAttributes: includeDefaultAttributes,
            with: options,
            properties: &properties
        )
        var resolver = PlatformAttributeResolver(
            content: content,
            style: style,
            environment: environment,
            options: options,
            defaultAttributes: defaultAttributes,
            properties: properties
        )
        variant.makePlatformAttributes(resolver: &resolver)
        properties = resolver.properties
        let value = Value(
            uuid: UUID(),
            resolvableAttributeKey: R.attribute,
            runs: string.runs().map { run in
                Value.Run(
                    range: run.range,
                    oldAttributes: defaultAttributes,
                    newAttributes: run.attributes
                )
            }
        )
        string.addUniformAttribute(R.attribute, value: variant)
        string.addUniformAttribute(.resolvableTextSegment, value: value)
        return string
    }

    private static func buildUpdatableTextSegment<R>(
        for resolvable: R,
        style: Text.Style,
        environment: EnvironmentValues,
        includeDefaultAttributes: Bool,
        options: Text.ResolveOptions,
        properties: inout Text.ResolvedProperties
    ) -> NSMutableAttributedString? where R: ResolvableStringAttribute {
        let variant = resolvable.sizeVariant(environment.textSizeVariant)
        if variant.exact {
            properties.features.insert(.isUniqueSizeVariant)
        }
        guard let string = buildStaticTextSegment(
            for: variant.resolvable,
            style: style,
            environment: environment,
            includeDefaultAttributes: includeDefaultAttributes,
            options: options,
            properties: &properties
        ) else {
            return nil
        }
        let value = Value(
            uuid: UUID(),
            resolvableAttributeKey: R.attribute,
            runs: string.runs().map { run in
                Value.Run(
                    range: run.range,
                    oldAttributes: [:],
                    newAttributes: [:]
                )
            }
        )
        string.addUniformAttribute(R.attribute, value: variant.resolvable)
        string.addUniformAttribute(.resolvableTextSegment, value: value)
        return string
    }

    package static func buildStaticTextSegment<R>(
        for resolvable: R,
        style: Text.Style,
        environment: EnvironmentValues,
        includeDefaultAttributes: Bool,
        options: Text.ResolveOptions,
        properties: inout Text.ResolvedProperties
    ) -> NSMutableAttributedString? where R: ResolvableStringAttribute {
        let variant = resolvable.sizeVariant(environment.textSizeVariant)
        if variant.exact {
            properties.features.insert(.isUniqueSizeVariant)
        }
        guard let resolved = variant.resolvable.initialResolution(
            in: environment,
            options: options,
            properties: &properties
        ) else {
            return nil
        }
        let result = NSMutableAttributedString(resolved)
        result.convertToPlatformStyled(
            style: style,
            environment: environment,
            includeDefaultAttributes: includeDefaultAttributes,
            options: options,
            properties: &properties
        )
        if environment.sensitiveContent {
            properties.addSensitive()
        }
        return result
    }
}

// MARK: - ResolvableStringAttribute + Initial Resolution

extension ResolvableStringAttribute {
    fileprivate func initialResolution(
        in environment: EnvironmentValues,
        options: Text.ResolveOptions,
        properties: inout Text.ResolvedProperties
    ) -> AttributedString? {
        properties.features.formUnion(requiredFeatures)
        if options.contains(.writeAuxiliaryMetadata) {
            return AttributedString(String.nsAttachment)
        } else {
            return resolve(in: ResolvableStringResolutionContext(environment: environment))
        }
    }
}

// MARK: - PlatformAttributeResolver

package struct PlatformAttributeResolver {
    let content: String
    let style: Text.Style
    let environment: EnvironmentValues
    let options: Text.ResolveOptions
    let defaultAttributes: [NSAttributedString.Key: Any]
    var properties: Text.ResolvedProperties

    mutating func platformAttributes(
        for container: AttributeContainer,
        includeDefaultValueAttributes: Bool
    ) -> [NSAttributedString.Key: Any] {
        #if canImport(Darwin)
        var attributes = [NSAttributedString.Key: Any](container)
        var style = style
        attributes.transferAttributedStringStyles(to: &style)
        let content = content
        let platformAttributes = style.nsAttributes(
            content: { content },
            environment: environment,
            includeDefaultAttributes: true,
            with: options,
            properties: &properties
        )
        attributes.merge(platformAttributes) { _, new in new }
        guard !includeDefaultValueAttributes else {
            return attributes
        }
        for (key, defaultValue) in defaultAttributes {
            guard let value = attributes[key],
                  AttributeContainer([key: value]) == AttributeContainer([key: defaultValue])
            else {
                continue
            }
            attributes[key] = nil
        }
        return attributes
        #else
        _openSwiftUIPlatformUnimplementedWarning()
        return [:]
        #endif
    }
}
