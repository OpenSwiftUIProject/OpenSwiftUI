//
//  DisplayListPrinter.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: 11125C146A81D1913BFBD53B89D010C6 (SwiftUICore)

// MARK: - DisplayList + print

extension DisplayList: CustomStringConvertible {
    public var description: String {
        var printer = SExpPrinter(tag: "display-list")
        print(into: &printer)
        return printer.end()
    }

    package var minimalDescription: String {
        var printer = SExpPrinter(tag: "DL", singleLine: true)
        printMinimally(into: &printer)
        return printer.end()
    }

    fileprivate func print(into printer: inout SExpPrinter) {
        for item in items {
            item.print(into: &printer)
        }
    }

    fileprivate func printMinimally(into printer: inout SExpPrinter) {
        for item in items {
            item.printMinimally(into: &printer)
        }
    }
}

// MARK: - DisplayList.Item + print

extension DisplayList.Item: CustomStringConvertible {
    package var description: String {
        var printer = SExpPrinter(tag: "display-list-item")
        print(into: &printer)
        return printer.end()
    }

    fileprivate func print(into printer: inout SExpPrinter) {
        printer.push("item")
        if identity.value != .zero {
            printer.print("#:identity \(identity.value)", newline: false)
        }
        printer.print("#:version \(version.value)", newline: false)
        if features.contains(.required) {
            printer.print("#:required true", newline: false)
        }
        if features.contains(.views) {
            printer.print("#:views true", newline: false)
        }
        printer.print("(frame (\(position.x) \(position.y); \(size.width) \(size.height)))")
        switch value {
        case .empty:
            break
        case let .content(content):
            printer.print("(content-seed \(content.seed.value))")
            content.value.print(into: &printer)
        case let .effect(effect, displayList):
            printer.push("effect")
            effect.print(into: &printer)
            displayList.print(into: &printer)
            printer.pop()
        case let .states(states):
            printer.push("states")
            for (hash, displayList) in states {
                printer.push("state \(hash)")
                displayList.print(into: &printer)
                printer.pop()
            }
            printer.pop()
        }
        printer.pop()
    }

    fileprivate func printMinimally(into printer: inout SExpPrinter) {
        printer.push("I:\(identity.value)")
        switch value {
        case .empty:
            break
        case let .content(content):
            content.value.printMinimally(into: &printer)
        case let .effect(effect, displayList):
            printer.push("E")
            effect.printMinimally(into: &printer)
            displayList.printMinimally(into: &printer)
            printer.pop()
        case let .states(states):
            printer.push("states")
            for (hash, displayList) in states {
                printer.push("\(hash)")
                displayList.printMinimally(into: &printer)
                printer.pop()
            }
            printer.pop()
        }
        printer.pop()
    }
}

// MARK: - DisplayList.Content.Value + print

