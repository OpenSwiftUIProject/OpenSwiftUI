//
//  InputTests.swift
//  OpenSwiftUIEmbeddedTests

import OpenSwiftUI

struct InputSink: EmbeddedRenderSink {
    var rects: [EmbeddedRect] = []
    var colors: [UInt32] = []
    mutating func measureImage(_ name: StaticString) -> EmbeddedSize { .zero }
    mutating func measureText(_ text: StaticString, proposal: ProposedViewSize) -> EmbeddedSize { .zero }
    mutating func fill(_ rect: EmbeddedRect, color: Color) { rects.append(rect); colors.append(color.rgb) }
    mutating func image(_ name: StaticString, in rect: EmbeddedRect) {}
    mutating func text(_ text: StaticString, in rect: EmbeddedRect, color: Color) {}
}

struct InteractiveView: View {
    @State private var width: Int32 = 10
    @State private var visible = true
    var body: some View {
        // A value captured by the freshly evaluated body must not become stale.
        let previousWidth = width
        VStack(spacing: 3) {
            Color.red.frame(width: width, height: 5)
                .onPhyicButton(.upArrow) { width = previousWidth + 1 }
                .frame(height: 5).padding(0).offset()
                .background(Color.clear)
            if visible {
                HStack {
                    Color.green.frame(width: 2, height: 5)
                        .onPhyicButton(.downArrow) { width -= 1 }
                }
            }
            if visible {
                Color.blue.frame(width: 1, height: 5)
            } else {
                ZStack {
                    Color.yellow.frame(width: 1, height: 5)
                        .onPhyicButton(.downArrow) { width = 20 }
                }
            }
        }.onPhyicButton(.select) { visible.toggle() }
    }
}

final class Counter { var value = 0 }
final class LifetimeToken {
    let counter: Counter
    init(_ counter: Counter) { self.counter = counter }
    deinit { counter.value += 1 }
}
struct LifetimeView: View {
    @State private var token: LifetimeToken
    init(_ counter: Counter) { _token = State(wrappedValue: LifetimeToken(counter)) }
    var body: some View { Color.red.onPhyicButton(.select) { _ = token.counter.value } }
}
struct PairView: View {
    var body: some View {
        Color.red.frame(width: 4, height: 5)
        Color.green.frame(width: 4, height: 7)
    }
}

@main
enum InputTests {
    static let geometry = RootGeometry(screenSize: .init(width: 100, height: 100))
    static func render<C: View>(_ host: EmbeddedViewHost<C>) -> InputSink {
        var sink = InputSink()
        host.render(rootGeometry: geometry, to: &sink)
        precondition(!host.needsRender)
        return sink
    }
    static func main() {
        let host = EmbeddedViewHost { InteractiveView() }
        let other = EmbeddedViewHost { InteractiveView() }
        precondition(host.needsRender)
        precondition(render(host).rects[0].width == 10)
        _ = render(other)
        for expected: Int32 in [11, 12, 13] {
            precondition(host.send(.upArrow) && host.needsRender && !other.needsRender)
            precondition(render(host).rects[0].width == expected)
        }
        precondition(host.send(.downArrow))
        precondition(render(host).rects[0].width == 12)
        precondition(host.send(.select))
        let hidden = render(host)
        precondition(hidden.rects.count == 2 && hidden.colors[1] == 0xffff00)
        precondition(host.send(.downArrow))
        precondition(render(host).rects[0].width == 20) // Only the active branch ran.
        precondition(render(other).rects[0].width == 10)
        host.invalidate()
        precondition(host.needsRender)
        precondition(render(host).rects[0].width == 20)

        let counter = Counter()
        let priority = EmbeddedViewHost {
            VStack {
                Color.red.onPhyicButton(.upArrow) { counter.value += 1 }
                Color.blue.onPhyicButton(.upArrow) { counter.value += 100 }
            }
            .onPhyicButton(.select) { counter.value += 10 }
            .onPhyicButton(.select) { counter.value += 1000 }
        }
        _ = render(priority)
        precondition(!priority.send(.downArrow) && !priority.needsRender)
        precondition(priority.send(.upArrow) && counter.value == 1)
        precondition(priority.send(.select) && counter.value == 1001)
        precondition(!priority.needsRender) // Closures without State writes don't redraw.

        let transparent = EmbeddedViewHost {
            VStack(spacing: 3) { PairView().onPhyicButton(.upArrow) {} }
        }
        let pair = render(transparent)
        precondition(pair.rects.count == 2)
        precondition(pair.rects[1].y - pair.rects[0].y == 8)
        // Long-lived repeated actions must retain state without retaining body closures.
        for _ in 0..<500 {
            precondition(host.send(.select))
            _ = render(host)
        }
        precondition(render(host).rects[0].width == 20)
        let destroyed = Counter()
        for _ in 0..<100 {
            let transient = EmbeddedViewHost { LifetimeView(destroyed) }
            precondition(transient.send(.select))
            _ = render(transient)
        }
        precondition(destroyed.value == 100)
        print("Embedded input: PASS (State lifetime/isolation, fresh closures, routing, branches, layout transparency, teardown)")
    }
}
