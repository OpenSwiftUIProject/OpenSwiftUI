//
//  TappablePadding.swift
//  OpenSwiftUIExtension

import Foundation

// FIXME: import OpenSwiftUI
#if canImport(SwiftUI)
import SwiftUI

struct TappablePadding: ViewModifier {
    let edges: Edge.Set
    let insets: EdgeInsets?
    
    let perform: () -> Void
    
    init(edges: Edge.Set = .all, insets: EdgeInsets?, perform: @escaping () -> Void) {
        self.edges = edges
        self.insets = insets
        self.perform = perform
    }
    
    private var insetsValue: EdgeInsets {
        EdgeInsets(
            top: edges.contains(.top) ? insets?.top ?? .zero : .zero,
            leading: edges.contains(.leading) ? insets?.leading ?? .zero : .zero,
            bottom: edges.contains(.bottom) ? insets?.bottom ?? .zero : .zero,
            trailing: edges.contains(.trailing) ? insets?.trailing ?? .zero : .zero
        )
    }

    func body(content: Content) -> some View {
        content
             .padding(insetsValue)
             .contentShape(Rectangle())
             .onTapGesture(perform: perform)
             .padding(insetsValue.inverted)
    }
}

extension EdgeInsets {
    var inverted: EdgeInsets {
        .init(top: -top, leading: -leading, bottom: -bottom, trailing: -trailing)
    }
    
    init(_all all: CGFloat) {
        self.init(top: all, leading: all, bottom: all, trailing: all)
    }
}

extension View {
    public func tappablePadding(
        _ insets: EdgeInsets,
        perform: @escaping () -> Void
    ) -> some View {
        modifier(TappablePadding(insets: insets, perform: perform))
    }
    
    public func tappablePadding(
        _ edges: Edge.Set = .all,
        _ length: CGFloat?,
        perform: @escaping () -> Void
    ) -> some View {
        let insets = length.map { EdgeInsets(_all: $0) }
        return modifier(TappablePadding(edges: edges, insets: insets, perform: perform))
    }
    
    public func tappablePadding(
        _ length: CGFloat,
        perform: @escaping () -> Void
    ) -> some View {
        tappablePadding(.all, length, perform: perform)
    }
}

@available(iOS 15, macOS 12, *)
#Preview {
    HStack(spacing: 20) {
        Text("Test 1")
            .background { Color.yellow }
            .padding(EdgeInsets())
            .tappablePadding(.all, 20.0) {
                print("Test 1")
            }
        Text("Test 2")
            .background { Color.red }
            .onTapGesture {
                print("Test 2")
            }
    }
    .padding(20)
    .background { Color.blue }
}
#endif
