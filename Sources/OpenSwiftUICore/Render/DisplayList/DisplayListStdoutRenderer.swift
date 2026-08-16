//
//  DisplayListStdoutRenderer.swift
//  OpenSwiftUICore
//
//  Status: WIP

package import Foundation
package import OpenCoreGraphicsShims
import OpenSwiftUI_SPI
#if canImport(Darwin)
import Darwin
#elseif canImport(Glibc)
import Glibc
#endif

// MARK: - DisplayList + stdout rendering

extension DisplayList {
    package func stdoutDescription(
        surface: CGSize,
        version: DisplayList.Version
    ) -> String {
        var lines = [
            "OpenSwiftUI backend: stdout",
            "surface: \(stdoutFormat(surface.width))x\(stdoutFormat(surface.height))",
            "display-list-version: \(version.value)",
            "rendered:",
        ]
        for command in stdoutRenderCommands() {
            lines.append("  - \(command.description)")
        }
        return lines.joined(separator: "\n")
    }

    package func stdoutTerminalDescription(
        surface: CGSize,
        version: DisplayList.Version,
        terminalSize: _RendererConfiguration.StdoutOptions.TerminalSize,
        colorMode: _RendererConfiguration.StdoutOptions.ColorMode
    ) -> String {
        let resolvedColorMode = StdoutTerminalSupport.resolvedColorMode(
            colorMode,
            environment: ProcessInfo.processInfo.environment,
            isTerminal: StdoutTerminalSupport.stdoutIsTerminal
        )
        var canvas = StdoutTerminalCanvas(
            surface: surface,
            terminalSize: terminalSize
        )
        canvas.draw(stdoutRenderCommands())
        return [
            "OpenSwiftUI backend: stdout",
            "surface: \(stdoutFormat(surface.width))x\(stdoutFormat(surface.height))",
            "display-list-version: \(version.value)",
            "terminal: \(canvas.columns)x\(canvas.rows) color:\(resolvedColorMode.stdoutDescription)",
            "rendered:",
            canvas.description(colorMode: resolvedColorMode),
        ].joined(separator: "\n")
    }

    private func stdoutRenderCommands() -> [StdoutRenderCommand] {
        var visitor = StdoutRenderCommandVisitor()
        visitor.append(list: self)
        return visitor.commands
    }
}

private enum StdoutRenderCommand {
    case fill(frame: CGRect, color: Color.Resolved)
    case text(
        frame: CGRect,
        runs: [StdoutTextRun],
        alignment: TextAlignment,
        layoutDirection: LayoutDirection
    )

    var description: String {
        switch self {
        case let .fill(frame, color):
            "fill x:\(stdoutFormat(frame.minX)) y:\(stdoutFormat(frame.minY)) w:\(stdoutFormat(frame.width)) h:\(stdoutFormat(frame.height)) \(color.description)"
        case let .text(frame, runs, _, _):
            "text x:\(stdoutFormat(frame.minX)) y:\(stdoutFormat(frame.minY)) w:\(stdoutFormat(frame.width)) h:\(stdoutFormat(frame.height)) \(runs.map(\.description).joined(separator: " "))"
        }
    }
}

private struct StdoutTextRun {
    var string: String
    var color: Color.Resolved?

    var description: String {
        let colorDescription = color?.description ?? "default"
        return "\(colorDescription):\(String(reflecting: string))"
    }

    func multiplyingOpacity(by opacity: Float) -> StdoutTextRun {
        var copy = self
        copy.color = color?.multiplyingOpacity(by: opacity)
        return copy
    }
}

private struct StdoutRenderCommandVisitor {
    var commands: [StdoutRenderCommand] = []

    mutating func append(
        list: DisplayList,
        transform: CGAffineTransform = .identity,
        opacity: Float = 1.0
    ) {
        for item in list.items {
            append(item: item, transform: transform, opacity: opacity)
        }
    }

    private mutating func append(
        item: DisplayList.Item,
        transform: CGAffineTransform,
        opacity: Float
    ) {
        switch item.value {
        case let .content(content):
            append(
                content: content,
                frame: item.frame.applying(transform),
                transform: transform,
                opacity: opacity
            )
        case let .effect(effect, list):
            append(effect: effect, list: list, transform: transform, opacity: opacity)
        case let .states(states):
            for (_, list) in states {
                append(list: list, transform: transform, opacity: opacity)
            }
        case .empty:
            break
        }
    }

