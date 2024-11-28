//
//  SwiftUI.Color.swift
//  OpenSwiftUIBridge

#if canImport(SwiftUI)
public import SwiftUI
public import OpenSwiftUI

// MARK: Color + Bridgeable

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension SwiftUI.Color: Bridgeable {
    public typealias Counterpart = OpenSwiftUI.Color
    
    public init(_ counterpart: Counterpart) {
        self.init(OpenSwiftUIColor2SwiftUIColorAdapter(base: counterpart))
    }
}

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension OpenSwiftUI.Color: Bridgeable {
    public typealias Counterpart = SwiftUI.Color
    
    public init(_ counterpart: Counterpart) {
        self.init(SwiftUIColor2OpenSwiftUIColorAdapter(base: counterpart))
    }
}

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
private struct OpenSwiftUIColor2SwiftUIColorAdapter: Hashable, SwiftUI.ShapeStyle {
    private let base: OpenSwiftUI.Color

    init(base: OpenSwiftUI.Color) {
        self.base = base
    }
    
    public typealias Resolved = SwiftUI.Color.Resolved
    
    public func resolve(in environment: SwiftUI.EnvironmentValues) -> SwiftUI.Color.Resolved {
        .init(base.resolve(in: .init(environment)))
    }
}

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
private struct SwiftUIColor2OpenSwiftUIColorAdapter: Hashable, OpenSwiftUI.ShapeStyle {
    private let base: SwiftUI.Color

    init(base: SwiftUI.Color) {
        self.base = base
    }
    
    public typealias Resolved = OpenSwiftUI.Color.Resolved
    
    public func resolve(in environment: OpenSwiftUI.EnvironmentValues) -> OpenSwiftUI.Color.Resolved {
        .init(base.resolve(in: .init(environment)))
    }
}

// MARK: - Color.Resolved + Bridgeable

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension SwiftUI.Color.Resolved: Bridgeable {
    public typealias Counterpart = OpenSwiftUI.Color.Resolved
    
    public init(_ counterpart: Counterpart) {
        self.init(colorSpace: .sRGBLinear, red: counterpart.linearRed, green: counterpart.linearGreen, blue: counterpart.linearBlue)
    }
}

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension OpenSwiftUI.Color.Resolved: Bridgeable {
    public typealias Counterpart = SwiftUI.Color.Resolved
    
    public init(_ counterpart: Counterpart) {
        self.init(colorSpace: .sRGBLinear, red: counterpart.linearRed, green: counterpart.linearGreen, blue: counterpart.linearBlue)
    }
}
#endif
