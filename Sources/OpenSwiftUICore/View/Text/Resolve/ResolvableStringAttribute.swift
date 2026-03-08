//
//  ResolvableStringAttribute.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: 6237733B8EBAC19656F21E79CFCF2D67 (SwiftUICore)

package import Foundation

// MARK: - ResolvableStringResolutionContext

package struct ResolvableStringResolutionContext {
    package var referenceDate: Date?
    package var environment: EnvironmentValues
    package var maximumWidth: CGFloat?

    package var date: Date {
        referenceDate ?? environment.stringResolutionDate ?? .now
    }

    package init(
        referenceDate: Date? = nil,
        environment: EnvironmentValues,
        maximumWidth: CGFloat? = nil
    ) {
        self.referenceDate = referenceDate
        self.environment = environment
        self.maximumWidth = maximumWidth
    }

    package init(
        environment: EnvironmentValues,
        maximumWidth: CGFloat? = nil
    ) {
        self.referenceDate = environment.resolvableStringReferenceDate
        self.environment = environment
        self.maximumWidth = maximumWidth
    }
}

// MARK: - ResolvableStringAttributeFamily

package protocol ResolvableStringAttributeFamily {
    static var attribute: NSAttributedString.Key { get }

    static func decode(
        from decoder: any Decoder
    ) throws -> (any ResolvableStringAttribute)?
}

// MARK: - ResolvableStringAttributeRepresentation

package protocol ResolvableStringAttributeRepresentation {
    associatedtype Family: ResolvableStringAttributeFamily

    static func encode(
        _ resolvable: Self,
        to encoder: any Encoder
    ) throws

    func representation(
        for version: ArchivedViewInput.DeploymentVersion
    ) -> any ResolvableStringAttributeRepresentation
}

// MARK: - ResolvableStringAttribute

package protocol ResolvableStringAttribute: ResolvableStringAttributeRepresentation, TimelineSchedule where Entries == AnySequence<Date> {
    associatedtype Schedule: TimelineSchedule

    func resolve(in context: ResolvableStringResolutionContext) -> AttributedString?

    var schedule: Schedule? { get }

    var requiredFeatures: Text.ResolvedProperties.Features { get }

    mutating func makePlatformAttributes(resolver: inout PlatformAttributeResolver)

    func sizeVariant(_ sizeVariant: TextSizeVariant) -> (resolvable: Self, exact: Bool)
}

extension ResolvableStringAttributeRepresentation where Self: ResolvableStringAttributeFamily {
    package typealias Family = Self
}

extension ResolvableStringAttributeRepresentation where Self: Decodable, Self: Encodable, Self: ResolvableStringAttributeFamily {
    package static func encode(
        _ resolvable: Self,
        to encoder: any Encoder
    ) throws {
        try resolvable.encode(to: encoder)
    }
}

extension ResolvableStringAttribute where Self: Decodable, Self: Encodable, Self: ResolvableStringAttributeFamily {
    package static func decode(
        from decoder: any Decoder
    ) throws -> (any ResolvableStringAttribute)? {
        try Self(from: decoder)
    }
}

extension ResolvableStringAttributeRepresentation {
    package func representation(
        for version: ArchivedViewInput.DeploymentVersion
    ) -> any ResolvableStringAttributeRepresentation {
        self
    }
}

extension ResolvableStringAttributeRepresentation {
    package static var attribute: NSAttributedString.Key {
        Family.attribute
    }
}

extension ResolvableStringAttribute {
    package var requiredFeatures: Text.ResolvedProperties.Features {
        []
    }
}

extension ResolvableStringAttribute {
    package mutating func makePlatformAttributes(resolver: inout PlatformAttributeResolver) {
        _openSwiftUIEmptyStub()
    }
}

extension ResolvableStringAttribute {
    package func sizeVariant(_ sizeVariant: TextSizeVariant) -> (resolvable: Self, exact: Bool) {
        (self, sizeVariant.rawValue == 0)
    }
}

extension ResolvableStringAttribute {
    package var isDynamic: Bool {
        schedule != nil
    }

    package func entries(
        from startDate: Date,
        mode: TimelineScheduleMode
    ) -> AnySequence<Date> {
        guard let schedule else { return AnySequence([]) }
        return AnySequence(schedule.entries(from: startDate, mode: mode))
    }
}

extension EnvironmentValues {
    private struct ResolvableStringReferenceDateKey: EnvironmentKey {
        static let defaultValue: Date? = nil
    }

    package var resolvableStringReferenceDate: Date? {
        get { self[ResolvableStringReferenceDateKey.self] }
        set { self[ResolvableStringReferenceDateKey.self] = newValue }
    }
}

extension EnvironmentValues {
    private struct StringResolutionDate: EnvironmentKey {
        static let defaultValue: Date? = nil
    }

    package var stringResolutionDate: Date? {
        get { self[StringResolutionDate.self] }
        set { self[StringResolutionDate.self] = newValue }
    }
}

// FIXME: PlatformAttributeResolver

package struct PlatformAttributeResolver {
    let content: String
    let style: Text.Style
    let environment: EnvironmentValues
    let options: Text.ResolveOptions
    let defaultAttributes: [NSAttributedString.Key: Any]
    var properties: Text.ResolvedProperties

    func platformAttributes(
        for container: AttributeContainer,
        includeDefaultValueAttributes: Bool
    ) -> [NSAttributedString.Key: Any] {
        _openSwiftUIUnimplementedFailure()
    }
}
