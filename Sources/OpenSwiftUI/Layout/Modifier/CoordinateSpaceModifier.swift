//
//  CoordinateSpaceModifier.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: AC3D921589C9B46E7A4620E6FB24D937 (SwiftUI)

import Foundation
import OpenAttributeGraphShims
@_spi(ForOpenSwiftUIOnly)
public import OpenSwiftUICore

// MARK: - _CoordinateSpaceModifier

@available(OpenSwiftUI_v1_0, *)
@frozen
public struct _CoordinateSpaceModifier<Name>: ViewModifier, ViewInputsModifier, Equatable where Name: Hashable {
    public var name: Name

    @inlinable
    public init(name: Name) {
        self.name = name
    }

    nonisolated public static func _makeViewInputs(modifier: _GraphValue<Self>, inputs: inout _ViewInputs) {
        inputs.transform = Attribute(CoordinateSpaceTransform(
            modifier: modifier.value,
            transform: inputs.transform,
            position: inputs.animatedPosition(),
            size: inputs.animatedCGSize()
        ))
    }

    public typealias Body = Never
}

@available(*, unavailable)
extension _CoordinateSpaceModifier: Sendable {}

// MARK: - View + CoordinateSpace

@available(OpenSwiftUI_v1_0, *)
extension View {
    /// Assigns a name to the view's coordinate space, so other code can operate
    /// on dimensions like points and sizes relative to the named space.
    ///
    /// Use `coordinateSpace(name:)` to allow another function to find and
    /// operate on a view and operate on dimensions relative to that view.
    ///
    /// The example below demonstrates how a nested view can find and operate on
    /// its enclosing view's coordinate space:
    ///
    ///     struct ContentView: View {
    ///         @State private var location = CGPoint.zero
    ///
    ///         var body: some View {
    ///             VStack {
    ///                 Color.red.frame(width: 100, height: 100)
    ///                     .overlay(circle)
    ///                 Text("Location: \(Int(location.x)), \(Int(location.y))")
    ///             }
    ///             .coordinateSpace(name: "stack")
    ///         }
    ///
    ///         var circle: some View {
    ///             Circle()
    ///                 .frame(width: 25, height: 25)
    ///                 .gesture(drag)
    ///                 .padding(5)
    ///         }
    ///
    ///         var drag: some Gesture {
    ///             DragGesture(coordinateSpace: .named("stack"))
    ///                 .onChanged { info in location = info.location }
    ///         }
    ///     }
    ///
    /// Here, the ``VStack`` in the `ContentView` named “stack” is composed of a
    /// red frame with a custom ``Circle`` view ``View/overlay(_:alignment:)``
    /// at its center.
    ///
    /// The `circle` view has an attached ``DragGesture`` that targets the
    /// enclosing VStack's coordinate space. As the gesture recognizer's closure
    /// registers events inside `circle` it stores them in the shared `location`
    /// state variable and the ``VStack`` displays the coordinates in a ``Text``
    /// view.
    ///
    /// ![A screenshot showing an example of finding a named view and tracking
    /// relative locations in that view.](OpenSwiftUI-View-coordinateSpace)
    ///
    /// - Parameter name: A name used to identify this coordinate space.
    @available(iOS, deprecated: 100000.0, message: "use coordinateSpace(_:) instead")
    @available(macOS, deprecated: 100000.0, message: "use coordinateSpace(_:) instead")
    @available(tvOS, deprecated: 100000.0, message: "use coordinateSpace(_:) instead")
    @available(watchOS, deprecated: 100000.0, message: "use coordinateSpace(_:) instead")
    @available(visionOS, deprecated: 100000.0, message: "use coordinateSpace(_:) instead")
    @inlinable
    nonisolated public func coordinateSpace<T>(name: T) -> some View where T: Hashable {
        modifier(_CoordinateSpaceModifier(name: name))
    }
}

@available(OpenSwiftUI_v5_0, *)
extension View {
    /// Assigns a name to the view's coordinate space, so other code can operate
    /// on dimensions like points and sizes relative to the named space.
    ///
    /// Use `coordinateSpace(_:)` to allow another function to find and
    /// operate on a view and operate on dimensions relative to that view.
    ///
    /// The example below demonstrates how a nested view can find and operate on
    /// its enclosing view's coordinate space:
    ///
    ///     struct ContentView: View {
    ///         @State private var location = CGPoint.zero
    ///
    ///         var body: some View {
    ///             VStack {
    ///                 Color.red.frame(width: 100, height: 100)
    ///                     .overlay(circle)
    ///                 Text("Location: \(Int(location.x)), \(Int(location.y))")
    ///             }
    ///             .coordinateSpace(.named("stack"))
    ///         }
    ///
    ///         var circle: some View {
    ///             Circle()
    ///                 .frame(width: 25, height: 25)
    ///                 .gesture(drag)
    ///                 .padding(5)
    ///         }
    ///
    ///         var drag: some Gesture {
    ///             DragGesture(coordinateSpace: .named("stack"))
    ///                 .onChanged { info in location = info.location }
    ///         }
    ///     }
    ///
    /// Here, the ``VStack`` in the `ContentView` named “stack” is composed of a
    /// red frame with a custom ``Circle`` view ``View/overlay(_:alignment:)``
    /// at its center.
    ///
    /// The `circle` view has an attached ``DragGesture`` that targets the
    /// enclosing VStack's coordinate space. As the gesture recognizer's closure
    /// registers events inside `circle` it stores them in the shared `location`
    /// state variable and the ``VStack`` displays the coordinates in a ``Text``
    /// view.
    ///
    /// ![A screenshot showing an example of finding a named view and tracking
    /// relative locations in that view.](OpenSwiftUI-View-coordinateSpace)
    ///
    /// - Parameter name: A name used to identify this coordinate space.
    nonisolated public func coordinateSpace(_ name: NamedCoordinateSpace) -> some View {
        modifier(CoordinateSpaceNameModifier(name: name))
    }
}

// MARK: - CoordinateSpaceTransform

private struct CoordinateSpaceTransform<Name>: Rule, AsyncAttribute where Name: Hashable {
    @Attribute var modifier: _CoordinateSpaceModifier<Name>
    @Attribute var transform: ViewTransform
    @Attribute var position: CGPoint
    @Attribute var size: CGSize

    var value: ViewTransform {
        var transform = transform
        transform.appendPosition(position)
        transform.appendSizedSpace(name: modifier.name, size: size)
        return transform
    }
}

// MARK: - CoordinateSpaceNameModifier

private struct CoordinateSpaceNameModifier: PrimitiveViewModifier, ViewInputsModifier {
    var name: NamedCoordinateSpace

    static func _makeViewInputs(modifier: _GraphValue<Self>, inputs: inout _ViewInputs) {
        inputs.transform = Attribute(CoordinateSpaceNameTransform(
            modifier: modifier.value,
            transform: inputs.transform,
            position: inputs.animatedPosition(),
            size: inputs.animatedCGSize()
        ))
    }
}

// MARK: - CoordinateSpaceNameTransform

private struct CoordinateSpaceNameTransform: Rule, AsyncAttribute {
    @Attribute var modifier: CoordinateSpaceNameModifier
    @Attribute var transform: ViewTransform
    @Attribute var position: CGPoint
    @Attribute var size: CGSize

    var value: ViewTransform {
        var transform = transform
        transform.appendPosition(position)
        switch modifier.name.name {
        case let .name(name):
            transform.appendSizedSpace(name: name, size: size)
        case let .id(id):
            transform.appendSizedSpace(id: id, size: size)
        }
        return transform
    }
}
