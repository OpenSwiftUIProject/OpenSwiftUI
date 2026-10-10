//
//  SDLViewUpdaterTests.swift
//  OpenSwiftUITests

#if OPENSWIFTUI_SDL3
import Foundation
import OpenCoreGraphicsShims
@testable import OpenSwiftUI
@_spi(ForOpenSwiftUIOnly) @_spi(Private) @testable import OpenSwiftUICore
import OpenSwiftUITestsSupport
@_implementationOnly import OpenSwiftUISkia
import SwiftSDL3
import Testing

@MainActor
@Suite(.tags(.aigc), .serialized)
struct SDLViewUpdaterTests {
    @Test
    func skiaTextTapUpdatesStateAndLayout() throws {
        try withTapHost(rootView: AnyView(SDLTextTapTestView())) { host in
            func textItem() throws -> (String, CGRect) {
                RunLoop.flushObservers()
                host.renderIfNeeded()
                let list = try #require(host.viewGraph.rootDisplayList?.0)
                for item in list.items {
                    if case let .content(content) = item.value,
                       case let .text(view, _) = content.value {
                        return (view.text.storage?.string ?? "", item.frame)
                    }
                }
                Issue.record("Expected a Text display-list item")
                return ("", .zero)
            }
            let before = try textItem()
            #expect(before.0 == "One")
            #expect(before.1.width > 0)
            click(host, y: Float(before.1.midY))
            let after = try textItem()
            #expect(after.0 == "One two three four")
            #expect(after.1.width > before.1.width)
        }
    }

    @Test
    func skiaMeasuresWrappingAndBaselines() {
        let text = resolveText(Text("Hello Skia\nSecond line").font(.system(size: 20)))
        let metrics = text.metrics(in: CGSize(width: 300, height: CGFloat.infinity), layoutMargins: nil)
        #expect(metrics.numberOfLines == 2)
        #expect(metrics.size.width > 60 && metrics.size.width < 300)
        #expect(metrics.size.height > 30)
        #expect(metrics.firstBaseline > 0)
        #expect(metrics.lastBaseline > metrics.firstBaseline)
        #expect(text.explicitAlignment(VerticalAlignment.firstTextBaseline.key, at: CGSize(width: 300, height: CGFloat.infinity)) == metrics.firstBaseline)
        let narrow = text.sizeThatFits(_ProposedSize(width: 50, height: nil))
        #expect(narrow.width <= 50)
        #expect(narrow.height > metrics.size.height)
        #expect(text.sizeThatFits(.zero) == .zero)
    }

    @Test
    func skiaLineLimitAndFontSize() {
        let defaultFont = resolveText(Text("Default font"))
        #expect(defaultFont.sizeThatFits(.unspecified).height > 0)
        let styled = resolveText(Text("Styled text").font(.headline).bold().italic())
        #expect(styled.sizeThatFits(.unspecified).width > 0)
        let small = resolveText(Text("Hello Skia").font(.system(size: 12)))
        let large = resolveText(Text("Hello Skia").font(.system(size: 32)))
        #expect(large.sizeThatFits(.unspecified).width > small.sizeThatFits(.unspecified).width * 2)
        var environment = EnvironmentValues()
        environment.lineLimit = 1
        let text = resolveText(Text("One long line with several words").font(.system(size: 20)), environment: environment)
        let metrics = text.metrics(in: CGSize(width: 70, height: CGFloat.infinity), layoutMargins: nil)
        #expect(metrics.numberOfLines == 1)
        #expect(metrics.hasTruncatedRanges)
    }

    @Test
    func skiaRasterAndSDLPresentation() throws {
        let text = resolveText(Text("Skia").font(.system(size: 24)).foregroundColor(.red))
        let size = text.sizeThatFits(.unspecified)
        let image = try #require(text.layout.rasterize(in: size, scale: 2))
        #expect(image.width > Int(size.width * 2))
        #expect(image.pixels.enumerated().contains { $0.offset % 4 == 3 && $0.element > 0 })
        try withSurface { surface, updater in
            let item = DisplayList.Item(
                .content(.init(.text(StyledTextContentView(text: text), size), seed: .init(decodedValue: 1))),
                frame: CGRect(origin: CGPoint(x: 10, y: 10), size: size),
                identity: .init(decodedValue: 1), version: .init(decodedValue: 1)
            )
            updater.render(DisplayList(item), scale: 1)
            let colored = (0..<100).contains { y in
                (0..<100).contains { x in
                    let rgba = pixel(surface, x: Int32(x), y: Int32(y))
                    return rgba[0] > 180 && rgba[1] < 100 && rgba[2] < 100
                }
            }
            #expect(colored)
        }
    }

