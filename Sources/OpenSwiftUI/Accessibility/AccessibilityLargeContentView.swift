//
//  AccessibilityLargeContentView.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: WIP
//  ID: F0D6FE3E66D6447B1F7FC2D6B4BA3CAB (SwiftUI)

import OpenAttributeGraphShims
@_spi(ForOpenSwiftUIOnly)
@_spi(Private)
import OpenSwiftUICore
import Foundation

// MARK: - EnvironmentValues + accessibilityLargeContentViewerEnabled

extension EnvironmentValues {

    /// Whether the Large Content Viewer is enabled.
    ///
    /// The system can automatically provide a large content view
    /// with ``View/accessibilityShowsLargeContentViewer()``
    /// or you can provide your own with ``View/accessibilityShowsLargeContentViewer(_:)``.
    ///
    /// While it is not necessary to check this value before adding
    /// a large content view, it may be helpful if you need to
    /// adjust the behavior of a gesture. For example, a button with
    /// a long press handler might increase its long press duration
    /// so the user can read the text in the large content viewer first.
    @available(OpenSwiftUI_v3_0, *)
    public var accessibilityLargeContentViewerEnabled: Bool {
        self[AccessibilityLargeContentViewerKey.self]
    }

    @available(OpenSwiftUI_v3_0, *)
    public var _accessibilityLargeContentViewerEnabled: Bool {
        get { self[AccessibilityLargeContentViewerKey.self] }
        set { self[AccessibilityLargeContentViewerKey.self] = newValue }
    }
}

// MARK: - View + accessibilityLargeContentViewer [WIP]

extension View {

    /// Adds a custom large content view to be shown by
    /// the large content viewer.
    ///
    /// Rely on the large content viewer only in situations
    /// where items must remain small due to unavoidable
    /// design constraints. For example, buttons in a tab bar
    /// remain small to leave more room for the main app content.
    ///
    /// The following example shows how to add a custom large
    /// content view:
    ///
    ///     var body: some View {
    ///         Button(action: newMessage) {
    ///             Image(systemName: "plus")
    ///         }
    ///         .accessibilityShowsLargeContentViewer {
    ///             Label("New Message", systemImage: "plus")
    ///         }
    ///     }
    ///
    /// Don’t use the large content viewer as a replacement for proper
    /// Dynamic Type support. For example, Dynamic Type allows items
    /// in a list to grow or shrink vertically to accommodate the user’s preferred
    /// font size. Rely on the large content viewer only in situations where
    /// items must remain small due to unavoidable design constraints.
    ///
    /// For example, views that have their Dynamic Type size constrained
    /// with ``View/dynamicTypeSize(_:)`` may require a
    /// large content view.
    @available(OpenSwiftUI_v3_0, *)
    nonisolated public func accessibilityShowsLargeContentViewer<V>(
        @ViewBuilder _ largeContentView: () -> V
    ) -> some View where V: View {
        accessibilityShowsLargeContentViewer(
            .enabled,
            largeContentView: largeContentView
        )
    }

    /// Adds a default large content view to be shown by
    /// the large content viewer.
    ///
    /// Rely on the large content viewer only in situations
    /// where items must remain small due to unavoidable
    /// design constraints. For example, buttons in a tab bar
    /// remain small to leave more room for the main app content.
    ///
    /// The following example shows how to add a custom large
    /// content view:
    ///
    ///     var body: some View {
    ///         Button("New Message", action: newMessage)
    ///             .accessibilityShowsLargeContentViewer()
    ///     }
    ///
    /// Don’t use the large content viewer as a replacement for proper
    /// Dynamic Type support. For example, Dynamic Type allows items
    /// in a list to grow or shrink vertically to accommodate the user’s preferred
    /// font size. Rely on the large content viewer only in situations where
    /// items must remain small due to unavoidable design constraints.
    ///
    /// For example, views that have their Dynamic Type size constrained
    /// with ``View/dynamicTypeSize(_:)`` may require a
    /// large content view.
    @available(OpenSwiftUI_v3_0, *)
    nonisolated public func accessibilityShowsLargeContentViewer(
    ) -> some View {
        accessibilityShowsLargeContentViewer(.enabled)
    }

    nonisolated func accessibilityShowsLargeContentViewer(
        _ behavior: AccessibilityLargeContentViewBehavior
    ) -> some View {
        transformPreference(AccessibilityLargeContentViewTree.Key.self) { value in
            _openSwiftUIUnimplementedFailure()
        }
    }

