//
//  GlobalCoordinateSpace.swift
//  OpenSwiftUICore
//
//  Audited for 6.0.87
//  Status: Complete

/// The global coordinate space at the root of the view hierarchy.
public struct GlobalCoordinateSpace: CoordinateSpaceProtocol {
    public init() {}
    
    public var coordinateSpace: CoordinateSpace { .global }
}

@available(*, unavailable)
extension GlobalCoordinateSpace: Sendable {}

extension CoordinateSpaceProtocol where Self == GlobalCoordinateSpace {
    /// The global coordinate space at the root of the view hierarchy.
    public static var global: GlobalCoordinateSpace { .init() }
}
