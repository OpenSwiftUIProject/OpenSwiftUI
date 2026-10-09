//
//  PlatformItemList.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: WIP
//  ID: CE84B1BFBEAEAB6361605407E54625A3 (SwiftUI)

import Foundation
#if os(macOS)
import AppKit
#endif
import OpenAttributeGraphShims
@_spi(ForOpenSwiftUIOnly)
@_spi(Private)
import OpenSwiftUICore

extension View {
    func platformItemLabel<Label, Flags>(_ label: Label, flags: Flags) -> some View where Label: View, Flags: PlatformItemListFlags {
        PlatformItemLabelView(flags: flags, label: label, content: self)
    }

    func transformPlatformItemList<Flags>(
        _ flags: Flags.Type,
        _ transform: @escaping (inout PlatformItemList) -> Void
    ) -> some View where Flags: PlatformItemListFlags {
        modifier(PlatformItemListTransformModifier<Flags>(transform: transform))
    }
}

// MARK: - PlatformItemLabelView [WIP]

private struct PlatformItemLabelView<Flags, Label, Content>: View where Flags: PlatformItemListFlags, Label: View, Content: View {
    var flags: Flags

    var label: Label

    var content: Content

    var body: some View {
        content
    }
}

// MARK: - PlatformItemListTransformModifier

struct PlatformItemListTransformModifier<Flags>: PrimitiveViewModifier, MultiViewModifier where Flags: PlatformItemListFlags {
    var transform: (inout PlatformItemList) -> Void

    nonisolated static func _makeView(
        modifier: _GraphValue<Self>,
        inputs: _ViewInputs,
        body: @escaping (_Graph, _ViewInputs) -> _ViewOutputs
    ) -> _ViewOutputs {
        var outputs = body(_Graph(), inputs)
        if inputs.platformItemListFlags.contains(Flags.flags),
           inputs.preferences.requiresPlatformItemList {
            outputs.preferences.platformItemList = Attribute(
                Transform(
                    modifier: modifier.value,
                    list: .init(outputs.preferences.platformItemList)
                )
            )
        }
        return outputs
    }

    private struct Transform: Rule {
        @Attribute var modifier: PlatformItemListTransformModifier
        @OptionalAttribute var list: PlatformItemList?

        var value: PlatformItemList {
            var list = list ?? .init(items: [])
            modifier.transform(&list)
            return list
        }
    }
}

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
        var keyboardShortcut: KeyboardShortcut?
        var onHover: ((Bool) -> ())?
        var buttonRole: ButtonRole?
        var accessibility: Accessibility?
        var secondaryNavigationBehavior: SecondaryNavigationBehavior?
        var label: NSAttributedString?
        var tooltip: String?
        var badge: String?
        var children: PlatformItemList?
        var labelGroupChildren: PlatformItemList?
        var menuIndicatorVisibility: Visibility?
        var controlSize: ControlSize?
        var toggleState: ToggleState?
        var commandOperation: CommandOperation?
        var scaleDownMenuImage: Bool = false
        var keepsMenuPresented: Bool = false
        var isPopUpButton: Bool?
        // var menuOrder: MenuOrder = .automatic
        var tint: Color?

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

        struct SelectionBehavior {
            var isMomentary: Bool = true
            var isContainerSelection: Bool = false
            var yieldsToContainerSelection: Bool = false
            var isPickerOption: Bool = false
            var visualStyle: VisualStyle = .plain
            var onSelect: (() -> Void)?
            var onDeselect: (() -> Void)?
            #if os(macOS)
            var onActivate: ((NSEvent?) -> Bool)?
            #else
            var onActivate: ((Void?) -> Bool)?
            #endif
            #if canImport(ObjectiveC)
            var platformSelector: Selector?
            #endif
            var springLoadingBehavior: SpringLoadingBehavior = .automatic

            enum VisualStyle: Hashable {
                case plain
                case checkmark
                case selected
            }
        }

        struct SecondaryNavigationBehavior {}

        struct Accessibility {
            var properties: AccessibilityProperties
            var environment: EnvironmentValues
        }

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
        items.first ?? Item()
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

extension _ViewOutputs {
    mutating func transformPlatformItemList(
        inputs: _ViewInputs,
        transform: @autoclosure () -> Attribute<(inout PlatformItemList) -> Void>
    ) {
        preferences.makePreferenceTransformer(
            inputs: inputs.preferences,
            key: PlatformItemList.Key.self,
            transform: transform()
        )
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

// MARK: - PlatformItemListViewThatFitsRepresentable

struct PlatformItemListViewThatFitsRepresentable: PlatformViewThatFitsRepresentable {
    static func shouldMakeRepresentation(inputs: _ViewInputs) -> Bool {
        inputs.preferences.requiresPlatformItemList
            && inputs.platformItemListFlags.contains(.viewThatFits)
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
            { list in
                list.items = []
                var children = PlatformItemList(items: [])
                state.applyChildren(selectLast: false) { outputs, _ in
                    if let childList = outputs.preferences.platformItemList {
                        children.items.append(childList.value.mergedContentItem)
                    }
                    return false
                }
                var item = PlatformItemList.Item()
                item.children = children
                list.items = [item]
            }
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
            && inputs.platformItemListFlags.contains(.namedImage)
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
            && inputs.platformItemListFlags.contains(.image)
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

// MARK: - IsPlatformItemListSourceInput

struct IsPlatformItemListSourceInput: ViewInput {
    static var defaultValue: Bool { false }
}
