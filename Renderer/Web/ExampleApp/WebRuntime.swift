#if os(WASI) && !OPENSWIFTUI_SWIFTUI_RENDERER
@_spi(WebRenderer) import OpenSwiftUI
import Foundation
import JavaScriptKit

struct BrowserHostInfo: Sendable {
    var reportedName: String
    var version: String

    var displayName: String {
        version.isEmpty ? reportedName : "\(reportedName) \(version)"
    }

    @MainActor
    static func current() -> BrowserHostInfo {
        let navigator = JSObject.global.navigator.object!
        let userAgent = navigator.userAgent.string ?? ""

        if let version = version(after: "Arc/", in: userAgent) {
            return BrowserHostInfo(reportedName: "Arc", version: version)
        }
        if let version = version(afterAny: ["Edg/", "EdgA/", "EdgiOS/"], in: userAgent) {
            return BrowserHostInfo(reportedName: "Microsoft Edge", version: version)
        }
        if let version = version(afterAny: ["OPR/", "OPiOS/"], in: userAgent) {
            return BrowserHostInfo(reportedName: "Opera", version: version)
        }
        if navigator.brave.object != nil {
            // The Chrome token is the engine version, not Brave's product
            // version, so don't present it as the latter.
            return BrowserHostInfo(reportedName: "Brave", version: "")
        }
        if let version = version(after: "Chrome/", in: userAgent)
            ?? version(after: "CriOS/", in: userAgent)
        {
            // Chromium-based browsers such as Arc can intentionally report
            // themselves as Chrome, so this is the browser-reported identity.
            return BrowserHostInfo(reportedName: "Chrome (reported)", version: version)
        }
        if let version = version(after: "Chromium/", in: userAgent) {
            return BrowserHostInfo(reportedName: "Chromium", version: version)
        }
        if let version = version(after: "Firefox/", in: userAgent)
            ?? version(after: "FxiOS/", in: userAgent)
        {
            return BrowserHostInfo(reportedName: "Firefox", version: version)
        }
        if userAgent.contains("Safari/"),
           let version = version(after: "Version/", in: userAgent)
        {
            return BrowserHostInfo(reportedName: "Safari", version: version)
        }
        return BrowserHostInfo(reportedName: "Unknown browser", version: "")
    }

    private static func version(after marker: String, in userAgent: String) -> String? {
        guard let markerRange = userAgent.range(of: marker) else {
            return nil
        }
        let value = userAgent[markerRange.upperBound...].prefix { character in
            character.isNumber || character == "."
        }
        return value.isEmpty ? nil : String(value)
    }

    private static func version(afterAny markers: [String], in userAgent: String) -> String? {
        for marker in markers {
            if let version = version(after: marker, in: userAgent) {
                return version
            }
        }
        return nil
    }
}

enum CanvasRenderer {
    private struct ActivePointer {
        var kind: _WebPointerEvent.Kind
        var button: Int
        var location: CGPoint
    }

    // JavaScriptKit objects and callbacks are tied to the browser's single
    // JavaScript thread. Input listeners and their bridge live for the iframe
    // lifetime; drawing a new frame does not interrupt active pointer sequences.
    nonisolated(unsafe) static let eventBridge = _WebEventBridge()
    nonisolated(unsafe) private static var activePointers: [Int: ActivePointer] = [:]
    nonisolated(unsafe) private static var pointerSurface: CGSize = .zero
    nonisolated(unsafe) private static var pointerListeners: [JSClosure] = []

    static func measureText(
        _ request: _WebTextMeasurementRequest
    ) -> _WebTextMetrics {
        let canvas = canvas()
        let context = context(for: canvas)
        _ = context.save!()
        defer { _ = context.restore!() }

        context.font = .string(cssFont(for: request.style))
        context.textAlign = .string("left")
        context.textBaseline = .string("alphabetic")

        let metrics = context.measureText!(request.text).object!
        let pointSize = Double(request.style.pointSize)
        let width = finiteMetric(metrics, "width") ?? 0.0
        let measuredAscent = finiteMetric(metrics, "fontBoundingBoxAscent")
            ?? finiteMetric(metrics, "actualBoundingBoxAscent")
            ?? 0.0
        let measuredDescent = finiteMetric(metrics, "fontBoundingBoxDescent")
            ?? finiteMetric(metrics, "actualBoundingBoxDescent")
            ?? 0.0
        let ascent: Double
        let descent: Double
        if measuredAscent + measuredDescent > 0.0 {
            ascent = max(measuredAscent, 0.0)
            descent = max(measuredDescent, 0.0)
        } else {
            ascent = pointSize * 0.8
            descent = pointSize * 0.2
        }

        let previousCount = canvas
            .getAttribute!("data-text-measurement-count")
            .string
            .flatMap(Int.init) ?? 0
        canvas.setAttribute!(
            "data-text-measurement-count",
            String(previousCount + 1)
        )

        return _WebTextMetrics(
            size: CGSize(
                width: CGFloat(width),
                height: CGFloat(ascent + descent)
            ),
            firstBaseline: CGFloat(ascent),
            lastBaseline: CGFloat(ascent),
            numberOfLines: request.text.isEmpty ? 0 : 1
        )
    }

