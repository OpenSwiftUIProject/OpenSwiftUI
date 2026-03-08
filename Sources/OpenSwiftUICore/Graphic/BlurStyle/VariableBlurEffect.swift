//
//  VariableBlurEffect.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: 6A2330B0C22A93F083499CFD6C3BD5B1 (SwiftUICore)

public import Foundation

// MARK: - VariableBlurEffect

private struct VariableBlurEffect: EnvironmentalModifier, Equatable {
    var radius: CGFloat
    var mask: Image
    var isOpaque: Bool

    typealias ResolvedModifier = VariableBlurStyle

    func resolve(in environment: EnvironmentValues) -> VariableBlurStyle {
        let context = ImageResolutionContext(environment: environment)
        let resolved = mask.resolve(in: context)
        return VariableBlurStyle(
            radius: radius,
            isOpaque: isOpaque,
            mask: .image(resolved.image)
        )
    }
}

@_spi(Private)
@available(OpenSwiftUI_v5_0, *)
extension View {
    nonisolated public func variableBlur(maxRadius: CGFloat, mask: Image, opaque: Bool = false) -> some View {
        modifier(VariableBlurEffect(radius: maxRadius, mask: mask, isOpaque: opaque))
    }
}
