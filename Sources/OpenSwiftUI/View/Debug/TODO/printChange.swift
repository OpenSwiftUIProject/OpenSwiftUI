//
//  printChanges.swift
//  OpenSwiftUI
//
//  Audited for RELEASE_2021
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
