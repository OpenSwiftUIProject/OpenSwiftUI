//
//  PlatformTextSystem.swift
//  OpenSwiftUICore

#if !canImport(CoreText)
package import Foundation

package protocol PlatformTextSystem {
    func textStyleTraits(_ style: Font.TextStyle, size: DynamicTypeSize) -> Font.ResolvedTraits
    func fontMetrics(_ string: NSAttributedString) -> NSAttributedString.EncodedFontMetrics
    func measure(_ string: NSAttributedString, in size: CGSize, lineLimit: Int?) -> NSAttributedString.Metrics
}

package enum PlatformTextSystems {
    // Installed before constructing a graph; access is serialized by Update.
    package static var current: (any PlatformTextSystem)?
}

package struct PlatformTextContent {
    package var string: NSAttributedString
    package var lineLimit: Int?
}
#endif
