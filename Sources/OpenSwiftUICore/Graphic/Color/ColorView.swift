//
//  ColorView.swift
//  OpenSwiftUICore
//
//  Audited for iOS 18.0
//  Empty

@MainActor
@preconcurrency
package struct ColorView: PrimitiveView { //FIXME
    package var color: Color.Resolved
    
    package init(_ color: Color.Resolved) {
        self.color = color
    }

    @available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 10.15, *)
    package typealias Body = Swift.Never
}
