//
//  WeakBox.swift
//  OpenSwiftUI
//
//  Audited for RELEASE_2021
//  Status: Complete

struct WeakBox<A: AnyObject> {
    weak var base: A?
}
