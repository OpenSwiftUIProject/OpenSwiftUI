//
//  RootViewForSimplifiedApplicationProvider.swift
//  OpenSwiftUI
//
//  Status: Complete

import Foundation

protocol ClarityUIApplicationDelegate: PlatformApplicationDelegate {
    associatedtype Body: View

    var rootViewForSimplifiedApplication: Body { get }
}

protocol RootViewForSimplifiedApplicationProvider {
    associatedtype Body: View

    var rootViewForSimplifiedApplication: Body { get }
}
