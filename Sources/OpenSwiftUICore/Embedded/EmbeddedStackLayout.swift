//
//  EmbeddedStackLayout.swift
//  OpenSwiftUICore

#if OPENSWIFTUI_LVGL && hasFeature(Embedded)
public struct _EmbeddedStackCache {
    var sizes: [EmbeddedSize] = []
    var proposals: [ProposedViewSize] = []
}

struct EmbeddedStackLayout {
    let vertical: Bool
    let spacing: Int32
    let alignment: Alignment
    func major(_ size: EmbeddedSize) -> Int32 { vertical ? size.height : size.width }
    func minor(_ size: EmbeddedSize) -> Int32 { vertical ? size.width : size.height }
    func proposal(major: Int32?, cross: Int32?) -> ProposedViewSize {
        vertical ? .init(width: cross, height: major) : .init(width: major, height: cross)
    }
    func measure<Content: View, Sink: EmbeddedRenderSink>(_ offered: ProposedViewSize, subviews: inout LayoutSubviews<Content, Sink>, cache: inout _EmbeddedStackCache) -> EmbeddedSize {
        let count = subviews.count
        guard count > 0 else { cache = .init(); return .zero }
        let available = vertical ? offered.height : offered.width
        let cross = vertical ? offered.width : offered.height
        cache.sizes = Array(repeating: .zero, count: count)
        cache.proposals = Array(repeating: .unspecified, count: count)
        // Allocate less-flexible children first. Stable order breaks ties.
        var flexibility = Array(repeating: Int32(0), count: count)
        var order = Array(0..<count)
        if available != nil {
            for index in 0..<count {
                let minimum = subviews.sizeThatFits(index, proposal: proposal(major: 0, cross: cross))
                let maximum = subviews.sizeThatFits(index, proposal: proposal(major: 32767, cross: cross))
                flexibility[index] = max(0, major(maximum) - major(minimum))
            }
            for end in 1..<count {
                var index = end
                while index > 0 && flexibility[order[index]] < flexibility[order[index - 1]] {
                    order.swapAt(index, index - 1); index -= 1
                }
            }
        }
        let gaps = spacing * Int32(count - 1)
        var remaining = max(0, (available ?? 0) - gaps)
        for position in 0..<count {
            let index = order[position]
            let p = proposal(major: available == nil ? nil : remaining / Int32(count - position), cross: cross)
            let size = subviews.sizeThatFits(index, proposal: p)
            cache.proposals[index] = p
            cache.sizes[index] = size
            remaining = max(0, remaining - major(size))
        }
        var main = gaps, other: Int32 = 0
        for size in cache.sizes { main += major(size); other = max(other, minor(size)) }
        return vertical ? .init(width: other, height: main) : .init(width: main, height: other)
    }
    func place<Content: View, Sink: EmbeddedRenderSink>(_ bounds: EmbeddedRect, subviews: inout LayoutSubviews<Content, Sink>, cache: _EmbeddedStackCache) {
        var cursor = vertical ? bounds.y : bounds.x
        for index in 0..<subviews.count {
            let size = cache.sizes[index]
            let aligned = alignment.rect(size: size, in: bounds)
            subviews.place(index, x: vertical ? aligned.x : cursor, y: vertical ? cursor : aligned.y, proposal: cache.proposals[index])
            cursor += major(size) + spacing
        }
    }
}
#endif
