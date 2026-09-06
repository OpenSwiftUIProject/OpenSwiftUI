//
//  EmbeddedColor.swift
//  OpenSwiftUICore

#if OPENSWIFTUI_LVGL && hasFeature(Embedded)
/// A constant sRGB color. Dynamic providers and color spaces are not included.
public struct Color: PrimitiveView, Equatable, Sendable {
    public let rgb: UInt32
    public let alpha: UInt8

    public init(red: Double, green: Double, blue: Double, opacity: Double = 1) {
        rgb = UInt32(Self.component(red)) << 16 | UInt32(Self.component(green)) << 8 | UInt32(Self.component(blue))
        alpha = Self.component(opacity)
    }

    public init(white: Double, opacity: Double = 1) {
        self.init(red: white, green: white, blue: white, opacity: opacity)
    }

    private init(rgb: UInt32, alpha: UInt8 = 255) {
        self.rgb = rgb
        self.alpha = alpha
    }

    private static func component(_ value: Double) -> UInt8 {
        if value.isNaN || value <= 0 { return 0 }
        if value >= 1 { return 255 }
        return UInt8(value * 255 + 0.5)
    }

    public static var black: Color { Color(rgb: 0x000000) }
    public static var white: Color { Color(rgb: 0xffffff) }
    public static var red: Color { Color(rgb: 0xff0000) }
    public static var green: Color { Color(rgb: 0x00ff00) }
    public static var blue: Color { Color(rgb: 0x0000ff) }
    public static var yellow: Color { Color(rgb: 0xffff00) }
    public static var orange: Color { Color(rgb: 0xff8800) }
    public static var purple: Color { Color(rgb: 0x8833ff) }
    public static var clear: Color { Color(rgb: 0, alpha: 0) }

    public func _sizeThatFits<Sink: EmbeddedRenderSink>(_ proposal: ProposedViewSize, using sink: inout Sink) -> EmbeddedSize {
        proposal.replacingUnspecifiedDimensions()
    }

    public func _render<Sink: EmbeddedRenderSink>(in rect: EmbeddedRect, to sink: inout Sink) {
        if alpha > 0 && rect.width > 0 && rect.height > 0 { sink.fill(rect, color: self) }
    }
}
#endif
