//
//  DestroyableBox.swift
//  OpenSwiftUI
//
//  Audited for RELEASE_2021
//  Status: Complete

#if OPENSWIFTUI_RELEASE_2021

@propertyWrapper
class DestroyableBox<A: Destroyable> {
    var wrappedValue: A

    init(wrappedValue: A) {
        self.wrappedValue = wrappedValue
    }
}

#endif
