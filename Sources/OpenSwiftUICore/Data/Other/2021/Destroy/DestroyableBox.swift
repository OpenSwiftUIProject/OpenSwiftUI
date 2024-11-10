//
//  DestroyableBox.swift
//  OpenSwiftUI
//
//  Audited for iOS 15.5
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
