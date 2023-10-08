//
//  _printChanges.swift
//  OpenSwiftUI
//
//  Created by Kyle on 2023/10/2.
//  Lastest Version: iOS 15.5
//  Status: WIP

extension View {
    public static func _printChanges() {
        printChangedBodyProperties(of: Self.self)
    }
}

extension ViewModifier {
    public static func _printChanges() {
        printChangedBodyProperties(of: Self.self)
    }
}

// WIP
func printChangedBodyProperties<A>(of: A.Type) {

}
