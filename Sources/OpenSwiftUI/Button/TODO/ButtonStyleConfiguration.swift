//
//  ButtonStyle.swift
//  OpenSwiftUI
//
//  Created by Kyle on 2023/9/21.
//  Lastest Version: iOS 15.5
//  Status: WIP

import Foundation

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public struct ButtonStyleConfiguration {
    public struct Label: View {
        public typealias Body = Never
        
        public var body: Never {
            fatalError()
        }
    }

    @available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
    public let role: ButtonRole?
    
    public let label: ButtonStyleConfiguration.Label
    public let isPressed: Bool
}
