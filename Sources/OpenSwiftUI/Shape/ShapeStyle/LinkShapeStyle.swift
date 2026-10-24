//
//  LinkShapeStyle.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete

public import OpenSwiftUICore

// MARK: - ShapeStyle + LinkShapeStyle

@available(OpenSwiftUI_v5_0, *)
extension ShapeStyle where Self == LinkShapeStyle {
    /// A style for links.
    @_alwaysEmitIntoClient
    public static var link: LinkShapeStyle {
        .init()
    }
}

// MARK: - LinkShapeStyle

/// A style for links.
@available(OpenSwiftUI_v5_0, *)
@frozen
public struct LinkShapeStyle: ShapeStyle {
    public init() {
        _openSwiftUIEmptyStub()
    }

    public func _apply(to shape: inout _ShapeStyle_Shape) {
        #if os(macOS)
        AppearanceCatalogShapeStyle(catalogName: "linkColor")._apply(to: &shape)
        #else
        let isDark = shape.environment.colorScheme == .dark
        Color(
            .sRGB,
            red: isDark ? 9 / 255 : 0,
            green: isDark ? 132 / 255 : 122 / 255,
            blue: 1
        )._apply(to: &shape)
        #endif
    }

    public typealias Resolved = Never
}
