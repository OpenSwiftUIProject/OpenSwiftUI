//
//  HasWidgetMetadata.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: FD72118870A434CF0E2B5B97BD09B3FE (SwiftUICore?)

extension _ViewInputs {
    package var hasWidgetMetadata: Bool {
        get { base.hasWidgetMetadata }
        set { base.hasWidgetMetadata = newValue }
    }
}

extension _GraphInputs {
    private struct HasWidgetMetadataKey: GraphInput {
        static var defaultValue: Bool { false }
    }

    package var hasWidgetMetadata: Bool {
        get { self[HasWidgetMetadataKey.self] }
        set { self[HasWidgetMetadataKey.self] = newValue }
    }
}
