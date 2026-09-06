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
public struct Button<Label> where Label: View {

    public init(action: @escaping () -> Void, @ViewBuilder label: () -> Label) {
        self.label = label();
        self.action = action;
    }

    public init(role: ButtonRole?, action: @escaping () -> Void, @ViewBuilder label: () -> Label) {
        self.label = label()
        self.action = action;
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

    var label: Label;
    var action: () -> Void;

    @Environment(\.isEnabled)
    var isEnabled: Bool;

    @Environment(\.buttonStyle)
    var style: AnyButtonStyle;
}

extension Button where Label == Text {
    @preconcurrency
    nonisolated
    init(_ labelResource: LocalizedStringResource, action: @escaping () -> Void) {
        self.label = Text(labelResource);
        self.action = action;
    }

    @preconcurrency
    nonisolated
    init(_ labelKey: LocalizedStringKey, action: @escaping () -> Void) {
        self.label = Text(labelKey);
        self.action = action;
    }

    @preconcurrency
    nonisolated
    init<S>(_ label: S, action: @escaping () -> Void) where S:StringProtocol{
        self.action = action;
        self.label = Text(label)
    }
}



#Preview("Create a button: text", body: {Button("Example Text Button"){}.body})