    private func resolveText(_ text: Text, environment: EnvironmentValues = .init()) -> BackendResolvedStyledText {
        BackendResolvedStyledText.resolve(text, environment: environment, backend: SkiaTextLayoutBackend(),
            options: [], idiom: nil, archiveOptions: .init()) as! BackendResolvedStyledText
    }

    @Test
    func mouseTapUpdatesStateAndDisplayList() throws {
        try withTapHost { host in
            #expect(colors(host) == resolved([.red, .blue]))
            mouse(host, type: SDL_EVENT_MOUSE_BUTTON_DOWN, y: 100)
            #expect(colors(host) == resolved([.red, .blue]))
            mouse(host, type: SDL_EVENT_MOUSE_BUTTON_UP, y: 100)
            #expect(colors(host) == resolved([.green, .blue]))
            click(host, y: 100)
            #expect(colors(host) == resolved([.red, .blue]))
        }
    }

    @Test
    func mouseDoubleTapKeepsItsSequence() throws {
        try withTapHost { host in
            click(host, y: 350)
            #expect(colors(host) == resolved([.red, .blue]))
            click(host, y: 350, clicks: 2)
            #expect(colors(host) == resolved([.red, .yellow]))
            click(host, y: 350)
            click(host, y: 350, clicks: 2)
            #expect(colors(host) == resolved([.red, .blue]))
        }
    }

    @Test
    func mouseDoubleTapExpiresAndRecovers() throws {
        try withTapHost { host in
            click(host, y: 350)
            Thread.sleep(forTimeInterval: 0.45)
            click(host, y: 350, clicks: 2)
            #expect(colors(host) == resolved([.red, .blue]))
            click(host, y: 350)
            click(host, y: 350, clicks: 2)
            #expect(colors(host) == resolved([.red, .yellow]))
        }
    }

    @Test
    func mouseTapHonorsHitTestingAndButton() throws {
        try withTapHost { host in
            click(host, y: 240)
            click(host, y: 100, button: UInt8(SDL_BUTTON_RIGHT))
            mouse(host, type: SDL_EVENT_MOUSE_BUTTON_DOWN, y: 100, windowID: host.windowID &+ 1)
            mouse(host, type: SDL_EVENT_MOUSE_BUTTON_UP, y: 100, windowID: host.windowID &+ 1)
            #expect(colors(host) == resolved([.red, .blue]))
            click(host, y: 100)
            #expect(colors(host) == resolved([.green, .blue]))
        }
    }

    @Test
    func movementAndFocusLossCancelTap() throws {
        try withTapHost { host in
            mouse(host, type: SDL_EVENT_MOUSE_BUTTON_DOWN, y: 100)
            var motion = SDL_Event()
            motion.motion.type = SDL_EVENT_MOUSE_MOTION
            motion.motion.windowID = host.windowID
            motion.motion.x = 500
            motion.motion.y = 100
            motion.motion.state = 1
            host.handle(motion)
            mouse(host, type: SDL_EVENT_MOUSE_BUTTON_UP, y: 100)
            #expect(colors(host) == resolved([.red, .blue]))

            mouse(host, type: SDL_EVENT_MOUSE_BUTTON_DOWN, y: 100)
            var lostFocus = SDL_Event()
            lostFocus.window.type = SDL_EVENT_WINDOW_FOCUS_LOST
            lostFocus.window.windowID = host.windowID
            host.handle(lostFocus)
            mouse(host, type: SDL_EVENT_MOUSE_BUTTON_UP, y: 100)
            #expect(colors(host) == resolved([.red, .blue]))
            click(host, y: 100)
            #expect(colors(host) == resolved([.green, .blue]))
        }
    }

    @Test
    func longMousePressDoesNotTap() throws {
        try withTapHost { host in
            mouse(host, type: SDL_EVENT_MOUSE_BUTTON_DOWN, y: 100)
            Thread.sleep(forTimeInterval: 0.8)
            mouse(host, type: SDL_EVENT_MOUSE_BUTTON_UP, y: 100)
            #expect(colors(host) == resolved([.red, .blue]))
        }
    }

