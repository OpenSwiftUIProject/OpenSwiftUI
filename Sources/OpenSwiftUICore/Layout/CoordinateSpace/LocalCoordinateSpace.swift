//
//  LocalCoordinateSpace.swift
//  OpenSwiftUICore
//
//  Audited for 6.0.87
//  Status: Complete

/// The local coordinate space of the current view.
public struct LocalCoordinateSpace: CoordinateSpaceProtocol {
    public init() {}
    
    public var coordinateSpace: CoordinateSpace { .local }
}

@available(*, unavailable)
extension LocalCoordinateSpace: Sendable {}

extension CoordinateSpaceProtocol where Self == LocalCoordinateSpace {
    /// The local coordinate space of the current view.
    public static var local: LocalCoordinateSpace { .init() }
}
