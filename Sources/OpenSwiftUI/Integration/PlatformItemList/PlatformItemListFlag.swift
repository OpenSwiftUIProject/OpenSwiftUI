//
//  PlatformItemListFlag.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete

@_spi(ForOpenSwiftUIOnly)
import OpenSwiftUICore

// MARK: - PlatformItemListFlagsSet

struct PlatformItemListFlagsSet: OptionSet, Hashable {
    var rawValue: UInt32

    init(rawValue: UInt32) {
        self.rawValue = rawValue
    }

    static var selection: PlatformItemListFlagsSet { .init(rawValue: 1 << 0) }

    static var image: PlatformItemListFlagsSet { .init(rawValue: 1 << 1) }

    static var text: PlatformItemListFlagsSet { .init(rawValue: 1 << 2) }

    static var layout: PlatformItemListFlagsSet { .init(rawValue: 1 << 3) }

    // FIXME: Infer the semantic name from a concrete consumer.
    static var _4: PlatformItemListFlagsSet { .init(rawValue: 1 << 4) }

    static var namedImage: PlatformItemListFlagsSet { .init(rawValue: 1 << 5) }

    static var viewThatFits: PlatformItemListFlagsSet { .init(rawValue: 1 << 6) }

    static var action: PlatformItemListFlagsSet { [.selection, .text, .layout] }

    static var label: PlatformItemListFlagsSet { [.image, .text, ._4] }

    static var toolbar: PlatformItemListFlagsSet { .label }

    static var searchToken: PlatformItemListFlagsSet { [.selection, .image, .text, .layout] }

    static var widgetMetadata: PlatformItemListFlagsSet { [.image, .text, ._4, .namedImage, .viewThatFits] }

    static var all: PlatformItemListFlagsSet { .init(rawValue: .max) }

    enum EditOperation {
        case replace
        case formUnion
    }
}

// MARK: - PlatformItemListFlags

protocol PlatformItemListFlags {
    static var flags: PlatformItemListFlagsSet { get }
}

struct SelectionPlatformItemListFlags: PlatformItemListFlags {
    static var flags: PlatformItemListFlagsSet { .selection }
}

struct AllPlatformItemListFlags: PlatformItemListFlags {
    static var flags: PlatformItemListFlagsSet { .all }
}

struct TextPlatformItemListFlags: PlatformItemListFlags {
    static var flags: PlatformItemListFlagsSet { .text }
}

struct LayoutPlatformItemListFlags: PlatformItemListFlags {
    static var flags: PlatformItemListFlagsSet { .layout }
}

struct ActionPlatformItemListFlags: PlatformItemListFlags {
    static var flags: PlatformItemListFlagsSet { .action }
}

struct LabelPlatformItemListFlags: PlatformItemListFlags {
    static var flags: PlatformItemListFlagsSet { .label }
}

struct ToolbarPlatformItemListFlags: PlatformItemListFlags {
    static var flags: PlatformItemListFlagsSet { .toolbar }
}

struct SearchTokenPlatformItemListFlags: PlatformItemListFlags {
    static var flags: PlatformItemListFlagsSet { .searchToken }
}

struct WidgetMetadataPlatformItemListFlags: PlatformItemListFlags {
    static var flags: PlatformItemListFlagsSet { .widgetMetadata }
}

// MARK: - PlatformItemListFlagsInput

struct PlatformItemListFlagsInput: ViewInput {
    static var defaultValue: PlatformItemListFlagsSet { .all }
}

extension _ViewInputs {
    var platformItemListFlags: PlatformItemListFlagsSet {
        get { self[PlatformItemListFlagsInput.self] }
        set { self[PlatformItemListFlagsInput.self] = newValue }
    }
}
