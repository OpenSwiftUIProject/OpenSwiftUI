//
//  SkiaTextLayout.swift
//  OpenSwiftUISkia

import Foundation
package import OpenSwiftUITextLayout
@_implementationOnly import Shaft
@_implementationOnly import ShaftSkia

/// Uses only Shaft's Skia bindings, never its widget, render-object or event pipeline.
package final class SkiaTextLayoutBackend: TextLayoutBackend {
    private let renderer = SkiaRenderer()
    private let lock = NSLock()

    package init() {}

    package func makeLayout(runs: [TextLayoutRun], options: TextLayoutOptions) -> any TextLayoutInstance {
        SkiaTextLayout(backend: self, runs: runs, options: options)
    }

    fileprivate func paragraph(runs: [TextLayoutRun], options: TextLayoutOptions, maxLines: Int?) -> Shaft.Paragraph {
        lock.lock()
        defer { lock.unlock() }
        let alignment: Shaft.TextAlign = switch options.alignment {
        case .leading: .start
        case .center: .center
        case .trailing: .end
        }
        let builder = renderer.createParagraphBuilder(ParagraphStyle(
            textAlign: alignment,
            textDirection: options.rightToLeft ? .rtl : .ltr,
            maxLines: maxLines, ellipsis: maxLines == nil ? nil : "\u{2026}"
        ))
        for run in runs {
            let font = run.font
            let weights: [(CGFloat, Shaft.FontWeight)] = [
                (-0.8, .w100), (-0.6, .w200), (-0.4, .w300), (0, .w400),
                (0.23, .w500), (0.3, .w600), (0.4, .w700), (0.56, .w800), (0.62, .w900),
            ]
            let weight = weights.min { abs($0.0 - font.weight) < abs($1.0 - font.weight) }!.1
            let families: [String]
            if let family = font.family { families = [family] }
            else {
                switch font.design {
                case .monospaced: families = ["Menlo", "DejaVu Sans Mono", "monospace"]
                case .serif: families = ["Times New Roman", "DejaVu Serif", "serif"]
                default: families = ["Helvetica", "DejaVu Sans", "sans-serif"]
                }
            }
            let color = run.color
            func byte(_ value: Float) -> UInt8 { UInt8((min(1, max(0, value)) * 255).rounded()) }
            builder.pushStyle(SpanStyle(
                color: Shaft.Color.argb(byte(color.opacity), byte(color.red), byte(color.green), byte(color.blue)),
                fontWeight: weight, fontStyle: font.italic ? .italic : .normal,
                fontFamilies: families, fontSize: Float(max(1, font.size)),
                letterSpacing: Float(run.letterSpacing)
            ))
            builder.addText(run.string)
            builder.pop()
        }
        return builder.build()
    }
}

private final class SkiaTextLayout: TextLayoutInstance {
    let backend: SkiaTextLayoutBackend
    let runs: [TextLayoutRun]
    let options: TextLayoutOptions
    private let lock = NSLock()
    private var entries: [Entry] = []
    private var raster: (size: CGSize, scale: CGFloat, image: TextLayoutRaster)?

    private struct Entry {
        var request: CGSize
        var paragraph: Shaft.Paragraph
        var metrics: OpenSwiftUITextLayout.TextLayoutMetrics
    }

    init(backend: SkiaTextLayoutBackend, runs: [TextLayoutRun], options: TextLayoutOptions) {
        self.backend = backend
        self.runs = runs
        self.options = options
    }

    func resetCache() {
        lock.lock()
        defer { lock.unlock() }
        entries.removeAll()
        raster = nil
    }

    func metrics(in size: CGSize) -> OpenSwiftUITextLayout.TextLayoutMetrics {
        lock.lock()
        defer { lock.unlock() }
        return entry(in: size).metrics
    }

    private func entry(in size: CGSize) -> Entry {
        let size = CGSize(width: size.width.isNaN ? 0 : max(0, size.width),
                          height: size.height.isNaN ? 0 : max(0, size.height))
        if let entry = entries.first(where: { $0.request == size }) { return entry }
        var limit = options.lineLimit.map { max(1, $0) }
        var paragraph = backend.paragraph(runs: runs, options: options, maxLines: limit)
        paragraph.layout(.width(.infinity))
        let width = min(size.width, CGFloat(ceil(paragraph.maxIntrinsicWidth)))
        paragraph.layout(.width(Float(width)))
        var lines = paragraph.computeLineMetrics()
        if size.height.isFinite, size.height > 0, CGFloat(paragraph.height) > size.height {
            let fitting = max(1, lines.prefix { CGFloat($0.baseline + $0.descent) <= size.height }.count)
            limit = min(limit ?? fitting, fitting)
            paragraph = backend.paragraph(runs: runs, options: options, maxLines: limit)
            paragraph.layout(.width(Float(width)))
            lines = paragraph.computeLineMetrics()
        }
        let empty = runs.allSatisfy { $0.string.isEmpty } || size.width == 0 || size.height == 0
        let metrics = OpenSwiftUITextLayout.TextLayoutMetrics(
            size: empty ? .zero : CGSize(width: width, height: CGFloat(paragraph.height)),
            firstBaseline: empty ? 0 : CGFloat(lines.first?.baseline ?? 0),
            lastBaseline: empty ? 0 : CGFloat(lines.last?.baseline ?? 0),
            numberOfLines: empty ? 0 : lines.count,
            hasTruncatedRanges: paragraph.didExceedMaxLines
        )
        let entry = Entry(request: size, paragraph: paragraph, metrics: metrics)
        if entries.count == 8 { entries.removeFirst() }
        entries.append(entry)
        return entry
    }

    func rasterize(in size: CGSize, scale: CGFloat) -> TextLayoutRaster? {
        lock.lock()
        defer { lock.unlock() }
        guard scale.isFinite, scale > 0 else { return nil }
        if let raster, raster.size == size, raster.scale == scale { return raster.image }
        let entry = entry(in: size)
        guard entry.metrics.size.width > 0, entry.metrics.size.height > 0 else { return nil }
        // Preserve glyph overhang without changing the logical measurement or baselines.
        let inset = max(2, runs.map { $0.font.size }.max() ?? 17)
        let bounds = CGRect(origin: .zero, size: entry.metrics.size).insetBy(dx: -inset, dy: -inset)
        let pixelWidth = ceil(bounds.width * scale)
        let pixelHeight = ceil(bounds.height * scale)
        guard pixelWidth > 0, pixelHeight > 0, pixelWidth <= 16384, pixelHeight <= 16384,
              pixelWidth * pixelHeight <= 16_777_216 else { return nil }
        let width = Int(pixelWidth), height = Int(pixelHeight)
        var pixels = Data(count: width * height * 4)
        let success = pixels.withUnsafeMutableBytes { bytes in
            SkiaCanvas.withRasterCanvas(width: width, height: height, pixels: bytes.baseAddress!, rowBytes: width * 4) { canvas in
                canvas.clear(color: Shaft.Color(0))
                canvas.scale(Float(scale), Float(scale))
                canvas.drawParagraph(entry.paragraph, Offset(Float(inset), Float(inset)))
            }
        }
        guard success else { return nil }
        let image = TextLayoutRaster(pixels: pixels, width: width, height: height,
            bounds: CGRect(x: -inset, y: -inset, width: CGFloat(width) / scale, height: CGFloat(height) / scale))
        raster = (size, scale, image)
        return image
    }
}
