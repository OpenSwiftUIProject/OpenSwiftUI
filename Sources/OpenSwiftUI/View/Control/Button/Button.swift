//
//  ButtonRole.swift
//  OpenSwiftUI
//
//  Audited for 3.5.2
//  Status: Empty

public struct Button<Label>: View where Label: View {
    public init(action: @escaping () -> Void, @ViewBuilder label: () -> Label) {

    }

    public var body: some View { EmptyView() }
}
