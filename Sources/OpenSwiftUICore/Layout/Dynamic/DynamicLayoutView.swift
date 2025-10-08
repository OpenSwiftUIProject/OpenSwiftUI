//
//  DynamicLayoutView.swift
//  OpenSwiftUICore
//
//  Status: WIP
//  ID: FF3C661D9D8317A1C8FE2B7FD4EDE12C (SwiftUICore)

import OpenAttributeGraphShims

// MARK: - DynamicLayoutComputer

private struct DynamicLayoutComputer<L>: StatefulRule, AsyncAttribute, CustomStringConvertible where L: Layout {
    @Attribute
    var layout: L

    @Attribute
    var environment: EnvironmentValues

    @OptionalAttribute
    var containerInfo: DynamicContainer.Info?

    var layoutMap: DynamicLayoutMap

    typealias Value = LayoutComputer

    mutating func updateValue() {
        updateLayoutComputer(
            layout: layout,
            environment: $environment,
            attributes: layoutMap.attributes(info: containerInfo!)
        )
    }

    var description: String {
        "\(L.self) → LayoutComputer"
    }
}
