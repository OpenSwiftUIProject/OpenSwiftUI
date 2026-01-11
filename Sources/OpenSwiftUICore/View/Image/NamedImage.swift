//
//  NamedImage.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Empty
//  ID: BBFAAB6E2E9787715FB41E2179A3B661 (SwiftUICore)

public import OpenCoreGraphicsShims

extension Image {
    #if canImport(CoreGraphics)
    // FIXME
    public init(decorative: CGImage, scale: CGFloat, orientation: Image.Orientation) {
        _openSwiftUIUnimplementedFailure()
    }
    #endif

    // FIXME
    package enum Resolved {}

    package enum NamedResolved {}
}