    @Test
    func mouseCoordinatesUseViewPoints() throws {
        try withTapHost { host in
            #expect(SDLMouseEventSource.location(x: 320, y: 240, window: host.window,
                                                size: CGSize(width: 320, height: 240)) == CGPoint(x: 160, y: 120))
            try #require(SDL_SetWindowSize(host.window, 800, 600))
            try #require(SDL_SyncWindow(host.window))
            host.updateWindowMetrics()
            host.renderIfNeeded()
            click(host, y: 290)
            #expect(colors(host) == resolved([.green, .blue]))
            click(host, y: 300)
            #expect(colors(host) == resolved([.green, .blue]))
        }
    }

    @Test
    func windowResizeUpdatesLayout() throws {
        try #require(SDL_Init(SDL_INIT_VIDEO))
        defer { SDL_Quit() }
        let host = Update.ensure {
            SDLHostingView(
                rootView: AnyView(VStack(spacing: 10) { Color.red; Color.blue }),
                environment: EnvironmentValues(), wakeEvent: SDL_RegisterEvents(1)
            )
        }
        defer { host.close() }
        host.renderIfNeeded()
        let initial = try #require(host.viewGraph.rootDisplayList?.0.items)
        #expect(initial.map(\.frame) == [
            CGRect(x: 0, y: 0, width: 640, height: 235),
            CGRect(x: 0, y: 245, width: 640, height: 235),
        ])
        try #require(SDL_SetWindowSize(host.window, 800, 600))
        try #require(SDL_SyncWindow(host.window))
        var event = SDL_Event()
        while SDL_PollEvent(&event) { host.handle(event) }
        host.renderIfNeeded()
        let resized = try #require(host.viewGraph.rootDisplayList?.0.items)
        #expect(resized.map(\.frame) == [
            CGRect(x: 0, y: 0, width: 800, height: 295),
            CGRect(x: 0, y: 305, width: 800, height: 295),
        ])
    }

    @Test
    func scaledColorAndGap() throws {
        try withSurface { surface, updater in
            let red = content(frame: CGRect(x: 0, y: 0, width: 40, height: 20))
            let blue = content(frame: CGRect(x: 0, y: 25, width: 40, height: 20), blue: true)
            updater.render(DisplayList([red, blue]), scale: 2)
            #expect(pixel(surface, x: 10, y: 39) == [255, 0, 0, 255])
            #expect(pixel(surface, x: 10, y: 40) == [255, 255, 255, 255])
            #expect(pixel(surface, x: 10, y: 49) == [255, 255, 255, 255])
            #expect(pixel(surface, x: 10, y: 50) == [0, 0, 255, 255])
            #expect(pixel(surface, x: 80, y: 50) == [255, 255, 255, 255])
        }
    }

    @Test
    func nestedOriginAndAffineTransform() throws {
        try withSurface { surface, updater in
            let child = content(frame: CGRect(x: 1, y: 2, width: 3, height: 4))
            let group = DisplayList.Item(
                .effect(.transform(.affine(CGAffineTransform(scaleX: 2, y: 2))), DisplayList(child)),
                frame: CGRect(x: 30, y: 5, width: 20, height: 20),
                identity: .init(decodedValue: 2), version: .init(decodedValue: 2)
            )
            updater.render(DisplayList(group), scale: 1)
            #expect(pixel(surface, x: 32, y: 9) == [255, 0, 0, 255])
            #expect(pixel(surface, x: 37, y: 16) == [255, 0, 0, 255])
            #expect(pixel(surface, x: 31, y: 9) == [255, 255, 255, 255])
            #expect(pixel(surface, x: 38, y: 16) == [255, 255, 255, 255])
        }
    }

    @Test
    func opacityAndReplacementFrame() throws {
        try withSurface { surface, updater in
            let child = content(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
            let group = DisplayList.Item(
                .effect(.opacity(0.5), DisplayList(child)),
                frame: CGRect(x: 0, y: 0, width: 20, height: 20),
                identity: .init(decodedValue: 2), version: .init(decodedValue: 2)
            )
            updater.render(DisplayList(group), scale: 1)
            let rgba = pixel(surface, x: 10, y: 10)
            #expect(rgba[0] == 255)
            #expect((127...128).contains(rgba[1]))
            #expect((127...128).contains(rgba[2]))
            updater.render(DisplayList(), scale: 1)
            #expect(pixel(surface, x: 10, y: 10) == [255, 255, 255, 255])
        }
    }

    private func content(frame: CGRect, blue: Bool = false) -> DisplayList.Item {
        let color = Color.Resolved(colorSpace: .sRGB, red: blue ? 0 : 1, green: 0, blue: blue ? 1 : 0)
        return .init(.content(.init(.color(color), seed: .init(decodedValue: 1))),
                     frame: frame, identity: .init(decodedValue: 1), version: .init(decodedValue: 1))
    }

    private func withTapHost(rootView: AnyView = AnyView(SDLTapTestView()), _ body: (SDLHostingView) throws -> Void) throws {
        try #require(SDL_Init(SDL_INIT_VIDEO))
        defer { SDL_Quit() }
        let host = Update.ensure {
            SDLHostingView(rootView: rootView, environment: EnvironmentValues(),
                           wakeEvent: SDL_RegisterEvents(1))
        }
        defer { host.close() }
        host.renderIfNeeded()
        try body(host)
    }

    private func colors(_ host: SDLHostingView) -> [Color.Resolved] {
        RunLoop.flushObservers()
        host.renderIfNeeded()
        return (host.viewGraph.rootDisplayList?.0.items ?? []).compactMap { item in
            guard case let .content(content) = item.value,
                  case let .color(color) = content.value else { return nil }
            return color
        }
    }

    private func resolved(_ colors: [Color]) -> [Color.Resolved] {
        colors.map { $0.resolve(in: EnvironmentValues()) }
    }

    private func mouse(_ host: SDLHostingView, type: SDL_EventType, y: Float,
                       clicks: UInt8 = 1, button: UInt8 = UInt8(SDL_BUTTON_LEFT), windowID: SDL_WindowID? = nil) {
        var event = SDL_Event()
        event.button.type = type
        event.button.timestamp = SDL_GetTicksNS()
        event.button.windowID = windowID ?? host.windowID
        event.button.button = button
        event.button.down = type == SDL_EVENT_MOUSE_BUTTON_DOWN
        event.button.clicks = clicks
        event.button.x = 320
        event.button.y = y
        host.handle(event)
    }

    private func click(_ host: SDLHostingView, y: Float, clicks: UInt8 = 1,
                       button: UInt8 = UInt8(SDL_BUTTON_LEFT)) {
        mouse(host, type: SDL_EVENT_MOUSE_BUTTON_DOWN, y: y, clicks: clicks, button: button)
        mouse(host, type: SDL_EVENT_MOUSE_BUTTON_UP, y: y, clicks: clicks, button: button)
    }

    private func withSurface(_ body: (UnsafeMutablePointer<SDL_Surface>, SDLViewUpdater) throws -> Void) throws {
        try #require(SDL_Init(SDL_INIT_VIDEO))
        defer { SDL_Quit() }
        let surface = try #require(SDL_CreateSurface(100, 100, SDL_PIXELFORMAT_RGBA8888))
        defer { SDL_DestroySurface(surface) }
        let context = try #require(SDL_CreateSoftwareRenderer(surface))
        let updater = SDLViewUpdater(context: context)
        defer { updater.destroy() }
        try body(surface, updater)
    }

    private func pixel(_ surface: UnsafeMutablePointer<SDL_Surface>, x: Int32, y: Int32) -> [UInt8] {
        var r: UInt8 = 0, g: UInt8 = 0, b: UInt8 = 0, a: UInt8 = 0
        #expect(SDL_ReadSurfacePixel(surface, x, y, &r, &g, &b, &a))
        return [r, g, b, a]
    }
}

private struct SDLTextTapTestView: View {
    @State private var expanded = false

    var body: some View {
        Text(expanded ? "One two three four" : "One")
            .font(.system(size: 24))
            .onTapGesture { expanded.toggle() }
            .frame(width: 640, height: 480)
    }
}

private struct SDLTapTestView: View {
    @State private var top = false
    @State private var bottom = false

    var body: some View {
        VStack(spacing: 10) {
            (top ? Color.green : Color.red).onTapGesture { top.toggle() }
            (bottom ? Color.yellow : Color.blue).onTapGesture(count: 2) { bottom.toggle() }
        }
    }
}
#endif
