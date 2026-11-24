//
//  WebCanvasHost.swift
//  OpenSwiftUI
//

#if os(WASI) && OPENSWIFTUI_DEFAULT_WEB_HOST && !OPENSWIFTUI_SWIFTUI_RENDERER
import Foundation
import JavaScriptEventLoop
import JavaScriptKit
import OpenCoreGraphicsShims
@_spi(WebRenderer) import OpenSwiftUICore

// MARK: - Default Web App Entry

func runDefaultWebApp(_ app: some App) {
    DefaultWebCanvasHost.installExecutorIfNeeded()
    let initialSurface = DefaultWebCanvasHost.currentViewportSurface()
    let options = _RendererConfiguration.WebOptions(
        surface: initialSurface,
        eventBridge: DefaultWebCanvasHost.eventBridge,
        measureText: DefaultWebCanvasHost.measureText,
        onRender: DefaultWebCanvasHost.render
    )
    DefaultWebCanvasHost.installHostListeners()
    runWebApp(app, options: options)
}

// MARK: - DefaultWebCanvasHost

private enum DefaultWebCanvasHost {
    private struct ActivePointer {
        var kind: _WebPointerEvent.Kind
        var button: Int
        var location: CGPoint
    }

    private static let executorInstallOnce: Void = {
        JavaScriptEventLoop.installGlobalExecutor()
    }()

    nonisolated(unsafe) static let eventBridge = _WebEventBridge()
    nonisolated(unsafe) private static var activePointers: [Int: ActivePointer] = [:]
    nonisolated(unsafe) private static var pointerSurface: CGSize = .zero
    nonisolated(unsafe) private static var pointerListeners: [JSClosure] = []
    nonisolated(unsafe) private static var hostListeners: [JSClosure] = []

    static func installExecutorIfNeeded() {
        _ = executorInstallOnce
    }

    private static func cssPixels(_ value: Double) -> String {
        if value.rounded() == value, let intValue = Int(exactly: value) {
            return "\(intValue)px"
        }
        return "\(value)px"
    }

    static func currentViewportSurface() -> CGSize {
        let canvas = resolveCanvas()
        if let explicitWidth = canvas.getAttribute!("data-surface-width").string.flatMap(Double.init),
           let explicitHeight = canvas.getAttribute!("data-surface-height").string.flatMap(Double.init),
           explicitWidth > 0, explicitHeight > 0,
           explicitWidth.isFinite, explicitHeight.isFinite
        {
            return CGSize(width: explicitWidth, height: explicitHeight)
        }
        let width = JSObject.global.innerWidth.number ?? 800.0
        let height = JSObject.global.innerHeight.number ?? 600.0
        return CGSize(
            width: width.isFinite && width > 0 ? width : 800.0,
            height: height.isFinite && height > 0 ? height : 600.0
        )
    }

    static func installHostListeners() {
        guard hostListeners.isEmpty else { return }

        let resizeListener = JSClosure { _ in
            let nextSurface = currentViewportSurface()
            eventBridge.resizeSurface(to: nextSurface)
            return .undefined
        }
        hostListeners.append(resizeListener)
        _ = JSObject.global.addEventListener!("resize", resizeListener)

        let keyDownListener = JSClosure { arguments in
            if let event = arguments.first?.object {
                handleKeyboard(event, isKeyDown: true)
            }
            return .undefined
        }
        let keyUpListener = JSClosure { arguments in
            if let event = arguments.first?.object {
                handleKeyboard(event, isKeyDown: false)
            }
            return .undefined
        }
        hostListeners.append(keyDownListener)
        hostListeners.append(keyUpListener)
        _ = JSObject.global.addEventListener!("keydown", keyDownListener)
        _ = JSObject.global.addEventListener!("keyup", keyUpListener)
    }

