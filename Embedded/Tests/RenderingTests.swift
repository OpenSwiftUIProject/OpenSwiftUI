//
//  RenderingTests.swift
//  OpenSwiftUIEmbeddedTests

import OpenSwiftUI

struct DrawRecord {
    let kind: UInt8
    let rect: EmbeddedRect
    let rgb: UInt32
    let alpha: UInt8
    let bytes: Int
}

struct RecordingSink: EmbeddedRenderSink {
    var records: [DrawRecord] = []
    mutating func measureImage(_ name: StaticString) -> EmbeddedSize { .init(width: 16, height: 16) }
    mutating func measureText(_ text: StaticString, proposal: ProposedViewSize) -> EmbeddedSize { .init(width: 35, height: 10) }
    mutating func fill(_ rect: EmbeddedRect, color: Color) {
        records.append(DrawRecord(kind: 0, rect: rect, rgb: color.rgb, alpha: color.alpha, bytes: 0))
    }
    mutating func image(_ name: StaticString, in rect: EmbeddedRect) {
        precondition(name.utf8CodeUnitCount == 5 && name.utf8Start[0] == 98)
        records.append(DrawRecord(kind: 1, rect: rect, rgb: 0, alpha: 0, bytes: name.utf8CodeUnitCount))
    }
    mutating func text(_ text: StaticString, in rect: EmbeddedRect, color: Color) {
        records.append(DrawRecord(kind: 2, rect: rect, rgb: color.rgb, alpha: color.alpha, bytes: text.utf8CodeUnitCount))
    }
}

struct BadgeView: View {
    var body: some View {
        Color.red.frame(width: 40, height: 20).offset(x: -50, y: -90)
        Image("badge").resizable().frame(width: 64, height: 64)
    }
}

struct ContentView: View {
    let showBadge: Bool
    let showCaption: Bool
    var body: some View {
        ZStack {
            Color.black
            if showBadge { BadgeView() } else { Color.blue }
            if showCaption {
                Text("Hello").foregroundStyle(.yellow).frame(width: 100, height: 20).offset(y: 100)
            }
            Color.clear
            EmptyView()
            Color.red.frame(width: 0, height: 0)
        }
    }
}

@main
enum RenderingTests {
    static func main() {
        let viewport = EmbeddedRect(width: 240, height: 320)
        var sink = RecordingSink()
        EmbeddedRenderer.render(ContentView(showBadge: true, showCaption: true), in: viewport, to: &sink)
        precondition(sink.records.count == 4)
        precondition(sink.records[0].rect == viewport && sink.records[0].rgb == 0)
        precondition(sink.records[1].rect == EmbeddedRect(x: 50, y: 60, width: 40, height: 20))
        precondition(sink.records[1].rgb == 0xff0000 && sink.records[1].alpha == 255)
        precondition(sink.records[2].kind == 1 && sink.records[2].bytes == 5)
        precondition(sink.records[2].rect == EmbeddedRect(x: 88, y: 128, width: 64, height: 64))
        precondition(sink.records[3].kind == 2 && sink.records[3].bytes == 5)
        precondition(sink.records[3].rgb == 0xffff00)
        precondition(sink.records[3].rect == EmbeddedRect(x: 102, y: 255, width: 35, height: 10))
        sink.records.removeAll()
        EmbeddedRenderer.render(ContentView(showBadge: false, showCaption: false), in: viewport, to: &sink)
        precondition(sink.records.count == 2 && sink.records[1].rgb == 0x0000ff)
        let clamped = Color(red: 2, green: -1, blue: 0.5, opacity: 0.5)
        precondition(clamped.rgb == 0xff0080 && clamped.alpha == 128)
        precondition(Color(red: .nan, green: .infinity, blue: -.infinity).rgb == 0x00ff00)
        print("Embedded rendering: PASS (cross-module ContentView, nested builder, conditions, ordering, frames, offsets, color bounds)")
    }
}
