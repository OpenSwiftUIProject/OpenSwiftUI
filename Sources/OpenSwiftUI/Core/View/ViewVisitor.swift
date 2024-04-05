//
//  ViewVisitor.swift
//  OpenSwiftUI
//
//  Audited for RELEASE_2021
//  Status: Complete

protocol ViewVisitor {
    mutating func visit<V: View>(_ view: V)
}

protocol ViewTypeVisitor {
    mutating func visit<V: View>(type: V.Type)
}
