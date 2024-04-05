//
//  ViewVisitor.swift
//  OpenSwiftUI
//
//  Audited for RELEASE_2021
//  Status: Complete

protocol ViewVisitor {
    func visit<V: View>(_ view: V)
}

protocol ViewTypeVisitor {
    func visit<V: View>(type: V.Type)
}
