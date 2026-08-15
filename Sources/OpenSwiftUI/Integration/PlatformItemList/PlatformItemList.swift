//
//  PlatformItemList.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: WIP
//  ID: CE84B1BFBEAEAB6361605407E54625A3 (SwiftUI)

import Foundation
import OpenAttributeGraphShims
@_spi(ForOpenSwiftUIOnly)
@_spi(Private)
import OpenSwiftUICore

// FIXME
package struct PlatformItemList {
    var items: [Item]

    // FIXME
    struct Item {
        var text: NSAttributedString?
        var secondaryText: NSAttributedString?
        var platformIdentifier: String?
        var isExternal: Bool = false
        var hierarchicalLevel: Int = -1
        var imageColorResolver: ImageColorResolver?
        var isEnabled: Bool = true
        var resolvedImage: Image.Resolved?
        var namedResolvedImage: Image.NamedResolved?
        var systemItem: SystemItem?
        var selectionBehavior: SelectionBehavior?
        var accessibility: Accessibility?
        var label: NSAttributedString?
        var tooltip: String?
        var badge: String?
        var tint: Color?
        // TODO

        init(
            text: NSAttributedString? = nil,
            image: Image.Resolved? = nil,
            selectionBehavior: SelectionBehavior? = nil,
            accessibility: Accessibility? = nil,
            tint: Color? = nil,
            imageColorResolver: ImageColorResolver? = nil
        ) {
            self.text = text
            self.imageColorResolver = imageColorResolver
            self.resolvedImage = image
            self.selectionBehavior = selectionBehavior
            self.accessibility = accessibility
            self.tint = tint
        }

        init(systemItem: SystemItem) {
            self.systemItem = systemItem
        }

        struct SelectionBehavior {}

        struct Accessibility {}

        struct ImageColorResolver {
            var shapeStyle: AnyShapeStyle
        }

        enum SystemItem {
            // TODO
            case divider
            case spacer
            case section
            case labelGroup
            case controlGroup
            case helpLink
            case button
            case menu
        }
    }

    var mergedContentItem: Item {
        // FIXME
        items[0]
    }

    mutating func modify(_ body: (inout Item) -> Void) {
        for index in items.indices {
            body(&items[index])
        }
    }

    fileprivate struct Key: PreferenceKey {
        static let defaultValue: PlatformItemList = .init(items: [])

        static func reduce(value: inout PlatformItemList, nextValue: () -> PlatformItemList) {
            value.items.append(contentsOf: nextValue().items)
        }
    }
}

extension PreferencesInputs {
    @inline(__always)
    var requiresPlatformItemList: Bool {
        get {
            contains(PlatformItemList.Key.self)
        }
        set {
            if newValue {
                add(PlatformItemList.Key.self)
            } else {
                remove(PlatformItemList.Key.self)
            }
        }
    }
}

extension PreferencesOutputs {
    @inline(__always)
    var platformItemList: Attribute<PlatformItemList>? {
        get { self[PlatformItemList.Key.self] }
        set { self[PlatformItemList.Key.self] = newValue }
    }

    @inline(__always)
    mutating func writePlatformItemList(
        inputs: PreferencesInputs,
        value: @autoclosure () -> Attribute<PlatformItemList>
    ) {
        makePreferenceWriter(
            inputs: inputs,
            key: PlatformItemList.Key.self,
            value: value()
        )
    }
}

extension _ViewInputs {
    mutating func addPlatformItemListKey<Flags>(
        flags: Flags.Type,
        editOperation: PlatformItemListFlagsSet.EditOperation? = nil
    ) where Flags: PlatformItemListFlags {
        preferences.requiresPlatformItemList = true
        requestedTextRepresentation = PlatformItemListTextRepresentable.self
        requestedImageRepresentation = PlatformItemListImageRepresentable.self
        requestedNamedImageRepresentation = PlatformItemListNamedImageRepresentable.self
        requestedSpacerRepresentation = PlatformItemListSpacerRepresentable.self
        requestedDividerRepresentation = PlatformItemListDividerRepresentable.self
        requestedViewThatFitsRepresentation = PlatformItemListViewThatFitsRepresentable.self
        requestedHiddenRepresentation = PlatformItemListHiddenRepresentable.self
        requestedDynamicHiddenRepresentation = PlatformItemListDynamicHiddenRepresentable.self
        switch editOperation {
        case .replace:
            platformItemListFlags = Flags.flags
        case .formUnion:
            platformItemListFlags.formUnion(Flags.flags)
        case nil:
            break
        }
    }
}

