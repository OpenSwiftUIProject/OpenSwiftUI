//
//  EmbeddedAlignment.swift
//  OpenSwiftUICore

#if OPENSWIFTUI_LVGL && hasFeature(Embedded)
public enum HorizontalAlignment: Sendable { case leading, center, trailing }
public enum VerticalAlignment: Sendable { case top, center, bottom }
public struct Alignment: Sendable {
    public var horizontal: HorizontalAlignment
    public var vertical: VerticalAlignment
    public init(horizontal: HorizontalAlignment, vertical: VerticalAlignment) {
        self.horizontal = horizontal; self.vertical = vertical
    }
    public static var center: Self { .init(horizontal: .center, vertical: .center) }
    public static var topLeading: Self { .init(horizontal: .leading, vertical: .top) }
    public static var bottomTrailing: Self { .init(horizontal: .trailing, vertical: .bottom) }
    func rect(size: EmbeddedSize, in bounds: EmbeddedRect) -> EmbeddedRect {
        let dx = bounds.width - size.width, dy = bounds.height - size.height
        let x: Int32 = horizontal == .leading ? 0 : horizontal == .trailing ? dx : dx / 2
        let y: Int32 = vertical == .top ? 0 : vertical == .bottom ? dy : dy / 2
        return .init(x: bounds.x + x, y: bounds.y + y, width: size.width, height: size.height)
    }
}
#endif
