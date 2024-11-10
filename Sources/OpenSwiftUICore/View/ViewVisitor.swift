//
//  ViewVisitor.swift
//  OpenSwiftUI
//
//  Audited for iOS 15.5
//  Status: Complete

protocol ViewVisitor {
    mutating func visit<V: View>(_ view: V)
}

protocol ViewTypeVisitor {
    mutating func visit<V: View>(type: V.Type)
}
