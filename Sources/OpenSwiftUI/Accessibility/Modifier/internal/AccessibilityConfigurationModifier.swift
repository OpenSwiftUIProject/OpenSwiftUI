//
//  AccessibilityConfigurationModifier.swift
//  OpenSwiftUI
//
//  Created by Kyle on 2023/10/9.
//  Lastest Version: iOS 15.5
//  Status: Complete

protocol AccessibilityConfigurationModifier {
    associatedtype Configuration = Never
    associatedtype Body
    associatedtype Content

    var configuration: Configuration { get }
    func body(content: Self.Content) -> Self.Body
}

extension AccessibilityConfigurationModifier where Configuration == Never {
    var configuration: Configuration { fatalError() }
}
