//
//  ZIndex.swift
//  OpenSwiftUICore
//
//  Audited for iOS 18.0
//  Status: Complete

extension View {
    /// Controls the display order of overlapping views.
    ///
    /// Use `zIndex(_:)` when you want to control the front-to-back ordering of
    /// views.
    ///
    /// In this example there are two overlapping rotated rectangles. The
    /// frontmost is represented by the larger index value.
    ///
    ///     VStack {
    ///         Rectangle()
    ///             .fill(Color.yellow)
    ///             .frame(width: 100, height: 100, alignment: .center)
    ///             .zIndex(1) // Top layer.
    ///
    ///         Rectangle()
    ///             .fill(Color.red)
    ///             .frame(width: 100, height: 100, alignment: .center)
    ///             .rotationEffect(.degrees(45))
    ///             // Here a zIndex of 0 is the default making
    ///             // this the bottom layer.
    ///     }
    ///
    /// ![A screenshot showing two overlapping rectangles. The frontmost view is
    /// represented by the larger zIndex value.](OpenSwiftUI-View-zIndex.png)
    ///
    /// - Parameter value: A relative front-to-back ordering for this view; the
    ///   default is `0`.
    @inlinable
    nonisolated public func zIndex(_ value: Double) -> some View {
        return _trait(ZIndexTraitKey.self, value)
    }

}
@usableFromInline
package struct ZIndexTraitKey: _ViewTraitKey {
    @inlinable
    package static var defaultValue: Double { 0.0 }
}

@available(*, unavailable)
extension ZIndexTraitKey: Sendable {}

extension ViewTraitCollection {
    package var zIndex: Double {
        get { self[ZIndexTraitKey.self] }
        set { self[ZIndexTraitKey.self] = newValue }
    }
}
