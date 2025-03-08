//
//  DynamicViewContent.swift
//  OpenSwiftUICore
//
//  Audited for iOS 18.0
//  Status: Complete

/// A type of view that generates views from an underlying collection of data.
public protocol DynamicViewContent: View {
    /// The type of the underlying collection of data.
    associatedtype Data: Collection

    /// The collection of underlying data.
    var data: Data { get }
}

extension ForEach: DynamicViewContent where Content: View {}

extension ModifiedContent: DynamicViewContent where Content: DynamicViewContent, Modifier: ViewModifier {
    public var data: Content.Data {
        content.data
    }
}

package struct DynamicViewContentIDTraitKey: _ViewTraitKey {
    package static let defaultValue: Int? = nil
}

package struct DynamicViewContentOffsetTraitKey: _ViewTraitKey {
    package static let defaultValue: Int? = nil
}

package struct DynamicContentOffsetVisitor: ViewListVisitor {
    package var offset: Int?

    package mutating func visit(view: _ViewList_View, traits: ViewTraitCollection) -> Bool {
        offset = traits.value(for: DynamicViewContentOffsetTraitKey.self)
        return false
    }
}