// MARK: - PlatformItemListDynamicHiddenRepresentable

struct PlatformItemListDynamicHiddenRepresentable: PlatformDynamicHiddenRepresentable {
    static func shouldMakeRepresentation(inputs: _ViewInputs) -> Bool {
        inputs.preferences.requiresPlatformItemList
    }

    static func makeRepresentation(
        inputs: _ViewInputs,
        modifier: Attribute<DynamicHiddenModifier>,
        outputs: inout _ViewOutputs
    ) {
        outputs.preferences.makePreferenceTransformer(
            inputs: inputs.preferences,
            key: PlatformItemList.Key.self,
            transform: Attribute(PlatformItemListTransform(modifier: modifier))
        )
    }

    private struct PlatformItemListTransform: Rule {
        @Attribute var modifier: DynamicHiddenModifier

        var value: (inout PlatformItemList) -> Void {
            { list in
                guard modifier.isHidden else {
                    return
                }
                guard !modifier.allowedKeys.contains(.platformItemList) else {
                    return
                }
                list.items = []
            }
        }
    }
}

// MARK: - PlatformItemListHiddenRepresentable

struct PlatformItemListHiddenRepresentable: PlatformHiddenRepresentable {
    static func makeRepresentation(
        inputs: inout _ViewInputs,
        allowedKeys: AllowedPreferenceKeysWhileHidden
    ) {
        if !allowedKeys.contains(.platformItemList) {
            inputs.preferences.requiresPlatformItemList = false
        }
    }
}

// MARK: - PlatformItemListViewThatFitsRepresentable [WIP]

struct PlatformItemListViewThatFitsRepresentable: PlatformViewThatFitsRepresentable {
    static func shouldMakeRepresentation(inputs: _ViewInputs) -> Bool {
        inputs.preferences.requiresPlatformItemList
            && inputs.platformItemListFlags.contains(._6)
    }

    static func makeRepresentation(
        inputs: _ViewInputs,
        state: SizeFittingState,
        outputs: inout _ViewOutputs
    ) {
        outputs.preferences.makePreferenceTransformer(
            inputs: inputs.preferences,
            key: PlatformItemList.Key.self,
            transform: Attribute(FittingChildrenPlatformItemList(state: state))
        )
    }

    private struct FittingChildrenPlatformItemList: Rule, AsyncAttribute {
        let state: SizeFittingState

        var value: (inout PlatformItemList) -> Void {
            _openSwiftUIUnimplementedFailure()
        }
    }
}

// MARK: - PlatformItemListDividerRepresentable

struct PlatformItemListDividerRepresentable: PlatformDividerRepresentable {
    static func shouldMakeRepresentation(inputs: _ViewInputs) -> Bool {
        inputs.preferences.requiresPlatformItemList
            && inputs.platformItemListFlags.contains(.layout)
    }

    static func makeRepresentation(inputs: _ViewInputs, outputs: inout _ViewOutputs) {
        outputs.preferences.writePlatformItemList(
            inputs: inputs.preferences,
            value: GraphHost.currentHost.intern(
                PlatformItemList(items: [.init(systemItem: .divider)]),
                for: Divider.self,
                id: .placeholder
            )
        )
    }
}

// MARK: - PlatformItemListSpacerRepresentable

struct PlatformItemListSpacerRepresentable: PlatformSpacerRepresentable {
    static func shouldMakeRepresentation(inputs: _ViewInputs) -> Bool {
        inputs.preferences.requiresPlatformItemList
            && inputs.platformItemListFlags.contains(.layout)
    }

