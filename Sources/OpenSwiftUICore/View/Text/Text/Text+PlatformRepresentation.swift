//
//  Text+PlatformRepresentation.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: 03CAEBF34B5290A85C0CA97765182271 (SwiftUICore)

package import Foundation
package import OpenAttributeGraphShims

package protocol PlatformTextRepresentable {
    static func shouldMakeRepresentation(
        inputs: _ViewInputs
    ) -> Bool

    static func representationOptions(
        inputs: _ViewInputs
    ) -> RepresentationOptions

    static func makeRepresentation(
        inputs: _ViewInputs,
        context: Attribute<Context>,
        outputs: inout _ViewOutputs
    )

    typealias Context = PlatformTextRepresentableContext

    typealias RepresentationOptions = PlatformTextRepresentationOptions
}

package struct PlatformTextRepresentableContext {
    package var text: NSAttributedString?
}

package struct PlatformTextRepresentationOptions: OptionSet {
    package let rawValue: Int

    package init(rawValue: Int) {
        self.rawValue = rawValue
    }

    package static let includeStyledText: PlatformTextRepresentationOptions = .init(rawValue: 1 << 0)
}

extension _ViewInputs {
    package var requestedTextRepresentation: (any PlatformTextRepresentable.Type)? {
        get { base.requestedTextRepresentation }
        set { base.requestedTextRepresentation = newValue }
    }
}

extension _GraphInputs {
    private struct TextRepresentationKey: GraphInput {
        static var defaultValue: (any PlatformTextRepresentable.Type)? { nil }
    }

    package var requestedTextRepresentation: (any PlatformTextRepresentable.Type)? {
        get { self[TextRepresentationKey.self] }
        set { self[TextRepresentationKey.self] = newValue }
    }
}