    private mutating func append(
        content: DisplayList.Content,
        frame: CGRect,
        transform: CGAffineTransform,
        opacity: Float
    ) {
        switch content.value {
        case let .color(color):
            commands.append(.fill(frame: frame, color: color.multiplyingOpacity(by: opacity)))
        case let .shape(_, paint, _):
            if let color = paint.stdoutResolvedColor {
                commands.append(.fill(frame: frame, color: color.multiplyingOpacity(by: opacity)))
            }
        case let .text(text, _):
            #if os(macOS)
            let runs = text.stdoutTextRuns.map { $0.multiplyingOpacity(by: opacity) }
            commands.append(.text(
                frame: frame,
                runs: runs,
                alignment: text.text.layoutProperties.multilineTextAlignment,
                layoutDirection: text.text.layoutProperties.layoutDirection
            ))
            #else
            break
            #endif
        case let .flattened(list, offset, _):
            append(
                list: list,
                transform: transform.concatenating(
                    CGAffineTransform(translationX: frame.minX + offset.x, y: frame.minY + offset.y)
                ),
                opacity: opacity
            )
        default:
            break
        }
    }

    private mutating func append(
        effect: DisplayList.Effect,
        list: DisplayList,
        transform: CGAffineTransform,
        opacity: Float
    ) {
        switch effect {
        case let .opacity(alpha):
            append(list: list, transform: transform, opacity: opacity * alpha)
        case let .transform(.affine(affine)):
            append(list: list, transform: transform.concatenating(affine), opacity: opacity)
        default:
            append(list: list, transform: transform, opacity: opacity)
        }
    }
}

private struct StdoutColorPaintVisitor: ResolvedPaintVisitor {
    var color: Color.Resolved?

    mutating func visitPaint<P>(_ paint: P) where P: ResolvedPaint {
        color = paint as? Color.Resolved
    }
}

private extension AnyResolvedPaint {
    var stdoutResolvedColor: Color.Resolved? {
        var visitor = StdoutColorPaintVisitor()
        visit(&visitor)
        return visitor.color
    }
}

#if os(macOS)
private extension StyledTextContentView {
    var stdoutTextRuns: [StdoutTextRun] {
        guard let storage = text.storage, storage.length > 0 else {
            return []
        }
        var runs: [StdoutTextRun] = []
        storage.enumerateAttributes(
            in: NSRange(location: 0, length: storage.length)
        ) { attributes, range, _ in
            let string = storage.attributedSubstring(from: range).string
            let color = attributes[.kitForegroundColor].flatMap(stdoutResolvedColor)
            if let lastIndex = runs.indices.last, runs[lastIndex].color == color {
                runs[lastIndex].string += string
            } else {
                runs.append(StdoutTextRun(string: string, color: color))
            }
        }
        return runs
    }
}

private func stdoutResolvedColor(_ value: Any) -> Color.Resolved? {
    if let color = value as? Color.Resolved {
        return color
    }
    return Color.Resolved(platformColor: value as AnyObject)
}
#endif

private func stdoutFormat(_ value: CGFloat) -> String {
    let number = Double(value)
    return String(format: "%.1f", number == -0.0 ? 0.0 : number)
}

// MARK: - Terminal support [TBA]

package enum StdoutTerminalSupport {
    package static var stdoutIsTerminal: Bool {
        #if canImport(Darwin) || canImport(Glibc)
        isatty(STDOUT_FILENO) == 1
        #else
        false
        #endif
    }

    package static func resolvedColorMode(
        _ requestedMode: _RendererConfiguration.StdoutOptions.ColorMode,
        environment: [String: String],
        isTerminal: Bool
    ) -> _RendererConfiguration.StdoutOptions.ColorMode {
        guard requestedMode == .automatic else {
            return requestedMode
        }
        guard isTerminal,
              environment["NO_COLOR", default: ""].isEmpty,
              environment["TERM"]?.lowercased() != "dumb" else {
            return .monochrome
        }
        let colorTerminal = environment["COLORTERM", default: ""].lowercased()
        let terminal = environment["TERM", default: ""].lowercased()
        if colorTerminal == "truecolor" || colorTerminal == "24bit" ||
            terminal.contains("truecolor") || terminal.contains("direct") {
            return .trueColor
        }
        if terminal.contains("256color") {
            return .ansi256
        }
        return terminal.isEmpty ? .monochrome : .ansi16
    }

    package static func terminalSize(
        environment: [String: String] = ProcessInfo.processInfo.environment
    ) -> _RendererConfiguration.StdoutOptions.TerminalSize {
        #if canImport(Darwin) || canImport(Glibc)
        var windowSize = winsize()
        if ioctl(STDOUT_FILENO, UInt(TIOCGWINSZ), &windowSize) == 0,
           windowSize.ws_col > 0,
           windowSize.ws_row > 0 {
            return .init(
                columns: Int(windowSize.ws_col),
                rows: Int(windowSize.ws_row)
            )
        }
        #endif
        let columns = environment["COLUMNS"].flatMap(Int.init).flatMap { $0 > 0 ? $0 : nil } ?? 80
        let rows = environment["LINES"].flatMap(Int.init).flatMap { $0 > 0 ? $0 : nil } ?? 24
        return .init(columns: columns, rows: rows)
    }
}

