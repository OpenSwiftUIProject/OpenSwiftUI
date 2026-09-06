//
//  EmbeddedProposedViewSize.swift
//  OpenSwiftUICore

#if OPENSWIFTUI_LVGL && hasFeature(Embedded)
/// A size proposal; nil asks for the child's ideal size on that axis.
/// The Embedded profile uses integer pixels and a finite maximum probe.
public struct ProposedViewSize: Equatable, Sendable {
    public var width: Int32?
    public var height: Int32?
    public init(width: Int32? = nil, height: Int32? = nil) {
        precondition((width ?? 0) >= 0 && (height ?? 0) >= 0)
        self.width = width
        self.height = height
    }
    public init(_ size: EmbeddedSize) { self.init(width: size.width, height: size.height) }
    public static var unspecified: Self { .init() }
    public static var zero: Self { .init(width: 0, height: 0) }
    public static var maximum: Self { .init(width: 32767, height: 32767) }
    public func replacingUnspecifiedDimensions(by size: EmbeddedSize = .init(width: 10, height: 10)) -> EmbeddedSize {
        .init(width: width ?? size.width, height: height ?? size.height)
    }
}
#endif
