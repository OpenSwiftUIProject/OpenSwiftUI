//
//  Color+CoreGraphics.swift
//  OpenSwiftUICore
//
//  Audited for iOS 18.0
//  Status: TODO

#if canImport(Darwin)

public import CoreGraphics

// MARK: - CGColor + Color

extension Color {
    @available(*, deprecated, message: "Use Color(cgColor:) when converting a CGColor, or create a standard Color directly")
    public init(_ cgColor: CGColor) {
        self.init(cgColor: cgColor)
    }
}

extension Color {
    public init(cgColor: CGColor) {
        preconditionFailure("TODO")
    }
}

#endif
