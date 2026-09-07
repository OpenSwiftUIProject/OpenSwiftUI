//
//  AnimationTests.swift
//  OpenSwiftUIEmbeddedTests

import OpenSwiftUI

struct AnimationSink: EmbeddedRenderSink {
    var rects: [EmbeddedRect] = []
    var colors: [Color] = []
    mutating func measureImage(_ name: StaticString) -> EmbeddedSize { .init(width: 10, height: 10) }
    mutating func measureText(_ text: StaticString, proposal: ProposedViewSize) -> EmbeddedSize { .init(width: 10, height: 10) }
    mutating func fill(_ rect: EmbeddedRect, color: Color) { rects.append(rect); colors.append(color) }
    mutating func image(_ name: StaticString, in rect: EmbeddedRect) { rects.append(rect) }
    mutating func text(_ text: StaticString, in rect: EmbeddedRect, color: Color) { fill(rect, color: color) }
}

final class BodyCounter { var value = 0 }
struct AnimatedFixture: View {
    @State private var width: Int32 = 10
    @State private var visible = false
    let evaluations: BodyCounter
    var body: some View {
        let _ = evaluations.value += 1
        HStack(spacing: 0) {
            Color.red.frame(width: width, height: 20).id(1)
            if visible {
                Color.blue.frame(width: 20, height: 20)
                    .transition(.scale.combined(with: .opacity)).id(2)
            }
        }
    }
    func resize(_ width: Int32) { self.width = width }
    func insert() { visible = true }
}

struct ReorderedFixture: View {
    @State private var reversed = false
    var body: some View {
        HStack(spacing: 0) {
            (reversed ? Color.blue : Color.red).frame(width: 20, height: 20).id(reversed ? 2 : 1)
            (reversed ? Color.red : Color.blue).frame(width: 20, height: 20).id(reversed ? 1 : 2)
        }
    }
    func swap() { reversed.toggle() }
}

struct EmptyAnimationFixture: View {
    @State private var visible = false
    var body: some View {
        if visible { Color.red.frame(width: 20, height: 20).transition(.opacity).id(8) }
    }
    func toggle() { visible.toggle() }
}

@main
enum AnimationTests {
    static let geometry = RootGeometry(screenSize: .init(width: 100, height: 100), centersRootView: false)
    static func render<C: View>(_ host: EmbeddedViewHost<C>, geometry: RootGeometry = geometry) -> AnimationSink {
        var sink = AnimationSink()
        host.render(rootGeometry: geometry, to: &sink)
        return sink
    }
    static func main() {
        let counter = BodyCounter()
        let host = EmbeddedViewHost { AnimatedFixture(evaluations: counter) }
        precondition(render(host).rects[0].width == 10 && !host.isAnimating)
        host.update { view in withAnimation(.linear(duration: 0.1)) { view.resize(30) } }
        precondition(render(host).rects[0].width == 10 && host.isAnimating)
        let evaluations = counter.value
        host.advanceAnimation(byMilliseconds: 50)
        precondition(render(host).rects[0].width == 20)
        precondition(counter.value == evaluations) // No body/layout reevaluation on a frame.
        host.update { view in withAnimation(.linear(duration: 0.1)) { view.resize(40) } }
        precondition(render(host).rects[0].width == 20) // Interrupt from presentation, no jump.
        host.advanceAnimation(byMilliseconds: 50)
        precondition(render(host).rects[0].width == 30)
        host.advanceAnimation(byMilliseconds: .max)
        precondition(render(host).rects[0].width == 40 && !host.isAnimating && !host.needsRender)
        host.advanceAnimation(byMilliseconds: 10)
        precondition(!host.needsRender)

        host.update { view in withAnimation(.linear(duration: 0.1)) { view.insert() } }
        let inserted = render(host)
        precondition(inserted.rects[1].width == 15 && inserted.colors[1].alpha == 0)
        host.advanceAnimation(byMilliseconds: 50)
        let halfway = render(host)
        precondition(halfway.rects[1].width == 17 && halfway.colors[1].alpha == 127)
        host.advanceAnimation(byMilliseconds: 50)
        precondition(render(host).rects[1].width == 20 && !host.isAnimating)

        host.update { view in withAnimation { withAnimation(nil) { view.resize(5) } } }
        precondition(render(host).rects[0].width == 5 && !host.isAnimating)
        host.update { view in withAnimation(.linear(duration: 0)) { view.resize(7) } }
        precondition(render(host).rects[0].width == 7 && !host.isAnimating)
        host.update { view in withAnimation(.easeOut(duration: 0.1)) { view.resize(15) } }
        _ = render(host)
        host.advanceAnimation(byMilliseconds: 50)
        precondition(render(host).rects[0].width == 14) // Cubic ease-out reaches 7/8.
        let resized = RootGeometry(screenSize: .init(width: 200, height: 200), centersRootView: false)
        precondition(render(host, geometry: resized).rects[0].width == 15 && !host.isAnimating)

        let reordered = EmbeddedViewHost { ReorderedFixture() }
        _ = render(reordered)
        reordered.update { view in withAnimation(.linear(duration: 0.1)) { view.swap() } }
        let start = render(reordered)
        precondition(start.colors[0].rgb == 0x0000ff && start.rects[0].x == 20)
        reordered.advanceAnimation(byMilliseconds: 50)
        let middle = render(reordered)
        precondition(middle.rects[0].x == 10 && middle.rects[1].x == 10)
        reordered.advanceAnimation(byMilliseconds: 50)
        precondition(render(reordered).rects[0].x == 0)
        precondition(!host.isAnimating) // Other hosts are isolated.
        let empty = EmbeddedViewHost { EmptyAnimationFixture() }
        precondition(render(empty).rects.isEmpty)
        empty.update { view in withAnimation(.linear(duration: 0.1)) { view.toggle() } }
        precondition(render(empty).colors[0].alpha == 0 && empty.isAnimating)
        empty.advanceAnimation(byMilliseconds: 100)
        precondition(render(empty).colors[0].alpha == 255 && !empty.isAnimating)
        empty.update { $0.toggle() }
        precondition(render(empty).rects.isEmpty && !empty.isAnimating)
        print("Embedded animation: PASS (layout interpolation, identity, insertion, interruption, clock, scopes, zero duration, geometry changes, cached frames)")
    }
}
