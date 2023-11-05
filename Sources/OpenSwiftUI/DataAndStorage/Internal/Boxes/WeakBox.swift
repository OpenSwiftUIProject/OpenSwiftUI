//
//  WeakBox.swift
//  OpenSwiftUI
//
//  Created by Kyle on 2023/10/17.
//  Lastest Version: iOS 15.5
//  Status: Complete

struct WeakBox<A: AnyObject> {
    weak var base: A?
}