private extension _RendererConfiguration.StdoutOptions.ColorMode {
    var stdoutDescription: String {
        switch self {
        case .automatic: "automatic"
        case .monochrome: "monochrome"
        case .ansi16: "ansi16"
        case .ansi256: "ansi256"
        case .trueColor: "trueColor"
        }
    }
}

private struct StdoutTerminalCanvas {
    private struct Cell {
        var character: Character?
        var foreground: Color.Resolved?
        var background: Color.Resolved?
    }

    let surface: CGSize
    let columns: Int
    let rows: Int
    private var cells: [Cell]

    init(
        surface: CGSize,
        terminalSize: _RendererConfiguration.StdoutOptions.TerminalSize
    ) {
        self.surface = surface
        columns = max(1, terminalSize.columns)
        rows = max(1, terminalSize.rows)
        cells = Array(
            repeating: Cell(),
            count: max(1, terminalSize.columns) * max(1, terminalSize.rows)
        )
    }

    mutating func draw(_ commands: [StdoutRenderCommand]) {
        for command in commands {
            switch command {
            case let .fill(frame, color):
                fill(frame: frame, color: color)
            case let .text(frame, runs, alignment, layoutDirection):
                drawText(
                    frame: frame,
                    runs: runs,
                    alignment: alignment,
                    layoutDirection: layoutDirection
                )
            }
        }
    }

    func description(
        colorMode: _RendererConfiguration.StdoutOptions.ColorMode
    ) -> String {
        (0..<rows).map { row in
            var result = ""
            var activeForeground: Color.Resolved?
            var activeBackground: Color.Resolved?
            for column in 0..<columns {
                let cell = cells[index(column: column, row: row)]
                if colorMode != .monochrome,
                   cell.foreground != activeForeground || cell.background != activeBackground {
                    result += stdoutANSISequence(
                        foreground: cell.foreground,
                        background: cell.background,
                        colorMode: colorMode
                    )
                    activeForeground = cell.foreground
                    activeBackground = cell.background
                }
                if let character = cell.character {
                    result.append(character)
                } else if colorMode == .monochrome, cell.background != nil {
                    result.append("█")
                } else {
                    result.append(" ")
                }
            }
            if colorMode != .monochrome,
               activeForeground != nil || activeBackground != nil {
                result += "\u{001B}[0m"
            }
            return result
        }.joined(separator: "\n")
    }

    private mutating func fill(frame: CGRect, color: Color.Resolved) {
        guard !frame.isEmpty else {
            return
        }
        let columnRange = cellRange(
            from: frame.minX,
            to: frame.maxX,
            surfaceLength: surface.width,
            cellCount: columns
        )
        let rowRange = cellRange(
            from: frame.minY,
            to: frame.maxY,
            surfaceLength: surface.height,
            cellCount: rows
        )
        for row in rowRange {
            for column in columnRange {
                let index = index(column: column, row: row)
                cells[index].character = nil
                cells[index].foreground = nil
                cells[index].background = color
            }
        }
    }

    private struct TextCell {
        var character: Character
        var foreground: Color.Resolved?
    }

