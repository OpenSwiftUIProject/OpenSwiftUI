//
//  EmbeddedSize.swift
//  OpenSwiftUICore

#if OPENSWIFTUI_LVGL && hasFeature(Embedded)
/// A nonnegative size in physical pixels. No Foundation geometry is required.
public struct EmbeddedSize: Equatable, Sendable {
    public var width: Int32
    public var height: Int32
    public init(width: Int32, height: Int32) {
        precondition(width >= 0 && height >= 0)
        self.width = width
        self.height = height
    }
    public static var zero: Self { .init(width: 0, height: 0) }
}
#endif
