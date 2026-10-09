//
//  ControlSize.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: B084178BA9D46D059A1FB75185D1E85C (SwiftUICore)

package import OpenAttributeGraphShims

/// The size classes, like regular or small, that you can apply to controls
/// within a view.
@available(OpenSwiftUI_v1_0, *)
@available(OpenSwiftUI_iOS_v3_0, *)
@available(OpenSwiftUI_watchOS_v4_0, *)
@available(tvOS, unavailable)
public enum ControlSize: CaseIterable, Sendable {
    /// A control version that is minimally sized.
    case mini

    /// A control version that is proportionally smaller size for space-constrained views.
    case small

    /// A control version that is the default size.
    case regular

    /// A control version that is prominently sized.
    @available(OpenSwiftUI_macOS_v2_0, *)
    case large

    @available(OpenSwiftUI_v5_0, *)
    case extraLarge

    public static var allCases: [ControlSize] {
        [.mini, .small, .regular, .large, .extraLarge]
    }
}

extension ControlSize: Hashable {}

private struct ControlSizeKey: EnvironmentKey {
    static let defaultValue: ControlSize? = nil
}

@available(OpenSwiftUI_v1_0, *)
@available(OpenSwiftUI_iOS_v3_0, *)
@available(OpenSwiftUI_watchOS_v4_0, *)
@available(tvOS, unavailable)
extension EnvironmentValues {
    /// The size to apply to controls within a view.
    ///
    /// The default is ``ControlSize/regular``.
    public var controlSize: ControlSize {
        get { self[ControlSizeKey.self] ?? .regular }
        set { self[ControlSizeKey.self] = newValue }
    }

    package var explicitControlSize: ControlSize? {
        get { self[ControlSizeKey.self] }
        set { self[ControlSizeKey.self] = newValue }
    }
}

extension CachedEnvironment.ID {
    static let controlSize: CachedEnvironment.ID = .init()
}

extension _GraphInputs {
    package var controlSize: Attribute<ControlSize> {
        mapEnvironment(id: .controlSize) { $0.controlSize }
    }
}

@available(OpenSwiftUI_v1_0, *)
@available(OpenSwiftUI_iOS_v3_0, *)
@available(OpenSwiftUI_watchOS_v4_0, *)
@available(tvOS, unavailable)
extension View {
    /// Sets the size for controls within this view.
    ///
    /// Use `controlSize(_:)` to override the system default size for controls
    /// in this view. In this example, a view displays several typical controls
    /// at `.mini`, `.small` and `.regular` sizes.
    ///
    ///     struct ControlSize: View {
    ///         var body: some View {
    ///             VStack {
    ///                 MyControls(label: "Mini")
    ///                     .controlSize(.mini)
    ///                 MyControls(label: "Small")
    ///                     .controlSize(.small)
    ///                 MyControls(label: "Regular")
    ///                     .controlSize(.regular)
    ///             }
    ///             .padding()
    ///             .frame(width: 450)
    ///             .border(Color.gray)
    ///         }
    ///     }
    ///
    ///     struct MyControls: View {
    ///         var label: String
    ///         @State private var value = 3.0
    ///         @State private var selected = 1
    ///         var body: some View {
    ///             HStack {
    ///                 Text(label + ":")
    ///                 Picker("Selection", selection: $selected) {
    ///                     Text("option 1").tag(1)
    ///                     Text("option 2").tag(2)
    ///                     Text("option 3").tag(3)
    ///                 }
    ///                 Slider(value: $value, in: 1...10)
    ///                 Button("OK") { }
    ///             }
    ///         }
    ///     }
    ///
    /// ![A screenshot showing several controls of various
    /// sizes.](OpenSwiftUI-View-controlSize.png)
    ///
    /// - Parameter controlSize: One of the control sizes specified in the
    ///   ``ControlSize`` enumeration.
    @inlinable
    nonisolated public func controlSize(_ controlSize: ControlSize) -> some View {
        environment(\.controlSize, controlSize)
    }
}
