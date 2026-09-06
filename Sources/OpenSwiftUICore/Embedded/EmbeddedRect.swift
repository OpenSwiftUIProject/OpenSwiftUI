//
//  EmbeddedRect.swift
//  OpenSwiftUICore

#if OPENSWIFTUI_EMBEDDED
/// Integer pixel coordinates used by the static Embedded rendering profile.
public struct EmbeddedRect: Equatable, Sendable {
    public var x: Int32
    public var y: Int32
    public var width: Int32
    public var height: Int32

    public init(x: Int32 = 0, y: Int32 = 0, width: Int32, height: Int32) {
        precondition(width >= 0 && height >= 0, "Negative render dimensions")
        self.x = x
        self.y = y
        self.width = width
        self.height = height
    }
}
#endif
