//
//  GlobalCoordinateSpace.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete

/// The global coordinate space at the root of the view hierarchy.
@available(OpenSwiftUI_v5_0, *)
public struct GlobalCoordinateSpace: CoordinateSpaceProtocol {
    public init() {}
    
    public var coordinateSpace: CoordinateSpace { .global }
}

@available(*, unavailable)
extension GlobalCoordinateSpace: Sendable {}

@available(OpenSwiftUI_v5_0, *)
extension CoordinateSpaceProtocol where Self == GlobalCoordinateSpace {
    /// The global coordinate space at the root of the view hierarchy.
    public static var global: GlobalCoordinateSpace { .init() }
}
