//
//  ViewVisitor.swift
//  OpenSwiftUI
//
//  Audited for iOS 15.5
//  Status: Complete

package protocol ViewVisitor {
    mutating func visit<V: View>(_ view: V)
}

package protocol ViewTypeVisitor {
    mutating func visit<V: View>(type: V.Type)
}