    nonisolated func accessibilityShowsLargeContentViewer<V>(
        _ behavior: AccessibilityLargeContentViewBehavior,
        @ViewBuilder largeContentView: () -> V
    ) -> some View where V: View {
        modifier(
            AccessibilityLargeContentViewModifier(
                behavior: behavior,
                largeContentView: largeContentView()
            )
        )
    }
}

// MARK: - AccessibilityLargeContentViewTree

enum AccessibilityLargeContentViewTree: Equatable {
    case leaf(AccessibilityLargeContentViewItem)
    case branch([AccessibilityLargeContentViewTree])
    case empty

    func hitTest(at point: CGPoint) -> AccessibilityLargeContentViewItem? {
        switch self {
        case .leaf(let item):
            guard item.behavior == .enabled, item.frame.contains(point) else {
                return nil
            }
            return item
        case .branch(let children):
            for child in children {
                guard let result = child.hitTest(at: point) else {
                    continue
                }
                return result
            }
            return nil
        case .empty:
            return nil
        }
    }

    // MARK: - AccessibilityLargeContentViewTree.Key

    struct Key: HostPreferenceKey {
        static let defaultValue: AccessibilityLargeContentViewTree = .empty

        static func reduce(
            value: inout AccessibilityLargeContentViewTree,
            nextValue: () -> AccessibilityLargeContentViewTree
        ) {
            let newValue = nextValue()
            switch (value, newValue) {
            case (_, .empty):
                break
            case (.empty, _):
                value = newValue
            case (.branch(let oldArray), .branch(let newArray)):
                value = .branch(oldArray + newArray)
            case (.branch(let oldArray), _):
                value = .branch(oldArray + [newValue])
            case (_, .branch(let newArray)):
                value = .branch([value] + newArray)
            case (_, _):
                value = .branch([value, newValue])
            }
        }
    }
}

// MARK: - AccessibilityLargeContentViewItem

struct AccessibilityLargeContentViewItem: Equatable {
    var title: String?
    var image: Image.Resolved?
    var frame: CGRect
    var behavior: AccessibilityLargeContentViewBehavior
}

// MARK: - AccessibilityLargeContentViewModifier [WIP]

private struct AccessibilityLargeContentViewModifier<Content: View>: MultiViewModifier, PrimitiveViewModifier {
    var behavior: AccessibilityLargeContentViewBehavior
    var largeContentView: Content

    nonisolated static func _makeView(
        modifier: _GraphValue<Self>,
        inputs: _ViewInputs,
        body: @escaping (_Graph, _ViewInputs) -> _ViewOutputs
    ) -> _ViewOutputs {
        _openSwiftUIUnimplementedFailure()
    }
}

package struct AccessibilityLargeContentViewerKey: EnvironmentKey {
    package static var defaultValue: Bool { false }
}

// MARK: - AccessibilityLargeContentViewHitTestingTransform

private struct AccessibilityLargeContentViewHitTestingTransform: Rule {
    @Attribute var allowsHitTesting: Bool

    var value: (inout AccessibilityLargeContentViewTree) -> Void {
        {
            guard !allowsHitTesting else {
                return
            }
            $0 = .empty
        }
    }
}

// MARK: - AccessibilityLargeContentViewTransform

private struct AccessibilityLargeContentViewTransform: Rule {
    @Attribute var behavior: AccessibilityLargeContentViewBehavior
    @Attribute var platformItemList: PlatformItemList
    @Attribute var size: ViewSize
    @Attribute var position: CGPoint
    @Attribute var transform: ViewTransform

    var value: (inout AccessibilityLargeContentViewTree) -> Void {
        var viewTransform = transform
        viewTransform.appendPosition(position)
        var frame = CGRect(origin: .zero, size: size.value)
        frame.convert(to: .global, transform: viewTransform)
        let mergedContentItems = platformItemList.mergedContentItems
        let title = mergedContentItems.text?.string ?? mergedContentItems.label?.string
        let image = mergedContentItems.resolvedImage
        let behavior = behavior
        let item = AccessibilityLargeContentViewItem(
            title: title,
            image: image,
            frame: frame,
            behavior: behavior
        )
        return { tree in
            tree = .leaf(item)
        }
    }
}

// MARK: - AccessibilityLargeContentViewBehavior

enum AccessibilityLargeContentViewBehavior: UInt8, Hashable {
    case disabled
    case placeholder
    case enabled
}
