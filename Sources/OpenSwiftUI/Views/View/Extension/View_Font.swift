//
//  View_Font.swift
//  OpenSwiftUI
//
//  Created by Kyle on 2023/9/25.
//  Lastest Version: iOS 15.5
//  Status: Complete

extension View {
    @inlinable
    @inline(__always)
    public func font(_ font: Font?) -> some View {
        environment(\.font, font)
    }
}

@available(iOS 13.0, *)
extension View {
    @inline(__always)
    func defaultFont(_ font: Font?) -> some View {
        environment(\.defaultFont, font)
    }
}
