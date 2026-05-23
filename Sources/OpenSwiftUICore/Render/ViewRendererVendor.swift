//
//  ViewRendererVendor.swift
//  OpenSwiftUICore

/// A type that identifies the underlying view renderer implementation vendor.
///
/// Use `viewRendererVendor` to check which vendor is active at runtime.
public struct ViewRendererVendor: RawRepresentable, Hashable, CaseIterable {
    public let rawValue: String

    public init(rawValue: String) {
        self.rawValue = rawValue
    }

    /// OpenSwiftUI's view renderer.
    public static let osui = ViewRendererVendor(rawValue: "org.OpenSwiftUIProject.OpenSwiftUI")

    /// Apple's SwiftUI view renderer.
    public static let sui = ViewRendererVendor(rawValue: "com.apple.SwiftUI")

    public static var allCases: [ViewRendererVendor] { [.osui, .sui] }
}

#if canImport(SwiftUI, _underlyingVersion: 6.5.4) && OPENSWIFTUI_SWIFTUI_RENDER
public let viewRendererVendor = ViewRendererVendor.sui
#else
public let viewRendererVendor = ViewRendererVendor.osui
#endif
