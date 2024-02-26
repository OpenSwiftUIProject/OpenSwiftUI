//
//  ControlSizeKey.swift
//  OpenSwiftUI
//
//  Audited for RELEASE_2021
//  Status: Complete
//  ID: 50E368DED9ACE8B6BEC08FF7781AF4B1

private struct ControlSizeKey: EnvironmentKey {
    static let defaultValue: ControlSize = .regular
}

extension EnvironmentValues {
    /// The size to apply to controls within a view.
    ///
    /// The default is ``ControlSize/regular``.
    @available(tvOS, unavailable)
    public var controlSize: ControlSize {
        get { self[ControlSizeKey.self] }
        set { self[ControlSizeKey.self] = newValue }
    }
}

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
    /// sizes.](SwiftUI-View-controlSize.png)
    ///
    /// - Parameter controlSize: One of the control sizes specified in the
    ///   ``ControlSize`` enumeration.
    @inlinable
    public func controlSize(_ controlSize: ControlSize) -> some View {
        environment(\.controlSize, controlSize)
    }
}
