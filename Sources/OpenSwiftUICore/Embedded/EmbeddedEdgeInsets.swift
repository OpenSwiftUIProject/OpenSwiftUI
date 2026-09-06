//
//  EmbeddedEdgeInsets.swift
//  OpenSwiftUICore

#if OPENSWIFTUI_LVGL && hasFeature(Embedded)
public struct EdgeInsets: Equatable, Sendable {
    public var top: Int32
    public var leading: Int32
    public var bottom: Int32
    public var trailing: Int32
    public init(top: Int32 = 0, leading: Int32 = 0, bottom: Int32 = 0, trailing: Int32 = 0) {
        precondition(top >= 0 && leading >= 0 && bottom >= 0 && trailing >= 0)
        self.top = top; self.leading = leading; self.bottom = bottom; self.trailing = trailing
    }
}
#endif
