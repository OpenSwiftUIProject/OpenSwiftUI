//
//  ButtonRole.swift
//  OpenSwiftUI
//
//  Audited for 3.5.2
//  Status: Empty
import Foundation

/// Mark: - Button

/// A control that initiates an action.
/// 
/// ## Overview
/// 
/// You can create a button by providing an action and a label. The aciton is either a method or closure that does something when a user 
/// clicks or taps the button. The label is a view that describes the button's action -- for example, by showing text, an icon or both.
/// 
/// The label of a button can be any kind of view, such as Text view for text-only tables
nonisolated
public struct Button<ButtonLabel> where ButtonLabel: View {
    private init(action: @escaping () -> Void, label: ButtonLabel) {
        self.action = action;
        self.label = label;
    }

    public init(action: @escaping () -> Void, @ViewBuilder label: () -> ButtonLabel) {
        self.init(action: action, label: label())
    }

    public init(role: ButtonRole?, action: @escaping () -> Void, @ViewBuilder label: () -> ButtonLabel) {
        self.init(action: action, label: label())
        // TODO : update style.configuration role
    }

    public var body: some View { 
        HStack(
            alignment: .center,
        ){
            self.label
        }.onTapGesture {
           if !isEnabled {
             self.action()
           }
        }
    }

    /// The descriptor for the ``action`` triggered by the Button.
    var label: ButtonLabel;

    /// The ``action`` take whenever the button is interacted with.
    var action: () -> Void;

    /// The enabled or disabled state.
    @Environment(\.isEnabled)
    var isEnabled: Bool;

    /// The active ``ButtonStyle``
    @Environment(\.buttonStyle)
    var style: AnyButtonStyle;
}

extension Button where ButtonLabel == Image {
    init(_ image: Image, action: @escaping () -> Void) {
        self.init(action: action, label: image,);
    }
}

extension Button where ButtonLabel == Text {
    @preconcurrency
    nonisolated
    init(_ label: LocalizedStringResource, action: @escaping () -> Void) {
       self.init(action: action, label: Text(label));
    }

    @preconcurrency
    nonisolated
    init(_ label: LocalizedStringKey, action: @escaping () -> Void) {
        self.init(action: action, label: Text(label));
    }

    @preconcurrency
    nonisolated
    init<S>(_ label: S, action: @escaping () -> Void) where S:StringProtocol{
        self.init(action: action, label: Text(label));
    }
}

extension Button where ButtonLabel == Label<Text, Image> {
    @preconcurrency
    nonisolated
    init(_ title: LocalizedStringResource, image: ImageResource, action: @escaping () -> Void) {
        self.init(action: action, label: Label(title, image: image));
    }

    @preconcurrency
    nonisolated
    init(_ title: LocalizedStringKey, image: ImageResource, action: @escaping () -> Void) {
        self.init(action: action, label: Label(title, image: image))
    }

    @preconcurrency
    nonisolated
    init<S>(_ title: S, image: ImageResource, action: @escaping () -> Void) where S:StringProtocol {
        self.init(action: action, label: Label(title, image: image));
    }

    @preconcurrency
    nonisolated
    init<S>(_ title: S, systemImage: String, action: @escaping () -> Void) where S: StringProtocol {
        self.init(action: action, label: Label(title, image: systemImage));
    }
}

#Preview("Creating a button: text", body: {Button("Example Text Button"){}.body})
#Preview("Creating a button: icon", body: {Button(Image("add")){}.body})