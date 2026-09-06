//
//  LayoutTests.swift
//  OpenSwiftUIEmbeddedTests

import OpenSwiftUI

struct LayoutRecord {
    let rect: EmbeddedRect
    let color: UInt32
}

struct LayoutSink: EmbeddedRenderSink {
    var records: [LayoutRecord] = []
    var textMeasurements = 0
    mutating func measureImage(_ name: StaticString) -> EmbeddedSize { .init(width: 16, height: 16) }
    mutating func measureText(_ text: StaticString, proposal: ProposedViewSize) -> EmbeddedSize {
        textMeasurements += 1
        // Deliberate 5x10 host font fixture, including width-dependent wrapping.
        let natural = Int32(text.utf8CodeUnitCount) * 5
        let width = min(natural, proposal.width ?? natural)
        return .init(width: width, height: natural == 0 ? 0 : ((natural + max(1, width) - 1) / max(1, width)) * 10)
    }
    mutating func fill(_ rect: EmbeddedRect, color: Color) { records.append(.init(rect: rect, color: color.rgb)) }
    mutating func image(_ name: StaticString, in rect: EmbeddedRect) { records.append(.init(rect: rect, color: 0)) }
    mutating func text(_ text: StaticString, in rect: EmbeddedRect, color: Color) { records.append(.init(rect: rect, color: color.rgb)) }
}

struct OptionalChildren: View {
    let visible: Bool
    var body: some View {
        Color.red.frame(width: 20, height: 10)
        if visible { Color.green.frame(width: 10, height: 30) }
        if visible { Color.yellow.frame(width: 10, height: 10) } else { EmptyView() }
        Color.blue.frame(width: 40, height: 20)
    }
}

/// A client-defined layout proves measurement and placement cross the module boundary.
struct ReverseRow: Layout {
    typealias Cache = [EmbeddedSize]
    func makeCache<Content: View, Sink: EmbeddedRenderSink>(subviews: inout LayoutSubviews<Content, Sink>) -> Cache { [] }
    func sizeThatFits<Content: View, Sink: EmbeddedRenderSink>(proposal: ProposedViewSize, subviews: inout LayoutSubviews<Content, Sink>, cache: inout Cache) -> EmbeddedSize {
        cache.removeAll(keepingCapacity: true)
        var width: Int32 = 0, height: Int32 = 0
        for index in 0..<subviews.count {
            let size = subviews.sizeThatFits(index, proposal: .unspecified)
            cache.append(size)
            width += size.width; height = max(height, size.height)
        }
        return .init(width: width, height: height)
    }
    func placeSubviews<Content: View, Sink: EmbeddedRenderSink>(in bounds: EmbeddedRect, proposal: ProposedViewSize, subviews: inout LayoutSubviews<Content, Sink>, cache: inout Cache) {
        var x = bounds.x
        for index in (0..<subviews.count).reversed() {
            subviews.place(index, x: x, y: bounds.y, proposal: ProposedViewSize(cache[index]))
            x += cache[index].width
        }
    }
}