extension DisplayList.Content.Value {
    fileprivate func print(into printer: inout SExpPrinter) {
        switch self {
        case let .backdrop(effect):
            printer.push("backdrop")
            printer.print("(scale \(effect.scale))")
            printer.print("(color \(effect.color))")
            printer.print("(filters \(effect.filters))")
            printer.pop()
        case let .color(color):
            printer.print("(color \(color))")
        case let .chameleonColor(fallback, filters):
            printer.push("chameleon-color")
            printer.print("(color \(fallback))")
            printer.print("(filters \(filters))")
            printer.pop()
        case let .image(image):
            printer.push("image")
            printer.print("#:size (\(image.size.width) \(image.size.height))", newline: false)
            printer.pop()
        case let .shape(path, paint, style):
            printer.push("shape")
            printer.print("(path\(path.description))")
            printer.print("(paint \(paint))")
            printer.print("(style \(style))")
            printer.pop()
        case let .shadow(path, shadow):
            printer.push("shadow")
            printer.print("(path\(path.description))")
            printer.print("(shadow \(shadow))")
            printer.pop()
        case .platformView:
            printer.push("platform-view")
            printer.pop()
        case .platformLayer:
            printer.push("platform-layer")
            printer.pop()
        case let .text(text, textSize):
            printer.print(#"(text "\#(text.text.storage?.string ?? "")" #:size \#(textSize))"#)
        case let .flattened(displayList, origin, _):
            printer.push("flattened")
            if origin != .zero {
                printer.print("#:origin (\(origin.x) \(origin.y))", newline: false)
            }
            displayList.print(into: &printer)
            printer.pop()
        case let .drawing(_, offset, options):
            printer.push("drawing")
            if offset != .zero {
                printer.print("#:offset (\(offset.x) \(offset.y))", newline: false)
            }
            if options.isAccelerated {
                printer.print("#:accelerated", newline: false)
            }
            if options.alphaOnly {
                printer.print("#:alpha-only", newline: false)
            }
            printer.pop()
        case let .view(factory):
            printer.push("view #:type \(type(of: factory))")
            printer.pop()
        case let .placeholder(id: identity):
            printer.print("(placeholder \(identity))")
        }
    }

    fileprivate func printMinimally(into printer: inout SExpPrinter) {
        switch self {
        case .backdrop:
            printer.print("B")
        case .color:
            printer.print("C")
        case .chameleonColor:
            printer.print("CH")
        case .image:
            printer.print("IM")
        case .shape:
            printer.print("S")
        case .shadow:
            printer.print("SH")
        case .platformView:
            printer.print("PV")
        case .platformLayer:
            printer.print("PL")
        case .text:
            printer.print("T")
        case let .flattened(displayList, _, _):
            printer.push("F")
            displayList.printMinimally(into: &printer)
            printer.pop()
        case .drawing:
            printer.print("D")
        case let .view(factory):
            printer.print("V:\(type(of: factory))")
        case let .placeholder(id: identity):
            printer.print("@\(identity)")
        }
    }
}

// MARK: - DisplayList.Effect + print

extension DisplayList.Effect {
    fileprivate func print(into printer: inout SExpPrinter) {
        switch self {
        case .identity:
            break
        case .geometryGroup:
            printer.print("#:geometry-group", newline: false)
        case .compositingGroup:
            printer.print("#:compositing-group", newline: false)
        case let .backdropGroup(isEnabled):
            printer.print("#:backdrop-group \(isEnabled)", newline: false)
        case let .archive(archiveIDs):
            printer.print("#:archive \(archiveIDs.map { $0.uuid.description } ?? "nil")", newline: false)
        case let .properties(properties):
            if properties.contains(.foregroundLayer) {
                printer.print("#:primary-fg-layer", newline: false)
            }
            if properties.contains(.secondaryForegroundLayer) {
                printer.print("#:secondary-fg-layer", newline: false)
            }
            if properties.contains(.tertiaryForegroundLayer) {
                printer.print("#:tertiary-fg-layer", newline: false)
            }
            if properties.contains(.quaternaryForegroundLayer) {
                printer.print("#:quaternary-fg-layer", newline: false)
            }
            if properties.contains(.ignoresEvents) {
                printer.print("#:ignores-events", newline: false)
            }
            if properties.contains(.privacySensitive) {
                printer.print("#:privacy-sensitive", newline: false)
            }
            if properties.contains(.archivesInteractiveControls) {
                printer.print("#:archives-interactive-controls", newline: false)
            }
            if properties.contains(.screencaptureProhibited) {
                printer.print("#:screencapture-prohibited", newline: false)
            }
        case .platformGroup:
            printer.print("#:platform-group", newline: false)
        case let .opacity(opacity):
            printer.print("#:opacity \(opacity)", newline: false)
        case let .blendMode(mode):
            printer.print("#:blend-mode \(mode)", newline: false)
        case let .clip(path, style, options):
            printer.push("clip")
            printer.print("(path\(path.description))")
            printer.print("(style \(style))")
            if !options.isEmpty {
                printer.print("(options \(options))")
            }
            printer.pop()
        case let .mask(displayList, options):
            printer.push("mask")
            if !options.isEmpty {
                printer.print("(options \(options))")
            }
            displayList.print(into: &printer)
            printer.pop()
        case let .transform(transform):
            printer.print("(transform \(transform))")
        case let .filter(filter):
            printer.push("filter")
            filter.print(into: &printer)
            printer.pop()
        case let .animation(animation):
            printer.push("animation")
            printer.print("(animation \(animation))")
            printer.pop()
        case let .contentTransition(state):
            printer.push("contentTransition")
            printer.print("(transition \(state.transition))")
            _ = state.animation.map { animation in
                printer.print("(animation \(animation.base))")
            }
            printer.pop()
        case let .view(factory):
            printer.push("view #:type \(type(of: factory))")
            printer.pop()
        case .accessibility:
            printer.push("accessibility")
            printer.pop()
        case .platform:
            break
        case let .state(hash):
            printer.push("state \(hash)")
            printer.pop()
        case let .interpolatorRoot(_, contentOrigin, contentOffset):
            printer.push("interpolatorRoot")
            if contentOrigin != .zero {
                printer.print("(content-origin \(contentOrigin))")
            }
            if contentOffset != .zero {
                printer.print("(content-offset \(contentOffset))")
            }
            printer.pop()
        case let .interpolatorLayer(_, serial):
            printer.push("interpolatorLayer #:serial \(serial)")
            printer.pop()
        case let .interpolatorAnimation(interpolatorAnimation):
            printer.push("interpolator-animation")
            if let value = interpolatorAnimation.value {
                printer.print("(value \(value))")
            }
            _ = interpolatorAnimation.animation.map { animation in
                printer.print("(animation \(animation.base))")
            }
            printer.pop()
        }
    }

