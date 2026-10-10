//
//  TextLayoutBackend.swift
//  OpenSwiftUITextLayout

package import Foundation

// This boundary contains only Swift values, never CoreText, RenderBox or Skia types.
package struct TextLayoutFont {
    package enum Design { case `default`, serif, rounded, monospaced }
    package var family: String?
    package var size: CGFloat
    package var weight: CGFloat
    package var italic: Bool
    package var design: Design

    package init(family: String? = nil, size: CGFloat = 17, weight: CGFloat = 0,
                 italic: Bool = false, design: Design = .default) {
        self.family = family
        self.size = size
        self.weight = weight
        self.italic = italic
        self.design = design
    }
}

package struct TextLayoutColor {
    package var red: Float
    package var green: Float
    package var blue: Float
    package var opacity: Float

    package init(red: Float, green: Float, blue: Float, opacity: Float) {
        self.red = red
        self.green = green
        self.blue = blue
        self.opacity = opacity
    }
}

package struct TextLayoutRun {
    package var string: String
    package var font: TextLayoutFont
    package var color: TextLayoutColor
    package var letterSpacing: CGFloat

    package init(string: String, font: TextLayoutFont, color: TextLayoutColor, letterSpacing: CGFloat) {
        self.string = string
        self.font = font
        self.color = color
        self.letterSpacing = letterSpacing
    }
}

package struct TextLayoutOptions {
    package enum Alignment { case leading, center, trailing }
    package var lineLimit: Int?
    package var alignment: Alignment
    package var rightToLeft: Bool

    package init(lineLimit: Int?, alignment: Alignment, rightToLeft: Bool) {
        self.lineLimit = lineLimit
        self.alignment = alignment
        self.rightToLeft = rightToLeft
    }
}

package struct TextLayoutMetrics {
    package var size: CGSize
    package var firstBaseline: CGFloat
    package var lastBaseline: CGFloat
    package var numberOfLines: Int
    package var hasTruncatedRanges: Bool

    package init(size: CGSize, firstBaseline: CGFloat, lastBaseline: CGFloat,
                 numberOfLines: Int, hasTruncatedRanges: Bool) {
        self.size = size
        self.firstBaseline = firstBaseline
        self.lastBaseline = lastBaseline
        self.numberOfLines = numberOfLines
        self.hasTruncatedRanges = hasTruncatedRanges
    }
}

/// Premultiplied RGBA8 pixels, with bounds in logical view coordinates.
package struct TextLayoutRaster {
    package var pixels: Data
    package var width: Int
    package var height: Int
    package var bounds: CGRect

    package init(pixels: Data, width: Int, height: Int, bounds: CGRect) {
        self.pixels = pixels
        self.width = width
        self.height = height
        self.bounds = bounds
    }
}

package protocol TextLayoutBackend: AnyObject {
    func makeLayout(runs: [TextLayoutRun], options: TextLayoutOptions) -> any TextLayoutInstance
}

package protocol TextLayoutInstance: AnyObject {
    func metrics(in size: CGSize) -> TextLayoutMetrics
    func rasterize(in size: CGSize, scale: CGFloat) -> TextLayoutRaster?
    func resetCache()
}