    static func render(_ frame: _WebRenderFrame) {
        let canvas = canvas()

        let width = Double(frame.surface.width)
        let height = Double(frame.surface.height)
        let devicePixelRatio = JSObject.global.devicePixelRatio.number ?? 1.0
        canvas.width = .number(width * devicePixelRatio)
        canvas.height = .number(height * devicePixelRatio)

        let style = canvas.style.object!
        style.width = .string("\(width)px")
        style.height = .string("\(height)px")
        style.display = .string("block")

        let context = context(for: canvas)
        _ = context.setTransform!(
            devicePixelRatio,
            0.0,
            0.0,
            devicePixelRatio,
            0.0,
            0.0
        )
        _ = context.clearRect!(0.0, 0.0, width, height)

        var textCommandCount = 0
        var positiveTextSizeCount = 0
        var renderedTexts: [String] = []
        var renderedTextColors: Set<String> = []
        var renderedTextFontWeights: Set<Int> = []
        var textCommandSummary: [[String: Any]] = []
        for command in frame.commands {
            switch command {
            case let .fill(rect, transform, cssColor, shape):
                _ = context.save!()
                _ = context.transform!(
                    Double(transform.a),
                    Double(transform.b),
                    Double(transform.c),
                    Double(transform.d),
                    Double(transform.tx),
                    Double(transform.ty)
                )
                context.fillStyle = .string(cssColor)
                fillPrimitive(shape, rect: rect, in: context)
                _ = context.restore!()
            case let .gradient(rect, transform, stops, geometry, shape):
                _ = context.save!()
                _ = context.transform!(
                    Double(transform.a), Double(transform.b),
                    Double(transform.c), Double(transform.d),
                    Double(transform.tx), Double(transform.ty)
                )
                // Shape and gradient share this local coordinate system. The
                // Canvas transform also carries the host's device pixel ratio.
                if case let .elliptical(center, size, _, _) = geometry {
                    // The default path captures the item transform here.
                    // Changing the transform afterwards affects the gradient
                    // at fill time, but does not stretch the already-built
                    // shape (unlike passing a Path2D object to fill).
                    if beginPrimitivePath(shape, rect: rect, in: context) {
                        _ = context.transform!(
                            Double(size.width), 0.0, 0.0, Double(size.height),
                            Double(center.x), Double(center.y)
                        )
                        if let gradient = canvasGradient(geometry, stops: stops, in: context) {
                            context.fillStyle = .object(gradient)
                            _ = context.fill!()
                        }
                    }
                } else if let gradient = canvasGradient(geometry, stops: stops, in: context) {
                    context.fillStyle = .object(gradient)
                    fillPrimitive(shape, rect: rect, in: context)
                }
                _ = context.restore!()
            case let .text(rect, transform, text, textStyle, cssColor, firstBaseline):
                let cssFont = cssFont(for: textStyle)
                let fontWeight = cssFontWeight(textStyle.weight)
                _ = context.save!()
                _ = context.transform!(
                    Double(transform.a),
                    Double(transform.b),
                    Double(transform.c),
                    Double(transform.d),
                    Double(transform.tx),
                    Double(transform.ty)
                )
                context.font = .string(cssFont)
                context.textAlign = .string("left")
                context.textBaseline = .string("alphabetic")
                context.fillStyle = .string(cssColor)
                _ = context.beginPath!()
                _ = context.rect!(
                    Double(rect.minX),
                    Double(rect.minY),
                    Double(rect.width),
                    Double(rect.height)
                )
                _ = context.clip!()
                _ = context.fillText!(
                    text,
                    Double(rect.minX),
                    Double(rect.minY + firstBaseline)
                )
                _ = context.restore!()

                textCommandCount += 1
                if rect.width > 0.0, rect.height > 0.0 {
                    positiveTextSizeCount += 1
                }
                renderedTexts.append(text)
                renderedTextColors.insert(cssColor)
                renderedTextFontWeights.insert(fontWeight)
                let renderedRect = rect.applying(transform)
                textCommandSummary.append([
                    "text": text,
                    "x": Double(renderedRect.minX),
                    "y": Double(renderedRect.minY),
                    "width": Double(renderedRect.width),
                    "height": Double(renderedRect.height),
                    "cssColor": cssColor,
                    "cssFont": cssFont,
                    "cssFontWeight": fontWeight,
                    "pointSize": Double(textStyle.pointSize),
                ])
            case let .pushClip(rect, transform, shape):
                _ = context.save!()
                _ = context.transform!(
                    Double(transform.a),
                    Double(transform.b),
                    Double(transform.c),
                    Double(transform.d),
                    Double(transform.tx),
                    Double(transform.ty)
                )
                if beginPrimitivePath(shape, rect: rect, in: context) {
                    _ = context.clip!()
                }
                _ = context.setTransform!(
                    devicePixelRatio,
                    0.0,
                    0.0,
                    devicePixelRatio,
                    0.0,
                    0.0
                )
            case .popClip:
                _ = context.restore!()
            case let .symbol(rect, transform, _, textStyle, cssColor):
                _ = context.save!()
                _ = context.transform!(
                    Double(transform.a),
                    Double(transform.b),
                    Double(transform.c),
                    Double(transform.d),
                    Double(transform.tx),
                    Double(transform.ty)
                )
                let size = min(Double(rect.width), Double(rect.height))
                if size > 0, size.isFinite {
                    context.strokeStyle = .string(cssColor)
                    context.lineWidth = .number(max(1.25, size * 0.095 + Double(textStyle.weight) * 0.5))
                    _ = context.beginPath!()
                    _ = context.arc!(Double(rect.midX), Double(rect.midY), size * 0.36, 0.0, 2 * Double.pi)
                    _ = context.stroke!()
                }
                _ = context.restore!()
            }
        }

        pointerSurface = frame.surface
        installPointerListeners(on: canvas)

        canvas.setAttribute!("data-display-list-version", String(frame.version))
        canvas.setAttribute!("data-render-command-count", String(frame.commands.count))
        canvas.setAttribute!("data-text-command-count", String(textCommandCount))
        canvas.setAttribute!("data-text-color-count", String(renderedTextColors.count))
        canvas.setAttribute!(
            "data-text-font-weight-count",
            String(renderedTextFontWeights.count)
        )
        canvas.setAttribute!(
            "data-positive-text-size-count",
            String(positiveTextSizeCount)
        )
        canvas.setAttribute!("data-rendered-text", renderedTexts.joined(separator: "|"))
        if JSONSerialization.isValidJSONObject(textCommandSummary),
           let data = try? JSONSerialization.data(withJSONObject: textCommandSummary),
           let json = String(data: data, encoding: .utf8)
        {
            canvas.setAttribute!("data-text-command-summary", json)
        }
    }

