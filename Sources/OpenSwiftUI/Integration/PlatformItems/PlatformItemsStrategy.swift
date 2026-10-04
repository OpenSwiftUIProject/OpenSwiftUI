//
//  PlatformItemsStrategy.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: WIP

import OpenAttributeGraphShims
import OpenSwiftUICore

// MARK: - PlatformItemsStrategy

protocol PlatformItemsStrategy {
    associatedtype Content

    static var defaultValue: Content { get }
    static var itemsFeatures: PlatformItems.Features { get }
    static var itemFeatures: PlatformItem.Features { get }

    static func hasChanges(from oldContent: Content, to newContent: Content) -> Bool
    static func makeInputs(_ inputs: inout _ViewInputs)
    static func makeContent(from outputs: _ViewOutputs) -> OptionalAttribute<Content>
}
