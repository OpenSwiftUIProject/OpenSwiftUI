//
//  DefaultDescriptionAttribute.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete

// MARK: - DefaultDescriptionAttribute

package enum DefaultDescriptionAttribute: String, CaseIterable {
    case rect
    case origin
    case startPoint
    case endPoint
    case transform
    case clips
    case cornerRadius
    case continuousCorners
    case opacity
    case borderWidth
    case borderColor
    case backgroundColor
    case compositingFilter
    case disableUpdates
    case shadowOpacity
    case shadowRadius
    case shadowColor
    case shadowOffset
    case shadowPath
    case shadowPathIsBounds
    case contentsCenter
    case contentsScaling
    case contentsMultiplyColor
    case colorScheme
    case filters
    case gradientType
    case gradientColors
    case gradientLocations
    case gradientInterpolations

    package static var all: Set<DefaultDescriptionAttribute> {
        var cases = Set(Self.allCases)
        if _TestApp.isIntending(to: .ignoreGeometry) {
            cases.subtract(Self.geometry)
        }
        if _TestApp.isIntending(to: .ignoreCornerRadius) {
            cases.subtract(Self.relatedToCornerRadius)
        }
        if !_TestApp.isIntending(to: .includeContinuousCorners) {
            cases.remove(.continuousCorners)
        }
        if !_TestApp.isIntending(to: .includeExtendedContents) {
            cases.remove(.contentsMultiplyColor)
        }
        if !_TestApp.isIntending(to: .includeExtendedGradients) {
            cases.remove(.gradientType)
            cases.remove(.gradientColors)
            cases.remove(.gradientLocations)
            cases.remove(.gradientInterpolations)
        }
        if _TestApp.isIntending(to: .ignoreOpacity) {
            cases.remove(.opacity)
        }
        if _TestApp.isIntending(to: .ignoreCompositingFilters) {
            cases.subtract([.filters, .compositingFilter])
        }
        return Set(cases)
    }

    package static var geometry: Set<DefaultDescriptionAttribute> {
        [.rect, .origin, .startPoint, .endPoint, .transform]
    }

    package static var relatedToCornerRadius: Set<DefaultDescriptionAttribute> {
        [.cornerRadius, .continuousCorners]
    }
}