    private static func installPointerListeners(on canvas: JSObject) {
        guard pointerListeners.isEmpty else { return }
        // The canvas owns its gesture sequences, including multiple pointers.
        // Avoid browser panning/zooming taking over midway through recognition.
        canvas.style.object!.touchAction = .string("none")
        let phases: [(String, _WebPointerEvent.Phase)] = [
            ("pointerdown", .began),
            ("pointermove", .moved),
            ("pointerup", .ended),
            ("pointercancel", .cancelled),
            ("lostpointercapture", .cancelled),
        ]
        for (name, phase) in phases {
            let listener = JSClosure { arguments in
                if let event = arguments.first?.object {
                    handlePointer(event, phase: phase, on: canvas)
                }
                return .undefined
            }
            pointerListeners.append(listener)
            _ = canvas.addEventListener!(name, listener)
        }
        for name in ["blur", "pagehide"] {
            let listener = JSClosure { _ in
                let pointers = activePointers
                activePointers.removeAll()
                // Also resets a pending multi-tap sequence after pointerup.
                eventBridge.cancelAll()
                for pointerID in pointers.keys {
                    releasePointer(pointerID, on: canvas)
                }
                canvas.setAttribute!("data-active-pointer-count", "0")
                canvas.setAttribute!("data-last-pointer-phase", "cancelled")
                return .undefined
            }
            pointerListeners.append(listener)
            _ = JSObject.global.addEventListener!(name, listener)
        }
        canvas.setAttribute!("data-web-input", "pointer")
        canvas.setAttribute!("data-active-pointer-count", "0")
    }

