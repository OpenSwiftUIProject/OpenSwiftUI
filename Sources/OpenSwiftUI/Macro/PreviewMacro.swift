//
//  PreviewMacro.swift
//  OpenSwiftUI

#if canImport(DeveloperToolsSupport)
@_exported import DeveloperToolsSupport
import OpenSwiftUICore

/// Creates an Xcode preview from an OpenSwiftUI view.
///
/// The macro hosts the view in a platform view controller and registers it with
/// Xcode Previews.
@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
@freestanding(declaration)
public macro Preview(
    _ name: String? = nil,
    @OpenSwiftUICore.ViewBuilder body: @escaping @MainActor () -> any OpenSwiftUICore.View
) = #externalMacro(
    module: "OpenSwiftUIMacros",
    type: "PreviewMacro"
)

/// Creates an Xcode preview with traits from an OpenSwiftUI view.
///
/// The macro hosts the view in a platform view controller and registers it and
/// its traits with Xcode Previews.
@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
@freestanding(declaration)
public macro Preview(
    _ name: String? = nil,
    traits: DeveloperToolsSupport.PreviewTrait<DeveloperToolsSupport.Preview.ViewTraits>,
    _ additionalTraits: DeveloperToolsSupport.PreviewTrait<DeveloperToolsSupport.Preview.ViewTraits>...,
    @OpenSwiftUICore.ViewBuilder body: @escaping @MainActor () -> any OpenSwiftUICore.View
) = #externalMacro(
    module: "OpenSwiftUIMacros",
    type: "PreviewMacro"
)
#endif