@main
enum LayoutTests {
    static func render<V: View>(_ view: V, width: Int32 = 100, height: Int32 = 100, insets: EdgeInsets = .init()) -> LayoutSink {
        var sink = LayoutSink()
        EmbeddedRenderer.render(view, rootGeometry: RootGeometry(screenSize: .init(width: width, height: height), safeAreaInsets: insets), to: &sink)
        return sink
    }
    static func main() {
        let root = RootGeometry(screenSize: .init(width: 240, height: 320), safeAreaInsets: .init(top: 66, leading: 12, bottom: 30, trailing: 12))
        precondition(root.contentBounds == .init(x: 12, y: 66, width: 216, height: 224))
        var fill = LayoutSink()
        EmbeddedRenderer.render(Color.blue, rootGeometry: root, to: &fill)
        precondition(fill.records[0].rect == root.contentBounds)

        let v = render(VStack(alignment: .leading, spacing: 4) {
            Color.red.frame(width: 20, height: 10)
            Color.blue.frame(width: 40, height: 20)
        }, insets: .init(top: 10, leading: 10, bottom: 10, trailing: 10))
        precondition(v.records.count == 2)
        precondition(v.records[0].rect == .init(x: 30, y: 33, width: 20, height: 10))
        precondition(v.records[1].rect == .init(x: 30, y: 47, width: 40, height: 20))
        let trailing = render(VStack(alignment: .trailing, spacing: 4) { OptionalChildren(visible: false) })
        precondition(trailing.records.count == 2)
        precondition(trailing.records[0].rect == .init(x: 50, y: 33, width: 20, height: 10))
        precondition(trailing.records[1].rect == .init(x: 30, y: 47, width: 40, height: 20))
        let present = render(VStack(spacing: 4) { OptionalChildren(visible: true) })
        precondition(present.records.count == 4)
        precondition(present.records[0].rect.y == 9 && present.records[1].rect.y == 23)
        precondition(present.records[2].rect.y == 57 && present.records[3].rect.y == 71)

        let h = render(HStack(alignment: .bottom, spacing: 3) {
            Color.red.frame(width: 10, height: 20)
            Color.blue.frame(width: 20, height: 10)
        })
        precondition(h.records[0].rect == .init(x: 33, y: 40, width: 10, height: 20))
        precondition(h.records[1].rect == .init(x: 46, y: 50, width: 20, height: 10))
        let flexible = render(VStack(spacing: 4) {
            Color.blue
            Color.red.frame(width: 20, height: 20)
        })
        precondition(flexible.records[0].rect == .init(x: 0, y: 0, width: 100, height: 76))
        precondition(flexible.records[1].rect == .init(x: 40, y: 80, width: 20, height: 20))
        let remainder = render(HStack(spacing: 0) { Color.red; Color.blue }, width: 101, height: 20)
        precondition(remainder.records[0].rect.width == 50 && remainder.records[1].rect.width == 51)
        precondition(remainder.records[1].rect.x == 50)
        let overflow = render(VStack(spacing: 4) {
            Color.red.frame(width: 20, height: 40)
            Color.blue.frame(width: 20, height: 40)
        }, height: 60)
        precondition(overflow.records[0].rect.y == -12 && overflow.records[1].rect.y == 32)
        let empty = render(VStack { EmptyView() })
        precondition(empty.records.isEmpty)

        let narrow = render(Text("0123456789"), width: 30, height: 80)
        let wide = render(Text("0123456789"), width: 60, height: 80)
        precondition(narrow.records[0].rect == .init(x: 0, y: 30, width: 30, height: 20))
        precondition(wide.records[0].rect == .init(x: 5, y: 35, width: 50, height: 10))
        precondition(narrow.textMeasurements > 0 && wide.textMeasurements > 0)
        let natural = render(Image("badge").frame(width: 80, height: 80), width: 80, height: 80)
        precondition(natural.records[0].rect == .init(x: 32, y: 32, width: 16, height: 16))
        let scaled = render(Image("badge").resizable().frame(width: 80, height: 80), width: 80, height: 80)
        precondition(scaled.records[0].rect == .init(width: 80, height: 80))
        let padded = render(Color.red.frame(width: 20, height: 10).padding(5).background(Color.blue))
        precondition(padded.records[0].rect == .init(x: 35, y: 40, width: 30, height: 20))
        precondition(padded.records[1].rect == .init(x: 40, y: 45, width: 20, height: 10))
        let offset = render(VStack(spacing: 0) {
            Color.red.frame(width: 20, height: 10).offset(x: 7)
            Color.blue.frame(width: 20, height: 10)
        })
        precondition(offset.records[0].rect == .init(x: 47, y: 40, width: 20, height: 10))
        precondition(offset.records[1].rect == .init(x: 40, y: 50, width: 20, height: 10))

        let custom = render(ReverseRow() {
            Color.red.frame(width: 10, height: 20)
            Color.blue.frame(width: 30, height: 10)
        })
        precondition(custom.records[0].color == 0x0000ff && custom.records[0].rect == .init(x: 30, y: 40, width: 30, height: 10))
        precondition(custom.records[1].color == 0xff0000 && custom.records[1].rect == .init(x: 60, y: 40, width: 10, height: 20))
        print("Embedded layout: PASS (root geometry, changing proposals, stacks/alignment, flexibility/remainder, optional children, wrapping, intrinsic/resizable images, modifiers, custom Layout)")
    }
}