    private static func handlePointer(
        _ event: JSObject,
        phase: _WebPointerEvent.Phase,
        on canvas: JSObject
    ) {
        guard let rawID = event.pointerId.number,
              let pointerID = Int(exactly: rawID) else { return }
        var pointer: ActivePointer
        switch phase {
        case .began:
            guard activePointers[pointerID] == nil,
                  let location = logicalLocation(event, on: canvas) else { return }
            let kind: _WebPointerEvent.Kind
            switch event.pointerType.string {
            case "touch": kind = .touch
            case "pen": kind = .pen
            default: kind = .mouse
            }
            pointer = ActivePointer(
                kind: kind,
                button: event.button.number.flatMap(Int.init(exactly:)) ?? 0,
                location: location
            )
            activePointers[pointerID] = pointer
            // Synthetic PointerEvents are useful for smoke tests, but have no
            // browser-owned pointer to capture and would throw NotFoundError.
            if event.isTrusted.boolean == true {
                _ = canvas.setPointerCapture!(pointerID)
            }
        case .moved, .ended, .cancelled:
            guard let active = activePointers[pointerID] else { return }
            pointer = active
            if phase != .cancelled, let location = logicalLocation(event, on: canvas) {
                pointer.location = location
            }
            if phase == .moved {
                activePointers[pointerID] = pointer
            } else {
                // Remove first: releasePointerCapture can synchronously cause
                // lostpointercapture, which must not dispatch a second terminal event.
                activePointers.removeValue(forKey: pointerID)
            }
        }
        let input = _WebPointerEvent(
            pointerID: pointerID,
            phase: phase,
            kind: pointer.kind,
            location: pointer.location,
            button: pointer.button,
            modifiers: eventModifiers(event)
        )
        eventBridge.send(input)
        if phase == .ended || phase == .cancelled {
            releasePointer(pointerID, on: canvas)
        }
        let count = canvas.getAttribute!("data-web-pointer-event-count").string.flatMap(Int.init) ?? 0
        canvas.setAttribute!("data-web-pointer-event-count", String(count + 1))
        canvas.setAttribute!("data-active-pointer-count", String(activePointers.count))
        canvas.setAttribute!("data-last-pointer-phase", String(describing: phase))
        canvas.setAttribute!("data-last-pointer-x", String(Double(pointer.location.x)))
        canvas.setAttribute!("data-last-pointer-y", String(Double(pointer.location.y)))
    }

    private static func releasePointer(_ pointerID: Int, on canvas: JSObject) {
        if canvas.hasPointerCapture!(pointerID).boolean == true {
            _ = canvas.releasePointerCapture!(pointerID)
        }
    }

    private static func eventModifiers(_ event: JSObject) -> EventModifiers {
        var modifiers: EventModifiers = []
        if event.shiftKey.boolean == true { modifiers.insert(.shift) }
        if event.ctrlKey.boolean == true { modifiers.insert(.control) }
        if event.altKey.boolean == true { modifiers.insert(.option) }
        if event.metaKey.boolean == true { modifiers.insert(.command) }
        return modifiers
    }

    private static func logicalLocation(_ event: JSObject, on canvas: JSObject) -> CGPoint? {
        guard let clientX = event.clientX.number, clientX.isFinite,
              let clientY = event.clientY.number, clientY.isFinite,
              pointerSurface.width > 0, pointerSurface.height > 0 else { return nil }
        let bounds = canvas.getBoundingClientRect!().object!
        let style = JSObject.global.getComputedStyle!(canvas).object!
        func pixels(_ property: String) -> Double {
            let value = JSObject.global.parseFloat!(style[property]).number ?? 0
            return value.isFinite ? value : 0
        }
        let borderLeft = pixels("borderLeftWidth")
        let borderTop = pixels("borderTopWidth")
        let paddingLeft = pixels("paddingLeft")
        let paddingTop = pixels("paddingTop")
        let horizontalInsets = borderLeft + pixels("borderRightWidth") + paddingLeft + pixels("paddingRight")
        let verticalInsets = borderTop + pixels("borderBottomWidth") + paddingTop + pixels("paddingBottom")
        let borderBox = style.boxSizing.string == "border-box"
        let contentWidth = pixels("width") - (borderBox ? horizontalInsets : 0)
        let contentHeight = pixels("height") - (borderBox ? verticalInsets : 0)
        guard contentWidth > 0, contentHeight > 0,
              let left = bounds.left.number, let top = bounds.top.number,
              let width = bounds.width.number, width > 0,
              let height = bounds.height.number, height > 0 else { return nil }
        // CSS pixels, borders and padding must all be scaled together. The
        // canvas backing-store devicePixelRatio does not enter hit-test coordinates.
        let scaleX = width / (contentWidth + horizontalInsets)
        let scaleY = height / (contentHeight + verticalInsets)
        return CGPoint(
            x: ((clientX - left) / scaleX - borderLeft - paddingLeft) * Double(pointerSurface.width) / contentWidth,
            y: ((clientY - top) / scaleY - borderTop - paddingTop) * Double(pointerSurface.height) / contentHeight
        )
    }