    static func makeRepresentation(inputs: _ViewInputs, outputs: inout _ViewOutputs) {
        outputs.preferences.writePlatformItemList(
            inputs: inputs.preferences,
            value: GraphHost.currentHost.intern(
                PlatformItemList(items: [.init(systemItem: .spacer)]),
                for: Spacer.self,
                id: .placeholder
            )
        )
    }
}

// MARK: - PlatformItemListNamedImageRepresentable

struct PlatformItemListNamedImageRepresentable: PlatformNamedImageRepresentable {
    static func shouldMakeRepresentation(inputs: _ViewInputs) -> Bool {
        inputs.preferences.requiresPlatformItemList
            && inputs.platformItemListFlags.contains(._5)
    }

    static func makeRepresentation(
        inputs: _ViewInputs,
        context: Attribute<PlatformNamedImageRepresentableContext>,
        outputs: inout _ViewOutputs
    ) {
        outputs.preferences.makePreferenceTransformer(
            inputs: inputs.preferences,
            key: PlatformItemList.Key.self,
            transform: Attribute(NamedResolvedRule(context: context))
        )
    }

    private struct NamedResolvedRule: Rule, AsyncAttribute {
        @Attribute var context: PlatformNamedImageRepresentableContext

        var value: (inout PlatformItemList) -> Void {
            let resolutionContext = ImageResolutionContext(environment: context.environment)
            let namedResolvedImage = context.image.resolveNamedImage(in: resolutionContext)
            return { list in
                list.modify { item in
                    if item.resolvedImage != nil {
                        item.namedResolvedImage = namedResolvedImage
                    }
                }
            }
        }
    }
}

// MARK: - PlatformItemListImageRepresentable

struct PlatformItemListImageRepresentable: PlatformImageRepresentable {
    static func shouldMakeRepresentation(inputs: _ViewInputs) -> Bool {
        inputs.preferences.requiresPlatformItemList
            && inputs.platformItemListFlags.contains(._1)
    }

    static func makeRepresentation(
        inputs: _ViewInputs,
        context: Attribute<PlatformImageRepresentableContext>,
        outputs: inout _ViewOutputs
    ) {
        outputs.preferences.writePlatformItemList(
            inputs: inputs.preferences,
            value: Attribute(PlatformRepresentation(context: context))
        )
    }

    private struct PlatformRepresentation: Rule, AsyncAttribute {
        @Attribute var context: PlatformImageRepresentableContext

        var value: PlatformItemList {
            PlatformItemList(
                items: [
                    .init(
                        image: context.image,
                        tint: context.tintColor,
                        imageColorResolver: context.foregroundStyle.map {
                            .init(shapeStyle: $0)
                        }
                    )
                ]
            )
        }
    }
}

// MARK: - PlatformItemListTextRepresentable

struct PlatformItemListTextRepresentable: PlatformTextRepresentable {
    static func shouldMakeRepresentation(inputs: _ViewInputs) -> Bool {
        inputs.preferences.requiresPlatformItemList
            && inputs.platformItemListFlags.contains(.text)
    }

    static func representationOptions(inputs: _ViewInputs) -> PlatformTextRepresentationOptions {
        inputs.includesStyledText ? .includeStyledText : []
    }

    static func makeRepresentation(
        inputs: _ViewInputs,
        context: Attribute<PlatformTextRepresentableContext>,
        outputs: inout _ViewOutputs
    ) {
        outputs.preferences.writePlatformItemList(
            inputs: inputs.preferences,
            value: Attribute(PlatformRepresentation(context: context))
        )
    }

    private struct PlatformRepresentation: Rule, AsyncAttribute {
        @Attribute var context: PlatformTextRepresentableContext

        var value: PlatformItemList {
            PlatformItemList(
                items: [
                    .init(
                        text: context.text
                    )
                ]
            )
        }
    }
}
