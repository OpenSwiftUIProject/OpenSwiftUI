//
//  Image+PlatformRepresentation.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: 9FE4F19E3F2D6B2A0FD05C040386BBC3 (SwiftUICore)

package import OpenAttributeGraphShims

// MARK: - PlatformImageRepresentable

package protocol PlatformImageRepresentable {
    static func shouldMakeRepresentation(inputs: _ViewInputs) -> Bool

    static func makeRepresentation(inputs: _ViewInputs, context: Attribute<Context>, outputs: inout _ViewOutputs)

    typealias Context = PlatformImageRepresentableContext
}

package struct PlatformImageRepresentableContext {
    package var image: Image.Resolved

    package var tintColor: Color?

    package var foregroundStyle: AnyShapeStyle?
}

extension _ViewInputs {
    package var requestedImageRepresentation: (any PlatformImageRepresentable.Type)? {
        get { base.requestedImageRepresentation }
        set { base.requestedImageRepresentation = newValue }
    }
}

extension _GraphInputs {
    private struct ImageRepresentationKey: GraphInput {
        static var defaultValue: (any PlatformImageRepresentable.Type)? { nil }
    }

    package var requestedImageRepresentation: (any PlatformImageRepresentable.Type)? {
        get { self[ImageRepresentationKey.self] }
        set { self[ImageRepresentationKey.self] = newValue }
    }
}

// MARK: - PlatformNamedImageRepresentable

package protocol PlatformNamedImageRepresentable {
    static func shouldMakeRepresentation(inputs: _ViewInputs) -> Bool

    static func makeRepresentation(inputs: _ViewInputs, context: Attribute<Context>, outputs: inout _ViewOutputs)

    typealias Context = PlatformNamedImageRepresentableContext
}

package struct PlatformNamedImageRepresentableContext {
    package var image: Image

    package var environment: EnvironmentValues
}

extension _ViewInputs {
    package var requestedNamedImageRepresentation: (any PlatformNamedImageRepresentable.Type)? {
        get { base.requestedNamedImageRepresentation }
        set { base.requestedNamedImageRepresentation = newValue }
    }
}

extension _GraphInputs {
    private struct NamedImageRepresentationKey: GraphInput {
        static var defaultValue: (any PlatformNamedImageRepresentable.Type)? { nil }
    }

    package var requestedNamedImageRepresentation: (any PlatformNamedImageRepresentable.Type)? {
        get { self[NamedImageRepresentationKey.self] }
        set { self[NamedImageRepresentationKey.self] = newValue }
    }
}