    private static func canvas() -> JSObject {
        let document = JSObject.global.document
        if let existingCanvas = document.getElementById("canvas").object {
            return existingCanvas
        }
        let canvas = document.createElement("canvas").object!
        canvas.id = .string("canvas")
        _ = document.body.appendChild(canvas)
        return canvas
    }

    private static func canvasGradient(
        _ geometry: _WebRenderCommand.GradientGeometry,
        stops: [_WebRenderCommand.GradientStop],
        in context: JSObject
    ) -> JSObject? {
        let result: JSValue
        switch geometry {
        case let .linear(start, end):
            result = context.createLinearGradient!(Double(start.x), Double(start.y), Double(end.x), Double(end.y))
        case let .radial(center, startRadius, endRadius):
            result = context.createRadialGradient!(
                Double(center.x), Double(center.y), Double(startRadius),
                Double(center.x), Double(center.y), Double(endRadius)
            )
        case let .elliptical(_, _, startRadiusFraction, endRadiusFraction):
            // The center/axis transform is installed when filling the existing
            // shape path, so these radii stay in normalized gradient space.
            result = context.createRadialGradient!(
                0.0, 0.0, Double(startRadiusFraction),
                0.0, 0.0, Double(endRadiusFraction)
            )
        case let .angular(center, angle):
            // Older web hosts may not expose conic gradients. Skip this fill
            // rather than trapping the whole frame on an absent JS function.
            guard context.createConicGradient.function != nil else { return nil }
            result = context.createConicGradient!(angle, Double(center.x), Double(center.y))
        }
        guard let gradient = result.object else { return nil }
        for stop in stops {
            _ = gradient.addColorStop!(stop.location, stop.cssColor)
        }
        return gradient
    }

    private static func fillPrimitive(
        _ shape: _WebRenderCommand.FillShape,
        rect: CGRect,
        in context: JSObject
    ) {
        if beginPrimitivePath(shape, rect: rect, in: context) {
            _ = context.fill!()
        }
    }

    private static func beginPrimitivePath(
        _ shape: _WebRenderCommand.FillShape,
        rect: CGRect,
        in context: JSObject
    ) -> Bool {
        let x = Double(rect.minX)
        let y = Double(rect.minY)
        let width = Double(rect.width)
        let height = Double(rect.height)
        guard x.isFinite, y.isFinite, width.isFinite, height.isFinite,
              width > 0, height > 0 else { return false }
        _ = context.beginPath!()
        switch shape {
        case .rectangle:
            _ = context.rect!(x, y, width, height)
        case .ellipse:
            let radiusX = width / 2
            let radiusY = height / 2
            _ = context.ellipse!(x + radiusX, y + radiusY, radiusX, radiusY, 0.0, 0.0, 2 * Double.pi)
        case let .roundedRectangle(radius):
            let r = Double(radius)
            let right = x + width
            let bottom = y + height
            _ = context.moveTo!(x + r, y)
            _ = context.arcTo!(right, y, right, bottom, r)
            _ = context.arcTo!(right, bottom, x, bottom, r)
            _ = context.arcTo!(x, bottom, x, y, r)
            _ = context.arcTo!(x, y, right, y, r)
            _ = context.closePath!()
        }
        return true
    }

    private static func context(for canvas: JSObject) -> JSObject {
        guard let context = canvas.getContext!("2d").object else {
            fatalError("CanvasRenderingContext2D is unavailable")
        }
        return context
    }

    private static func finiteMetric(
        _ metrics: JSObject,
        _ name: String
    ) -> Double? {
        guard let value = metrics[name].number, value.isFinite else {
            return nil
        }
        return value
    }

    private static func cssFont(for style: _WebTextStyle) -> String {
        let pointSize = max(Double(style.pointSize), 1.0)
        return "\(cssFontWeight(style.weight)) \(pointSize)px -apple-system, BlinkMacSystemFont, system-ui, sans-serif"
    }

    private static func cssFontWeight(_ weight: CGFloat) -> Int {
        switch weight {
        case ..<(-0.7): 100
        case ..<(-0.5): 200
        case ..<(-0.2): 300
        case ..<0.15: 400
        case ..<0.27: 500
        case ..<0.35: 600
        case ..<0.48: 700
        case ..<0.60: 800
        default: 900
        }
    }
}
#endif
