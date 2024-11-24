//
//  AccessibilityConfigurationModifier.swift
//  OpenSwiftUI
//
//  Audited for iOS 15.5
//  Status: Complete

protocol AccessibilityConfigurationModifier {
    associatedtype Configuration = Never
    associatedtype Body
    associatedtype Content

    var configuration: Configuration { get }
    func body(content: Self.Content) -> Self.Body
}

extension AccessibilityConfigurationModifier where Configuration == Never {
    var configuration: Configuration { preconditionFailure("") }
}
