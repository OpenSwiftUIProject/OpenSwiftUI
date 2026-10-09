//
//  PlatformItemListButtonStyle.swift
//  OpenSwiftUI
//
//  Status: Stub

import OpenAttributeGraphShims
@_spi(ForOpenSwiftUIOnly)
import OpenSwiftUICore

// MARK: - PlatformItemListButtonStyle [TBA]

struct PlatformItemListButtonStyle: PrimitiveButtonStyle {
    // TODO: tint, displayMenuAsPalette, paletteSelectionEffect, menuActionDismissBehavior

    func makeBody(configuration: Configuration) -> some View {
        // TODO: OnPlatformContainerSelectionModifier, PlatformButtonActionModifier, menu metadata
        _openSwiftUIUnimplementedFailure()
    }
}

// MARK: - PlatformButtonActionTransform

struct PlatformButtonActionTransform: UnaryPlatformItemsModifier, PrimitiveViewModifier {
    var selection: PlatformItem.SelectionContent

    static var features: PlatformItem.Features { .selection }

    static func updateItem(modifier: Self, item: inout PlatformItem) {
        item.selection = modifier.selection
    }

    struct MakeTransform: Rule {
        @Attribute var selection: PlatformItem.SelectionContent

        var value: PlatformButtonActionTransform {
            PlatformButtonActionTransform(selection: selection)
        }
    }

    struct SelectionContent: Rule {
        @Attribute var action: (() -> Void)?
        @Attribute var isEnabled: Bool
        @Attribute var springLoadingBehavior: SpringLoadingBehavior

        var value: PlatformItem.SelectionContent {
            var options = isEnabled ? 1 : 0
            if springLoadingBehavior == .enabled {
                options |= 1 << 2
            }
            return PlatformItem.SelectionContent(
                onSelectAction: WeakAttribute($action),
                onDeselectAction: WeakAttribute(),
                options: .init(rawValue: options)
            )
        }
    }
}
