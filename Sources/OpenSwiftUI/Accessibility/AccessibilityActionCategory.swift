//
//  AccessibilityActionCategory.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete

public import OpenSwiftUICore

// MARK: - AccessibilityActionCategory

/// Designates an accessibility action category that is provided and named
/// by the system.
@available(OpenSwiftUI_v6_0, *)
public struct AccessibilityActionCategory: Equatable, Sendable {
    enum Category: Equatable, Sendable {
        case named(Text)
        case `default`
        case edit
    }

    let category: Category

    /// An accessibility action category for the default actions of a view.
    /// This category replaces the system provided actions rotor
    /// for accessibility technologies like VoiceOver.
    public static let `default` = AccessibilityActionCategory(category: .default)

    /// An accessibility action category for associating actions related to
    /// editing text. This category replaces the system provided Edit actions
    /// for accessibility technologies like VoiceOver.
    public static let edit = AccessibilityActionCategory(category: .edit)

    /// Creates a custom action category labeled by `name`.
    ///
    ///     extension AccessibilityActionCategory {
    ///         static let table = AccessibilityActionCategory("Table Options")
    ///     }
    ///
    ///     var body: some View {
    ///         TableCellView()
    ///              .accessibilityActions(category: .table) {
    ///                  ForEach(tableCellActions) { action in
    ///                      Button(action.title) {
    ///                          action()
    ///                      }
    ///                  }
    ///              }
    ///     }
    ///
    /// - Parameter:
    ///   - name: The name for the category of the accessibility actions.
    public init(_ name: Text) {
        category = .named(name)
    }

    /// Creates a custom action category labeled by `nameKey`.
    ///
    ///     extension AccessibilityActionCategory {
    ///         static let table = AccessibilityActionCategory("Table Options")
    ///     }
    ///
    ///     var body: some View {
    ///         TableCellView()
    ///              .accessibilityActions(category: .table) {
    ///                  ForEach(tableCellActions) { action in
    ///                      Button(action.title) {
    ///                          action()
    ///                      }
    ///                  }
    ///              }
    ///     }
    ///
    /// - Parameter:
    ///   - nameKey: The name for the category of the accessibility actions.
    public init(_ nameKey: LocalizedStringKey) {
        self.init(Text(nameKey))
    }

    /// Creates a custom action category labeled by `name`.
    ///
    ///     extension AccessibilityActionCategory {
    ///         static let table = AccessibilityActionCategory("Table Options")
    ///     }
    ///
    ///     var body: some View {
    ///         TableCellView()
    ///              .accessibilityActions(category: .table) {
    ///                  ForEach(tableCellActions) { action in
    ///                      Button(action.title) {
    ///                          action()
    ///                      }
    ///                  }
    ///              }
    ///     }
    ///
    /// - Parameter:
    ///   - name: The name for the category of the accessibility actions.
    @_disfavoredOverload
    public init(_ name: some StringProtocol) {
        self.init(Text(name))
    }
}

// MARK: - View + AccessibilityActionCategory

@available(OpenSwiftUI_v6_0, *)
extension View {
    /// Adds multiple accessibility actions to the view with a specific
    /// category. Actions allow assistive technologies, such as VoiceOver,
    /// to interact with the view by invoking the action and are grouped by
    /// their category. When multiple action modifiers with an equal category
    /// are applied to the view, the actions are combined together.
    ///
    ///     var body: some View {
    ///         EditorView()
    ///              .accessibilityActions(category: .edit) {
    ///                  ForEach(editActions) { action in
    ///                      Button(action.title) {
    ///                          action()
    ///                      }
    ///                  }
    ///                  if hasTextSuggestions {
    ///                      Button("Show Text Suggestions") {
    ///                          presentTextSuggestions()
    ///                      }
    ///                  }
    ///              }
    ///     }
    ///
    /// - Parameters:
    ///   - category: The category the accessibility actions are grouped by.
    ///   - content: The accessibility actions added to the view.
    nonisolated public func accessibilityActions<Content>(
        category: AccessibilityActionCategory,
        @ViewBuilder _ content: () -> Content
    ) -> some View where Content: View {
        accessibilityAttachment(content: content()) { tree in
            var attachment = AccessibilityAttachment()
            if let properties = tree.attachment?.mergedProperties {
                attachment.properties[AccessibilityProperties.ActionsKey.self] =
                    properties[AccessibilityProperties.ActionsKey.self].map {
                        $0.asCustomAction(category: category) ?? $0
                    }
            }
            tree = .leaf(attachment)
        }
    }
}
