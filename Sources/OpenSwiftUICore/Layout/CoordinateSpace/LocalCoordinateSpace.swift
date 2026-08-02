//
//  LocalCoordinateSpace.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete

/// The local coordinate space of the current view.
@available(OpenSwiftUI_v5_0, *)
public struct LocalCoordinateSpace: CoordinateSpaceProtocol {
    public init() {}
    
    public var coordinateSpace: CoordinateSpace { .local }
}

@available(*, unavailable)
extension LocalCoordinateSpace: Sendable {}

@available(OpenSwiftUI_v5_0, *)
extension CoordinateSpaceProtocol where Self == LocalCoordinateSpace {
    /// The local coordinate space of the current view.
    public static var local: LocalCoordinateSpace { .init() }
}
