//
//  EmbeddedDisplayList.swift
//  OpenSwiftUICore

#if OPENSWIFTUI_LVGL && hasFeature(Embedded)
package struct EmbeddedDrawCommand {
    enum Kind { case fill, image, text }
    var key: UInt64
    var kind: Kind
    var rect: EmbeddedRect
    var color: Color
    var name: StaticString
    var transition: AnyTransition
    var transitionBounds: EmbeddedRect

    func draw<Sink: EmbeddedRenderSink>(to sink: inout Sink) {
        switch kind {
        case .fill: sink.fill(rect, color: color)
        case .image: sink.image(name, in: rect)
        case .text: sink.text(name, in: rect, color: color)
        }
    }
    func insertionStart() -> Self {
        var result = self
        if transition.fades && kind != .image { result.color = .init(rgb: color.rgb, alpha: 0) }
        if transition.scale && kind != .text {
            let b = transitionBounds
            result.rect = .init(x: b.x + b.width / 2 + (rect.x - b.x - b.width / 2) * 3 / 4,
                                y: b.y + b.height / 2 + (rect.y - b.y - b.height / 2) * 3 / 4,
                                width: max(1, rect.width * 3 / 4), height: max(1, rect.height * 3 / 4))
        }
        return result
    }
    func interpolated(from old: Self, progress: Int32) -> Self {
        var value = self
        func mix(_ a: Int32, _ b: Int32) -> Int32 { a + Int32(Int64(b - a) * Int64(progress) / 1024) }
        value.rect = .init(x: mix(old.rect.x, rect.x), y: mix(old.rect.y, rect.y),
                           width: max(1, mix(old.rect.width, rect.width)), height: max(1, mix(old.rect.height, rect.height)))
        var rgb: UInt32 = 0
        for shift in [16, 8, 0] {
            rgb |= UInt32(mix(Int32((old.color.rgb >> shift) & 255), Int32((color.rgb >> shift) & 255))) << shift
        }
        value.color = .init(rgb: rgb, alpha: UInt8(mix(Int32(old.color.alpha), Int32(color.alpha))))
        return value
    }
}

package final class EmbeddedRecordingSink<Base: EmbeddedRenderSink>: EmbeddedRenderSink {
    var base: Base
    var commands: [EmbeddedDrawCommand] = []
    private var identity: UInt32 = 0
    private var ordinal: UInt32 = 0
    private var identities: [(UInt32, UInt32)] = []
    private var transitions: [(AnyTransition, EmbeddedRect)] = []
    init(base: Base) { self.base = base }
    package func measureImage(_ name: StaticString) -> EmbeddedSize { base.measureImage(name) }
    package func measureText(_ text: StaticString, proposal: ProposedViewSize) -> EmbeddedSize { base.measureText(text, proposal: proposal) }
    package func beginIdentity(_ id: UInt32) {
        precondition(identities.count < 16)
        identities.append((identity, ordinal)); identity = id; ordinal = 0
    }
    package func endIdentity() { let old = identities.removeLast(); identity = old.0; ordinal = old.1 }
    package func beginTransition(_ transition: AnyTransition, in rect: EmbeddedRect) {
        precondition(transitions.count < 16)
        transitions.append((transition, rect))
    }
    package func endTransition() { transitions.removeLast() }
    package func fill(_ rect: EmbeddedRect, color: Color) { append(.fill, rect, color, "") }
    package func image(_ name: StaticString, in rect: EmbeddedRect) { append(.image, rect, .white, name) }
    package func text(_ text: StaticString, in rect: EmbeddedRect, color: Color) { append(.text, rect, color, text) }
    private func append(_ kind: EmbeddedDrawCommand.Kind, _ rect: EmbeddedRect, _ color: Color, _ name: StaticString) {
        precondition(commands.count < 128, "Embedded display list limit exceeded")
        let key = UInt64(identity) << 32 | UInt64(ordinal)
        precondition(!commands.contains { $0.key == key }, "Duplicate Embedded drawing identity")
        ordinal += 1
        let transition = transitions.last
        commands.append(.init(key: key, kind: kind, rect: rect, color: color, name: name,
                              transition: transition?.0 ?? .identity, transitionBounds: transition?.1 ?? rect))
    }
}

package struct EmbeddedAnimationState {
    private var source: [EmbeddedDrawCommand] = []
    private var target: [EmbeddedDrawCommand] = []
    private var animation: Animation?
    private var elapsed: UInt32 = 0
    private var hasTarget = false
    private(set) var dirty = false
    var isAnimating: Bool { animation != nil }
    mutating func advance(by milliseconds: UInt32) {
        guard let animation else { return }
        elapsed = UInt32(min(UInt64(animation.milliseconds), UInt64(elapsed) + UInt64(milliseconds)))
        dirty = true
    }
    private func presented(_ index: Int) -> EmbeddedDrawCommand {
        guard let animation else { return target[index] }
        return target[index].interpolated(from: source[index], progress: animation.progress(at: elapsed))
    }
    mutating func setTarget(_ commands: [EmbeddedDrawCommand], animation: Animation?) {
        var starts: [EmbeddedDrawCommand] = []
        if let animation, animation.milliseconds > 0, hasTarget {
            for command in commands {
                if let index = target.firstIndex(where: { $0.key == command.key && $0.kind == command.kind }) {
                    starts.append(presented(index))
                } else {
                    starts.append(command.insertionStart())
                }
            }
            self.animation = animation
        } else { self.animation = nil }
        source = starts
        target = commands
        hasTarget = true
        elapsed = 0
        dirty = true
    }
    mutating func draw<Sink: EmbeddedRenderSink>(to sink: inout Sink) {
        for index in target.indices { presented(index).draw(to: &sink) }
        dirty = false
        if let animation, elapsed >= animation.milliseconds {
            self.animation = nil
            source.removeAll(keepingCapacity: true)
        }
    }
}
#endif