    private mutating func drawText(
        frame: CGRect,
        runs: [StdoutTextRun],
        alignment: TextAlignment,
        layoutDirection: LayoutDirection
    ) {
        let lines = textLines(runs: runs)
        let measuredColumns = lines.map(\.count).max() ?? 0
        guard measuredColumns > 0 else {
            return
        }
        // The display-list frame was measured using the resolved proportional font.
        // Preserve its center while replacing its size with terminal-cell metrics.
        let centerColumn = cellOffset(
            frame.midX,
            surfaceLength: surface.width,
            cellCount: columns
        )
        let centerRow = cellOffset(
            frame.midY,
            surfaceLength: surface.height,
            cellCount: rows
        )
        let initialColumn = centerColumn - measuredColumns / 2
        let initialRow = centerRow - lines.count / 2

        for (lineOffset, line) in lines.enumerated() {
            let row = initialRow + lineOffset
            guard row >= 0, row < rows else {
                continue
            }
            let columnOffset = textAlignmentOffset(
                availableWidth: measuredColumns,
                lineWidth: line.count,
                alignment: alignment,
                layoutDirection: layoutDirection
            )
            var column = initialColumn + columnOffset
            for textCell in line {
                guard column >= 0, column < columns else {
                    column += 1
                    continue
                }
                let index = index(column: column, row: row)
                cells[index].character = textCell.character
                cells[index].foreground = textCell.foreground
                column += 1
            }
        }
    }

    private func textLines(runs: [StdoutTextRun]) -> [[TextCell]] {
        var lines: [[TextCell]] = [[]]
        for run in runs {
            for character in run.string {
                if character == "\n" {
                    lines.append([])
                    continue
                }
                lines[lines.index(before: lines.endIndex)].append(
                    TextCell(character: character, foreground: run.color)
                )
            }
        }
        return lines
    }

    private func textAlignmentOffset(
        availableWidth: Int,
        lineWidth: Int,
        alignment: TextAlignment,
        layoutDirection: LayoutDirection
    ) -> Int {
        let remainingWidth = availableWidth - lineWidth
        switch alignment {
        case .leading:
            return layoutDirection == .leftToRight ? 0 : remainingWidth
        case .center:
            return remainingWidth / 2
        case .trailing:
            return layoutDirection == .leftToRight ? remainingWidth : 0
        }
    }

    private func index(column: Int, row: Int) -> Int {
        row * columns + column
    }

    private func cellOffset(
        _ position: CGFloat,
        surfaceLength: CGFloat,
        cellCount: Int
    ) -> Int {
        guard surfaceLength > 0 else {
            return 0
        }
        return Int(floor(position / surfaceLength * CGFloat(cellCount)))
    }

    private func cellRange(
        from start: CGFloat,
        to end: CGFloat,
        surfaceLength: CGFloat,
        cellCount: Int
    ) -> Range<Int> {
        guard surfaceLength > 0 else {
            return 0..<0
        }
        let lowerBound = max(
            0,
            min(cellCount, Int(ceil(start / surfaceLength * CGFloat(cellCount) - 0.5)))
        )
        let upperBound = max(
            lowerBound,
            min(cellCount, Int(ceil(end / surfaceLength * CGFloat(cellCount) - 0.5)))
        )
        return lowerBound..<upperBound
    }
}

private func stdoutANSISequence(
    foreground: Color.Resolved?,
    background: Color.Resolved?,
    colorMode: _RendererConfiguration.StdoutOptions.ColorMode
) -> String {
    var parameters = ["0"]
    if let foreground {
        parameters.append(contentsOf: stdoutANSIColorParameters(
            foreground,
            isBackground: false,
            colorMode: colorMode
        ))
    }
    if let background {
        parameters.append(contentsOf: stdoutANSIColorParameters(
            background,
            isBackground: true,
            colorMode: colorMode
        ))
    }
    return "\u{001B}[\(parameters.joined(separator: ";"))m"
}

private func stdoutANSIColorParameters(
    _ color: Color.Resolved,
    isBackground: Bool,
    colorMode: _RendererConfiguration.StdoutOptions.ColorMode
) -> [String] {
    let components = color.stdoutRGBComponents
    switch colorMode {
    case .ansi16:
        let index = stdoutNearestANSI16Color(to: components)
        let base = isBackground ? 40 : 30
        let code = index < 8 ? base + index : base + 60 + index - 8
        return [String(code)]
    case .ansi256:
        return [isBackground ? "48" : "38", "5", String(stdoutANSI256Color(for: components))]
    case .trueColor:
        return [
            isBackground ? "48" : "38",
            "2",
            String(components.red),
            String(components.green),
            String(components.blue),
        ]
    case .automatic, .monochrome:
        return []
    }
}