    fileprivate func printMinimally(into printer: inout SExpPrinter) {
        switch self {
        case .identity:
            break
        case .geometryGroup:
            printer.print("GG")
        case .compositingGroup:
            printer.print("CG")
        case .backdropGroup:
            printer.print("BG")
        case let .archive(archiveIDs):
            printer.print("A:\(archiveIDs.map { $0.uuid.description } ?? "nil")")
        case .properties:
            printer.print("PR")
        case .platformGroup:
            printer.print("PG")
        case .opacity:
            printer.print("O")
        case .blendMode:
            printer.print("B")
        case .clip:
            printer.print("C")
        case .mask:
            printer.print("M")
        case .transform:
            printer.print("T")
        case .filter:
            printer.print("F")
        case .animation:
            printer.print("AN")
        case .contentTransition:
            printer.print("TR")
        case let .view(factory):
            printer.push("V:\(type(of: factory))")
            printer.pop()
        case .accessibility:
            printer.print("AX")
        case .platform:
            printer.print("PL")
        case let .state(hash):
            printer.print("H:\(hash)")
        case .interpolatorRoot:
            printer.print("IR")
        case .interpolatorLayer:
            printer.print("IL")
        case .interpolatorAnimation:
            printer.print("IA")
        }
    }
}

// MARK: - GraphicsFilter + print

extension GraphicsFilter {
    fileprivate func print(into printer: inout SExpPrinter) {
        switch self {
        case let .blur(style):
            printer.print("(blur #:radius \(style.radius))")
        case let .variableBlur(style):
            printer.print("(variable-blur #:radius \(style.radius))")
        case .averageColor:
            printer.print("(average-color)")
        case let .shadow(style):
            printer.push("shadow")
            printer.print("(kind \(style.kind.rawValue))")
            printer.print("(radius \(style.radius))")
            printer.print("(offset \(style.offset)")
            printer.print("(color \(style.color))")
            printer.pop()
        case let .projection(transform):
            printer.print("(projection \(transform))")
        case let .colorMatrix(matrix, premultiplied):
            if premultiplied {
                printer.print("(premultiplied-color-matrix \(matrix))")
            } else {
                printer.print("(color-matrix \(matrix))")
            }
        case let .colorMultiply(color):
            printer.print("(color-multiply \(color))")
        case let .hueRotation(angle):
            printer.print("(hue-rotation \(angle.degrees)deg)")
        case let .saturation(amount):
            printer.print("(saturation \(amount))")
        case let .brightness(amount):
            printer.print("(brightness \(amount))")
        case let .contrast(amount):
            printer.print("(contrast \(amount))")
        case .luminanceToAlpha:
            printer.print("(luminance-to-alpha)")
        case .colorInvert:
            printer.print("(color-invert)")
        case let .grayscale(amount):
            printer.print("(grayscale \(amount))")
        case let .colorMonochrome(monochrome):
            printer.print("(color-monochrome \(monochrome.color) #:amount \(monochrome.amount) #:bias \(monochrome.bias))")
        case let .vibrantColorMatrix(matrix):
            printer.print("(vibrant-color-matrix \(matrix))")
        case let .luminanceCurve(curve):
            printer.print("(luminance-curve \(curve.curve) #:amount \(curve.amount))")
        case let .colorCurves(curves):
            printer.print("(color-curves #:red \(curves.redCurve) #:green \(curves.greenCurve) #:blue \(curves.blueCurve) #:opacity \(curves.opacityCurve))")
        case let .shader(shader):
            printer.print("(shader \(shader))")
        case let .alphaThreshold(threshold):
            printer.print("(alpha-threshold \(threshold.color) #:amount \(threshold.amount))")
        }
    }
}
