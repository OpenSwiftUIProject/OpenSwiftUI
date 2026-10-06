//
//  ToolbarItemBridging.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: WIP

@_spi(Private)
import OpenSwiftUICore

// MARK: - View + Toolbar Item Bridging

extension View {
    func allowsToolbarItemBridging(options: ToolbarItemBridgingOptions) -> some View {
        modifier(
            AllowsToolbarItemBridgingModifier(options: options)
                .requiring(Semantics.AllowLabelToolbarItemBridging.self)
                .requiring(ToolbarStyleContext.self)
                .requiring(CreatesToolbarSafeAreaInsetPredicate.Inverted.self)
        )
    }
}

// MARK: - AllowsToolbarItemBridgingModifier

struct AllowsToolbarItemBridgingModifier: ViewModifier {
    var options: ToolbarItemBridgingOptions

    func body(content: Content) -> some View {
        content
            .transformPreference(ToolbarItemBridgingPreferenceKey.self) { value in
                if options.contains(.item) {
                    value.count += 1
                }
                value.containsLabel = value.containsLabel || options.contains(.label)
            }
            .modifier(IncludesStyledTextModifier())
    }
}

// MARK: - ToolbarItemBridgingPreferenceKey

struct ToolbarItemBridgingPreferenceKey: HostPreferenceKey {
    static var defaultValue: ToolbarItemBridgingConfiguration {
        .init(count: 0, containsLabel: false)
    }

    static func reduce(
        value: inout ToolbarItemBridgingConfiguration,
        nextValue: () -> ToolbarItemBridgingConfiguration
    ) {
        let next = nextValue()
        value.count += next.count
        value.containsLabel = value.containsLabel || next.containsLabel
    }
}

// MARK: - ToolbarItemBridgingOptions

struct ToolbarItemBridgingOptions: OptionSet {
    let rawValue: Int

    static let item = Self(rawValue: 1 << 0)

    static let label = Self(rawValue: 1 << 1)
}

// MARK: - ToolbarItemBridgingConfiguration

struct ToolbarItemBridgingConfiguration: Equatable {
    var count: Int
    var containsLabel: Bool
}
