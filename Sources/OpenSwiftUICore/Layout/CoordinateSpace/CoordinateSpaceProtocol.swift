//
//  CoordinateSpaceProtocol.swift
//  OpenSwiftUICore
//
//  Audited for iOS 18.0
//  Status: Complete

/// A frame of reference within the layout system.
///
/// All geometric properties of a view, including size, position, and
/// transform, are defined within the local coordinate space of the view's
/// parent. These values can be converted into other coordinate spaces
/// by passing types conforming to this protocol into functions such as
/// `GeometryProxy.frame(in:)`.
///
/// For example, a named coordinate space allows you to convert the frame
/// of a view into the local coordinate space of an ancestor view by defining
/// a named coordinate space using the `coordinateSpace(_:)` modifier, then
/// passing that same named coordinate space into the `frame(in:)` function.
///
///     VStack {
///         GeometryReader { geometryProxy in
///             let distanceFromTop = geometryProxy.frame(in: "container").origin.y
///             Text("This view is \(distanceFromTop) points from the top of the VStack")
///         }
///         .padding()
///     }
///     .coordinateSpace(.named("container"))
///
/// You don't typically create types conforming to this protocol yourself.
/// Instead, use the system-provided `.global`, `.local`, and `.named(_:)`
/// implementations.
public protocol CoordinateSpaceProtocol {
    /// The resolved coordinate space.
    var coordinateSpace: CoordinateSpace { get }
}
