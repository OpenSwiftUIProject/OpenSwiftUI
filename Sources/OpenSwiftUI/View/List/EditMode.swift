//
//  EditMode.swift
//  OpenSwiftUICore
//
//  Audited for iOS 18.0
//  Status: Complete
//  ID: D7D98064D8079914AC08939D4AA110C8 (SwiftUI)

public import OpenSwiftUICore
import OpenGraphShims

// MARK: - EditMode

/// A mode that indicates whether the user can edit a view's content.
///
/// You receive an optional binding to the edit mode state when you
/// read the ``EnvironmentValues/editMode`` environment value. The binding
/// contains an `EditMode` value that indicates whether edit mode is active,
/// and that you can use to change the mode. To learn how to read an environment
/// value, see ``EnvironmentValues``.
///
/// Certain built-in views automatically alter their appearance and behavior
/// in edit mode. For example, a ``List`` with a ``ForEach`` that's
/// configured with the ``DynamicViewContent/onDelete(perform:)`` or
/// ``DynamicViewContent/onMove(perform:)`` modifier provides controls to
/// delete or move list items while in edit mode. On devices without an attached
/// keyboard and mouse or trackpad, people can make multiple selections in lists
/// only when edit mode is active.
///
/// You can also customize your own views to react to edit mode.
/// The following example replaces a read-only ``Text`` view with
/// an editable ``TextField``, checking for edit mode by
/// testing the wrapped value's ``EditMode/isEditing`` property:
///
///     @Environment(\.editMode) private var editMode
///     @State private var name = "Maria Ruiz"
///
///     var body: some View {
///         Form {
///             if editMode?.wrappedValue.isEditing == true {
///                 TextField("Name", text: $name)
///             } else {
///                 Text(name)
///             }
///         }
///         .animation(nil, value: editMode?.wrappedValue)
///         .toolbar { // Assumes embedding this view in a NavigationView.
///             EditButton()
///         }
///     }
///
/// You can set the edit mode through the binding, or you can
/// rely on an ``EditButton`` to do that for you, as the example above
/// demonstrates. The button activates edit mode when the user
/// taps it, and disables the mode when the user taps again.
@available(macOS, unavailable)
@available(watchOS, unavailable)
public enum EditMode: Sendable {

    /// The user can't edit the view content.
    ///
    /// The ``isEditing`` property is `false` in this state.
    case inactive

    /// The view is in a temporary edit mode.
    ///
    /// The use of this state varies by platform and for different
    /// controls. As an example, OpenSwiftUI might engage temporary edit mode
    /// over the duration of a swipe gesture.
    ///
    /// The ``isEditing`` property is `true` in this state.
    case transient

    /// The user can edit the view content.
    ///
    /// The ``isEditing`` property is `true` in this state.
    case active

    /// Indicates whether a view is being edited.
    ///
    /// This property returns `true` if the mode is something other than
    /// inactive.
    public var isEditing: Bool { self != .inactive }
}

// MARK: - EditModeKey

@available(macOS, unavailable)
@available(watchOS, unavailable)
private struct EditModeKey: EnvironmentKey {
    static var defaultValue: Binding<EditMode>? { .constant(.inactive) }
}

extension EnvironmentValues {
    @available(macOS, unavailable)
    @available(watchOS, unavailable)
    public var editMode: Binding<EditMode>? {
        get { self[EditModeKey.self] }
        set { self[EditModeKey.self] = newValue }
    }
}

// MARK: - EditModeScopeModifier

@available(macOS, unavailable)
@available(watchOS, unavailable)
struct EditModeScopeModifier: ViewModifier {
    var isActive: Bool
    
    @State private var editMode: EditMode = .inactive
    
    func body(content: Content) -> some View {
        content.modifier(
            TransformModifier(isActive: isActive, editMode: $editMode)
        )
    }
    
    private struct TransformModifier: EnvironmentModifier, PrimitiveViewModifier {
        var isActive: Bool
        var editMode: Binding<EditMode>
        
        static func makeEnvironment(modifier: Attribute<Self>, environment: inout EnvironmentValues) {
            let value = modifier.value
            guard value.isActive else {
                return
            }
            environment.editMode = value.editMode
        }
    }
}
