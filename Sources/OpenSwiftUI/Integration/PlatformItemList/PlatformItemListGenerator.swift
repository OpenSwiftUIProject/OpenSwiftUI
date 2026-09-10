//
//  PlatformItemListGenerator.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: 4CA94EFFBA1A33DEA2B0583B3783C90F (SwiftUI)

import OpenAttributeGraphShims
@_spi(ForOpenSwiftUIOnly)
import OpenSwiftUICore

// MARK: - PlatformItemListGenerator

struct PlatformItemListGenerator<Flags, Content>: StatefulRule where Flags: PlatformItemListFlags, Content: View {
    var subgraph: Subgraph
    @Attribute var content: Content
    let inputs: _ViewInputs
    let inputsIncludeGeometry: Bool
    @OptionalAttribute var itemList: PlatformItemList?

    init(
        flags: Flags.Type,
        content: Attribute<Content>,
        inputs: _ViewInputs,
        inputsIncludeGeometry: Bool
    ) {
        self.subgraph = Subgraph.current!
        self._content = content
        self.inputs = inputs
        self.inputsIncludeGeometry = inputsIncludeGeometry
        self._itemList = OptionalAttribute()
    }

    typealias Value = PlatformItemList

    mutating func updateValue() {
        if !hasValue {
            _itemList = subgraph.apply {
                makeItemList()
            }
        }
        value = itemList ?? PlatformItemList(items: [])
    }

    private func makeItemList() -> OptionalAttribute<PlatformItemList> {
        let flags = Flags.flags
        var newInputs = inputs
        if inputsIncludeGeometry {
            newInputs = newInputs.withoutGeometryDependencies
            newInputs.preferences = PreferencesInputs(
                hostKeys: inputs.intern(PreferenceKeys(), id: .defaultValue)
            )
        }
        newInputs.addPlatformItemListKey(flags: Flags.self, editOperation: .replace)
        newInputs[IsPlatformItemListSourceInput.self] = true
        if flags.contains(.accessibility),
           inputs.preferences.contains(AccessibilityNodesKey.self) {
            newInputs.preferences.add(AccessibilityAttachment.Key.self)
        }
        let outputs = Content._makeView(view: _GraphValue($content), inputs: newInputs)
        return OptionalAttribute(outputs.preferences.platformItemList)
    }
}

extension PlatformItemListGenerator where Flags == AllPlatformItemListFlags {
    init(
        content: Attribute<Content>,
        inputs: _ViewInputs,
        inputsIncludeGeometry: Bool
    ) {
        self.init(
            flags: AllPlatformItemListFlags.self,
            content: content,
            inputs: inputs,
            inputsIncludeGeometry: inputsIncludeGeometry
        )
    }
}
