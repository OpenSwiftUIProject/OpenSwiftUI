//
//  DestroyableBox.swift
//  OpenSwiftUI
//
//  Created by Kyle on 2023/10/18.
//  Lastest Version: iOS 15.5
//  Status: Complete

@propertyWrapper
class DestroyableBox<A: Destroyable> {
    var wrappedValue: A

    init(wrappedValue: A) {
        self.wrappedValue = wrappedValue
    }
}
