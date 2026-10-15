//
//  FontNonDarwinShims.swift
//  OpenSwiftUICore

#if !canImport(CoreText)
public import Foundation

// Placeholder for CoreText when not available.
public class CTFontDescriptor: CFCompatObject {}

public class CTFont: CFCompatObject {
    package let pointSize: CGFloat
    package let weight: CGFloat

    package init(pointSize: CGFloat, weight: CGFloat) {
        self.pointSize = pointSize
        self.weight = weight
        super.init()
    }
}

#endif
