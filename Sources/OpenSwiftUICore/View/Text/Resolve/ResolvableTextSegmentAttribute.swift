//
//  ResolvableTextSegmentAttribute.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete-Stubbed
//  ID: E9C99F480CB4DD26488FF949B5D8B9E1 (SwiftUICore)

package import Foundation

// MARK: - NSAttributedString.Key + resolvableTextSegment

extension NSAttributedString.Key {
    package static let resolvableTextSegment: NSAttributedString.Key = .init(ResolvableTextSegmentAttribute.name)
}

// MARK: - ResolvableTextSegmentAttribute [TODO]

package enum ResolvableTextSegmentAttribute: CodableAttributedStringKey {
    // FIXME
    package struct Value: Codable, Hashable {
        package func isAttributeRequiredForResolution(
            _ attribute: NSAttributedString.Key,
            includeNonFunctionalAttributes: Bool
        ) -> Bool {
            _openSwiftUIUnimplementedFailure()
        }
    }

    package static let name: String = "OpenSwiftUI.resolvableTextSegment"
}

extension ResolvableTextSegmentAttribute {
    package static func legacySegment(
        resolvableAttributeKey: NSAttributedString.Key,
        length: Int
    ) -> Value {
        _openSwiftUIUnimplementedFailure()
    }

    package static func toggleAttributes(in string: NSMutableAttributedString) {
        _openSwiftUIUnimplementedFailure()
    }

    package static func update(
        _ string: NSMutableAttributedString,
        in context: ResolvableStringResolutionContext
    ) {
        _openSwiftUIUnimplementedFailure()
    }
}

extension ResolvableTextSegmentAttribute {
    package static func buildDynamicTextSegment<R>(
        for resolvable: R,
        style: Text.Style,
        environment: EnvironmentValues,
        includeDefaultAttributes: Bool,
        options: Text.ResolveOptions,
        properties: inout Text.ResolvedProperties
    ) -> NSMutableAttributedString? where R: ResolvableStringAttribute {
        _openSwiftUIUnimplementedWarning()
        return nil
    }

    package static func buildStaticTextSegment<R>(
        for resolvable: R,
        style: Text.Style,
        environment: EnvironmentValues,
        includeDefaultAttributes: Bool,
        options: Text.ResolveOptions,
        properties: inout Text.ResolvedProperties
    ) -> NSMutableAttributedString? where R: ResolvableStringAttribute {
        _openSwiftUIUnimplementedWarning()
        return nil
    }
}

// MARK: - PlatformAttributeResolver [TODO]

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
