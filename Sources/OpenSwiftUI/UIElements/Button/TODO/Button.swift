//
//  ButtonRole.swift
//  OpenSwiftUI
//
//  Created by Kyle on 2023/9/22.
//  Lastest Version: iOS 15.5
//  Status: Empty

public struct Button<Label>: View where Label: View {
    public init(action: @escaping () -> Void, @ViewBuilder label: () -> Label) {

    }

    public var body: some View { EmptyView() }
}