    static func measureText(
        _ request: _WebTextMeasurementRequest
    ) -> _WebTextMetrics {
        let canvas = resolveCanvas()
        let context = context2D(for: canvas)
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
        let canvas = resolveCanvas()
        let width = Double(frame.surface.width)
        let height = Double(frame.surface.height)
        let devicePixelRatio = max(JSObject.global.devicePixelRatio.number ?? 1.0, 1.0)
        canvas.width = .number(width * devicePixelRatio)
        canvas.height = .number(height * devicePixelRatio)

        let style = canvas.style.object!
        style.width = .string(cssPixels(width))
        style.height = .string(cssPixels(height))
        style.display = .string("block")

        let context = context2D(for: canvas)
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
        var symbolCommandCount = 0
        var renderedTexts: [String] = []
        var renderedSymbols: [String] = []

        for command in frame.commands {
            switch command {
            case let .fill(rect, transform, cssColor, shape):
                _ = context.save!()
                applyTransform(transform, to: context)
                context.fillStyle = .string(cssColor)
                fillPrimitive(shape, rect: rect, in: context)
                _ = context.restore!()

            case let .gradient(rect, transform, stops, geometry, shape):
                _ = context.save!()
                applyTransform(transform, to: context)
                if case let .elliptical(center, size, _, _) = geometry {
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
                _ = context.save!()
                applyTransform(transform, to: context)
                context.font = .string(cssFont(for: textStyle))
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
                renderedTexts.append(text)

            case let .pushClip(rect, transform, shape):
                _ = context.save!()
                applyTransform(transform, to: context)
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

            case let .symbol(rect, transform, name, textStyle, cssColor):
                _ = context.save!()
                applyTransform(transform, to: context)
                drawSystemSymbol(
                    name: name,
                    in: rect,
                    style: textStyle,
                    cssColor: cssColor,
                    context: context
                )
                _ = context.restore!()
                symbolCommandCount += 1
                renderedSymbols.append(name)
            }
        }

        pointerSurface = frame.surface
        installPointerListeners(on: canvas)

        canvas.setAttribute!("data-display-list-version", String(frame.version))
        canvas.setAttribute!("data-render-command-count", String(frame.commands.count))
        canvas.setAttribute!("data-text-command-count", String(textCommandCount))
        canvas.setAttribute!("data-symbol-command-count", String(symbolCommandCount))
        canvas.setAttribute!("data-rendered-text", renderedTexts.joined(separator: "|"))
        canvas.setAttribute!("data-rendered-symbols", renderedSymbols.joined(separator: "|"))
        if let docElement = JSObject.global.document.object?.documentElement.object {
            docElement.setAttribute!("data-web-renderer-status", "ready")
        }
    }

    // MARK: - Pointer & Keyboard Input

    private static func installPointerListeners(on canvas: JSObject) {
        guard pointerListeners.isEmpty else { return }
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
                eventBridge.cancelAll()
                for pointerID in pointers.keys {
                    releasePointer(pointerID, on: canvas)
                }
                canvas.setAttribute!("data-active-pointer-count", "0")
                return .undefined
            }
            pointerListeners.append(listener)
            _ = JSObject.global.addEventListener!(name, listener)
        }
        canvas.setAttribute!("data-web-input", "pointer,keyboard")
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
            let kind: _WebPointerEvent.Kind = switch event.pointerType.string {
            case "touch": .touch
            case "pen": .pen
            default: .mouse
            }
            pointer = ActivePointer(
                kind: kind,
                button: event.button.number.flatMap(Int.init(exactly:)) ?? 0,
                location: location
            )
            activePointers[pointerID] = pointer
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
    }

    private static func releasePointer(_ pointerID: Int, on canvas: JSObject) {
        if canvas.hasPointerCapture!(pointerID).boolean == true {
            _ = canvas.releasePointerCapture!(pointerID)
        }
    }

    private static func handleKeyboard(_ event: JSObject, isKeyDown: Bool) {
        if event.isComposing.boolean == true {
            return
        }
        guard let rawKey = event.key.string,
              let mapped = mapDOMKey(rawKey) else {
            return
        }
        let phase: _WebKeyEvent.Phase
        if isKeyDown {
            phase = event.repeat.boolean == true ? .repeat : .down
        } else {
            phase = .up
        }
        let code = event.code.string ?? mapped.key
        let webEvent = _WebKeyEvent(
            phase: phase,
            key: mapped.key,
            characters: mapped.characters,
            keyID: code,
            modifiers: eventModifiers(event)
        )
        if eventBridge.send(webEvent) {
            _ = event.preventDefault!()
        }
    }

    private static func mapDOMKey(_ domKey: String) -> (key: String, characters: String)? {
        switch domKey {
        case "ArrowUp": ("\u{F700}", "\u{F700}")
        case "ArrowDown": ("\u{F701}", "\u{F701}")
        case "ArrowLeft": ("\u{F702}", "\u{F702}")
        case "ArrowRight": ("\u{F703}", "\u{F703}")
        case "Escape": ("\u{001B}", "\u{001B}")
        case "Enter": ("\u{000D}", "\u{000D}")
        case "Tab": ("\u{0009}", "\u{0009}")
        case "Backspace": ("\u{0008}", "\u{0008}")
        case "Delete": ("\u{F728}", "\u{F728}")
        case "Home": ("\u{F729}", "\u{F729}")
        case "End": ("\u{F72B}", "\u{F72B}")
        case "PageUp": ("\u{F72C}", "\u{F72C}")
        case "PageDown": ("\u{F72D}", "\u{F72D}")
        case " ", "Spacebar": (" ", " ")
        default:
            domKey.count == 1 ? (domKey.lowercased(), domKey) : nil
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
        let scaleX = width / (contentWidth + horizontalInsets)
        let scaleY = height / (contentHeight + verticalInsets)
        return CGPoint(
            x: ((clientX - left) / scaleX - borderLeft - paddingLeft) * Double(pointerSurface.width) / contentWidth,
            y: ((clientY - top) / scaleY - borderTop - paddingTop) * Double(pointerSurface.height) / contentHeight
        )
    }

    // MARK: - Canvas & Drawing Helpers

    private static func resolveCanvas() -> JSObject {
        let document = JSObject.global.document.object!
        if let existingCanvas = document.getElementById!("canvas").object {
            return existingCanvas
        }
        if let htmlStyle = document.documentElement.object?.style.object {
            htmlStyle.margin = .string("0")
            htmlStyle.padding = .string("0")
            htmlStyle.width = .string("100%")
            htmlStyle.height = .string("100%")
            htmlStyle.overflow = .string("hidden")
        }
        if let body = document.body.object, let bodyStyle = body.style.object {
            bodyStyle.margin = .string("0")
            bodyStyle.padding = .string("0")
            bodyStyle.width = .string("100%")
            bodyStyle.height = .string("100%")
            bodyStyle.overflow = .string("hidden")
        }
        let canvas = document.createElement!("canvas").object!
        canvas.id = .string("canvas")
        _ = document.body.object!.appendChild!(canvas)
        return canvas
    }

    private static func context2D(for canvas: JSObject) -> JSObject {
        guard let context = canvas.getContext!("2d").object else {
            fatalError("CanvasRenderingContext2D is unavailable")
        }
        return context
    }

    private static func applyTransform(_ transform: CGAffineTransform, to context: JSObject) {
        _ = context.transform!(
            Double(transform.a),
            Double(transform.b),
            Double(transform.c),
            Double(transform.d),
            Double(transform.tx),
            Double(transform.ty)
        )
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
            result = context.createRadialGradient!(
                0.0, 0.0, Double(startRadiusFraction),
                0.0, 0.0, Double(endRadiusFraction)
            )
        case let .angular(center, angle):
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
            let r = min(Double(radius), width / 2, height / 2)
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

    private static func drawSystemSymbol(
        name: String,
        in rect: CGRect,
        style: _WebTextStyle,
        cssColor: String,
        context: JSObject
    ) {
        let size = min(Double(rect.width), Double(rect.height))
        guard size > 0, size.isFinite else { return }
        let cx = Double(rect.midX)
        let cy = Double(rect.midY)
        let weightFactor = max(0.75, min(1.45, 1.0 + Double(style.weight) * 0.55))
        let lineWidth = max(1.25, size * 0.095 * weightFactor)

        context.strokeStyle = .string(cssColor)
        context.fillStyle = .string(cssColor)
        context.lineWidth = .number(lineWidth)
        context.lineCap = .string("round")
        context.lineJoin = .string("round")

        switch name {
        case "globe":
            let r = size * 0.42
            _ = context.beginPath!()
            _ = context.arc!(cx, cy, r, 0.0, 2 * Double.pi)
            _ = context.stroke!()
            _ = context.beginPath!()
            _ = context.ellipse!(cx, cy, r * 0.48, r, 0.0, 0.0, 2 * Double.pi)
            _ = context.stroke!()
            _ = context.beginPath!()
            _ = context.moveTo!(cx - r, cy)
            _ = context.lineTo!(cx + r, cy)
            _ = context.moveTo!(cx - r * 0.84, cy - r * 0.46)
            _ = context.lineTo!(cx + r * 0.84, cy - r * 0.46)
            _ = context.moveTo!(cx - r * 0.84, cy + r * 0.46)
            _ = context.lineTo!(cx + r * 0.84, cy + r * 0.46)
            _ = context.stroke!()

        case "arrow.clockwise":
            let r = size * 0.34
            let startAngle = -Double.pi * 0.32
            let endAngle = Double.pi * 1.32
            _ = context.beginPath!()
            _ = context.arc!(cx, cy, r, startAngle, endAngle, false)
            _ = context.stroke!()
            let tipX = cx + r * cos(startAngle)
            let tipY = cy + r * sin(startAngle)
            let head = size * 0.17
            _ = context.beginPath!()
            _ = context.moveTo!(tipX - head * 0.95, tipY - head * 0.22)
            _ = context.lineTo!(tipX + head * 0.15, tipY + head * 0.15)
            _ = context.lineTo!(tipX - head * 0.18, tipY + head * 1.02)
            _ = context.stroke!()

        case "trophy.fill", "trophy":
            let w = size * 0.48
            let topY = cy - size * 0.34
            let cupBottomY = cy + size * 0.05
            _ = context.beginPath!()
            _ = context.moveTo!(cx - w * 0.5, topY)
            _ = context.lineTo!(cx + w * 0.5, topY)
            _ = context.quadraticCurveTo!(cx + w * 0.46, cupBottomY, cx, cupBottomY)
            _ = context.quadraticCurveTo!(cx - w * 0.46, cupBottomY, cx - w * 0.5, topY)
            _ = context.closePath!()
            if name.hasSuffix(".fill") {
                _ = context.fill!()
            } else {
                _ = context.stroke!()
            }
            _ = context.beginPath!()
            _ = context.arc!(cx - w * 0.5, topY + size * 0.13, size * 0.10, Double.pi * 0.5, Double.pi * 1.5, false)
            _ = context.stroke!()
            _ = context.beginPath!()
            _ = context.arc!(cx + w * 0.5, topY + size * 0.13, size * 0.10, -Double.pi * 0.5, Double.pi * 0.5, false)
            _ = context.stroke!()
            _ = context.beginPath!()
            _ = context.moveTo!(cx, cupBottomY)
            _ = context.lineTo!(cx, cy + size * 0.28)
            _ = context.moveTo!(cx - w * 0.42, cy + size * 0.28)
            _ = context.lineTo!(cx + w * 0.42, cy + size * 0.28)
            _ = context.stroke!()

        case "arrow.up.and.down.and.arrow.left.and.right":
            let arm = size * 0.38
            let head = size * 0.12
            _ = context.beginPath!()
            _ = context.moveTo!(cx, cy - arm)
            _ = context.lineTo!(cx, cy + arm)
            _ = context.moveTo!(cx - arm, cy)
            _ = context.lineTo!(cx + arm, cy)
            // Up
            _ = context.moveTo!(cx - head, cy - arm + head)
            _ = context.lineTo!(cx, cy - arm)
            _ = context.lineTo!(cx + head, cy - arm + head)
            // Down
            _ = context.moveTo!(cx - head, cy + arm - head)
            _ = context.lineTo!(cx, cy + arm)
            _ = context.lineTo!(cx + head, cy + arm - head)
            // Left
            _ = context.moveTo!(cx - arm + head, cy - head)
            _ = context.lineTo!(cx - arm, cy)
            _ = context.lineTo!(cx - arm + head, cy + head)
            // Right
            _ = context.moveTo!(cx + arm - head, cy - head)
            _ = context.lineTo!(cx + arm, cy)
            _ = context.lineTo!(cx + arm - head, cy + head)
            _ = context.stroke!()

        case "plus":
            let arm = size * 0.32
            _ = context.beginPath!()
            _ = context.moveTo!(cx - arm, cy)
            _ = context.lineTo!(cx + arm, cy)
            _ = context.moveTo!(cx, cy - arm)
            _ = context.lineTo!(cx, cy + arm)
            _ = context.stroke!()

        case "minus":
            let arm = size * 0.32
            _ = context.beginPath!()
            _ = context.moveTo!(cx - arm, cy)
            _ = context.lineTo!(cx + arm, cy)
            _ = context.stroke!()

        case "xmark":
            let arm = size * 0.28
            _ = context.beginPath!()
            _ = context.moveTo!(cx - arm, cy - arm)
            _ = context.lineTo!(cx + arm, cy + arm)
            _ = context.moveTo!(cx + arm, cy - arm)
            _ = context.lineTo!(cx - arm, cy + arm)
            _ = context.stroke!()

        case "checkmark":
            let r = size * 0.30
            _ = context.beginPath!()
            _ = context.moveTo!(cx - r, cy + r * 0.05)
            _ = context.lineTo!(cx - r * 0.2, cy + r * 0.78)
            _ = context.lineTo!(cx + r, cy - r * 0.68)
            _ = context.stroke!()

        default:
            let r = size * 0.36
            _ = context.beginPath!()
            _ = context.arc!(cx, cy, r, 0.0, 2 * Double.pi)
            _ = context.stroke!()
            _ = context.beginPath!()
            _ = context.arc!(cx, cy, max(1.5, lineWidth * 0.75), 0.0, 2 * Double.pi)
            _ = context.fill!()
        }
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
