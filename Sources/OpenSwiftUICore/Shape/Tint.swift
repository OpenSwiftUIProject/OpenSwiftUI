//
//  TintShape.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: WIP
//  ID: EB037BD7690CB8A700384AACA7B075E4 (SwiftUICore)

package import OpenAttributeGraphShims

// MARK: - View + tint ShapeStyle

@available(OpenSwiftUI_v4_0, *)
extension View {
    /// Sets the tint within this view.
    ///
    /// Use this method to override the default accent color for this view with
    /// a given styling. Unlike an app's accent color, which can be
    /// overridden by user preference, tint is always respected and should
    /// be used as a way to provide additional meaning to the control.
    ///
    /// Controls which are unable to style themselves using the given type of
    /// `ShapeStyle` will try to approximate the styling as best as they can
    /// (i.e. controls which can not style themselves using a gradient will
    /// attempt to use the color of the gradient's first stop).
    ///
    /// This example shows a linear gauge tinted with a
    /// gradient from ``ShapeStyle/blue`` to ``ShapeStyle/red``.
    ///
    ///     struct ControlTint: View {
    ///         var body: some View {
    ///             Gauge(value: 75, in: 0...100) {
    ///                 Text("Temperature")
    ///             }
    ///             .gaugeStyle(.linearCapacity)
    ///             .tint(Gradient(colors: [.blue, .orange, .red]))
    ///         }
    ///     }
    ///
    /// Some controls adapt to the tint color differently based on their style,
    /// the current platform, and the surrounding context. For example, in
    /// macOS, a button with the ``PrimitiveButtonStyle/bordered`` style doesn't
    /// tint its background, but one with the
    /// ``PrimitiveButtonStyle/borderedProminent`` style does. In macOS, neither
    /// of these button styles tint their label, but they do in other platforms.
    ///
    /// - Parameter tint: The tint to apply.
    @inlinable
    nonisolated public func tint<S>(_ tint: S?) -> some View where S: ShapeStyle {
        environment(\.tint, tint.map(AnyShapeStyle.init))
    }
}

// MARK: - TintPlacement

@_spi(Private)
@available(OpenSwiftUI_v6_0, *)
public struct TintPlacement: Hashable {
    @available(macOS, unavailable)
    @available(tvOS, unavailable)
    public static var switchThumb: TintPlacement {
        .init(guts: .switchThumb)
    }

    enum Guts {
        case switchThumb
    }

    let guts: Guts
}

@_spi(Private)
@available(*, unavailable)
extension TintPlacement: Sendable {}

// MARK: - View + tintPlacement

@_spi(Private)
@available(OpenSwiftUI_v6_0, *)
extension View {
    @inlinable
    nonisolated public func tint<S>(_ tint: S?, for placement: TintPlacement) -> some View where S: ShapeStyle {
        transformEnvironment(\.placementTint) { value in
            if let tint {
                value[placement] = .init(tint)
            }
        }
    }
}

// MARK: - View + tint Color

@available(OpenSwiftUI_v3_0, *)
extension View {
    /// Sets the tint color within this view.
    ///
    /// Use this method to override the default accent color for this view.
    /// Unlike an app's accent color, which can be overridden by user
    /// preference, the tint color is always respected and should be used as a
    /// way to provide additional meaning to the control.
    ///
    /// This example shows Answer and Decline buttons with ``ShapeStyle/green``
    /// and ``ShapeStyle/red`` tint colors, respectively.
    ///
    ///     struct ControlTint: View {
    ///         var body: some View {
    ///             HStack {
    ///                 Button {
    ///                     // Answer the call
    ///                 } label: {
    ///                     Label("Answer", systemImage: "phone")
    ///                 }
    ///                 .tint(.green)
    ///                 Button {
    ///                     // Decline the call
    ///                 } label: {
    ///                     Label("Decline", systemImage: "phone.down")
    ///                 }
    ///                 .tint(.red)
    ///             }
    ///             .buttonStyle(.borderedProminent)
    ///             .padding()
    ///         }
    ///     }
    ///
    /// Some controls adapt to the tint color differently based on their style,
    /// the current platform, and the surrounding context. For example, in
    /// macOS, a button with the ``PrimitiveButtonStyle/bordered`` style doesn't
    /// tint its background, but one with the
    /// ``PrimitiveButtonStyle/borderedProminent`` style does. In macOS, neither
    /// of these button styles tint their label, but they do in other platforms.
    ///
    /// - Parameter tint: The tint ``Color`` to apply.
    @inlinable
    @_disfavoredOverload
    nonisolated public func tint(_ tint: Color?) -> some View {
        environment(\.tintColor, tint)
    }
}

// MARK: - EnvironmentValues + tint

private struct TintKey: EnvironmentKey {
    package static var defaultValue: AnyShapeStyle? { nil }
}

private struct PlacementTintKey: EnvironmentKey {
    package static var defaultValue: [TintPlacement: AnyShapeStyle] { [:] }
}

extension EnvironmentValues {
    @usableFromInline
    package var tint: AnyShapeStyle? {
        get { self[TintKey.self] }
        set { self[TintKey.self] = newValue }
    }

    @_spi(Private)
    @usableFromInline
    package var placementTint: [TintPlacement: AnyShapeStyle] {
        get { self[PlacementTintKey.self] }
        set { self[PlacementTintKey.self] = newValue }
    }
}

@available(OpenSwiftUI_v3_0, *)
extension EnvironmentValues {
    @usableFromInline
    package var tintColor: Color? {
        get { tint?.fallbackColor(in: self) }
        set { tint = newValue.map { AnyShapeStyle($0) } }
    }

    package var resolvedTintColor: Color.Resolved {
        (tintColor ?? .accent).resolve(in: self)
    }
}

extension CachedEnvironment.ID {
    package static let tintColor: CachedEnvironment.ID = .init()
}

extension _ViewInputs {
    package var tintColor: Attribute<Color?> {
        mapEnvironment(id: .tintColor) { $0.tintColor }
    }
}

// MARK: - TintShapeStyle [TODO]
