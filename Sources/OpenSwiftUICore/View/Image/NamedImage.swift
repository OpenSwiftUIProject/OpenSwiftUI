//
//  NamedImage.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Empty
//  ID: BBFAAB6E2E9787715FB41E2179A3B661 (SwiftUICore)

public import OpenCoreGraphicsShims

extension Image {
    // FIXME
    package struct Resolved {
        package init(
            image: GraphicsImage,
            decorative: Bool,
            label: AccessibilityImageLabel? = nil,
            basePlatformItemImage: AnyObject? = nil,
            // backgroundShape: SymbolVariants.Shape? = nil,
            backgroundCornerRadius: CGFloat? = nil
        ) {

        }
    }

    package enum NamedResolved {}
}
