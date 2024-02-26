//
//  DestroyableBox.swift
//  OpenSwiftUI
//
//  Audited for RELEASE_2021
//  Status: Complete

@propertyWrapper
class DestroyableBox<A: Destroyable> {
    var wrappedValue: A

    init(wrappedValue: A) {
        self.wrappedValue = wrappedValue
    }
}