private extension Color.Resolved {
    var stdoutRGBComponents: (red: Int, green: Int, blue: Int) {
        func component(_ value: Float) -> Int {
            Int((value.clamp(min: 0, max: 1) * 255).rounded())
        }
        return (component(red), component(green), component(blue))
    }
}

private func stdoutNearestANSI16Color(
    to color: (red: Int, green: Int, blue: Int)
) -> Int {
    let palette = [
        (0, 0, 0), (128, 0, 0), (0, 128, 0), (128, 128, 0),
        (0, 0, 128), (128, 0, 128), (0, 128, 128), (192, 192, 192),
        (128, 128, 128), (255, 0, 0), (0, 255, 0), (255, 255, 0),
        (0, 0, 255), (255, 0, 255), (0, 255, 255), (255, 255, 255),
    ]
    return palette.enumerated().min { lhs, rhs in
        stdoutColorDistance(lhs.element, color) < stdoutColorDistance(rhs.element, color)
    }?.offset ?? 0
}

private func stdoutANSI256Color(
    for color: (red: Int, green: Int, blue: Int)
) -> Int {
    let levels = [0, 95, 135, 175, 215, 255]
    func nearestLevel(to component: Int) -> Int {
        levels.enumerated().min {
            abs($0.element - component) < abs($1.element - component)
        }?.offset ?? 0
    }
    let red = nearestLevel(to: color.red)
    let green = nearestLevel(to: color.green)
    let blue = nearestLevel(to: color.blue)
    let cubeColor = (levels[red], levels[green], levels[blue])
    let cubeIndex = 16 + 36 * red + 6 * green + blue
    let average = (color.red + color.green + color.blue) / 3
    let gray = max(0, min(23, Int(round((Double(average) - 8) / 10))))
    let grayValue = 8 + gray * 10
    let grayColor = (grayValue, grayValue, grayValue)
    return stdoutColorDistance(grayColor, color) < stdoutColorDistance(cubeColor, color)
        ? 232 + gray
        : cubeIndex
}

private func stdoutColorDistance(
    _ lhs: (Int, Int, Int),
    _ rhs: (red: Int, green: Int, blue: Int)
) -> Int {
    let red = lhs.0 - rhs.red
    let green = lhs.1 - rhs.green
    let blue = lhs.2 - rhs.blue
    return red * red + green * green + blue * blue
}

// MARK: - StdoutDisplayListRenderer

final class StdoutDisplayListRenderer: ViewRendererBase {
    let platform: DisplayList.ViewUpdater.Platform
    weak var host: (any ViewRendererHost)?
    var options: _RendererConfiguration.StdoutOptions
    private var seed: DisplayList.Seed = .init()
    private var hasRendered = false

    init(
        platform: DisplayList.ViewUpdater.Platform,
        host: (any ViewRendererHost)?,
        options: _RendererConfiguration.StdoutOptions
    ) {
        self.platform = platform
        self.host = host
        self.options = options
    }

    var exportedObject: AnyObject? {
        nil
    }

    func render(
        rootView: AnyObject,
        from list: DisplayList,
        time: Time,
        version: DisplayList.Version,
        maxVersion: DisplayList.Version,
        environment: DisplayList.ViewRenderer.Environment
    ) -> Time {
        let nextSeed = DisplayList.Seed(version)
        guard !hasRendered || nextSeed != seed else {
            return .infinity
        }
        hasRendered = true
        seed = nextSeed
        let description: String
        switch options.viewMode {
        case .displayList:
            description = list.stdoutDescription(
                surface: options.surface,
                version: version
            )
        case .terminal:
            description = list.stdoutTerminalDescription(
                surface: options.surface,
                version: version,
                terminalSize: options.terminalSize ?? StdoutTerminalSupport.terminalSize(),
                colorMode: options.colorMode
            )
        }
        print(description)
        if let host, let observer = host.as(ViewGraphRenderObserver.self) {
            observer.didRender()
        }
        return .infinity
    }

    func renderAsync(
        to list: DisplayList,
        time: Time,
        targetTimestamp: Time?,
        version: DisplayList.Version,
        maxVersion: DisplayList.Version
    ) -> Time? {
        nil
    }

    func destroy(rootView: AnyObject) {}

    var viewCacheIsEmpty: Bool {
        true
    }
}
