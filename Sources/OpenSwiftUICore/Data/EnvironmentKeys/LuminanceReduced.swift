//
//  LuminanceReduced.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: 0F38C9BE5EB47FD38EBFADF6C616C18D (SwiftUICore)

private struct ReducedLuminanceKey: EnvironmentKey {
    static var defaultValue: Bool { false }
}

@available(OpenSwiftUI_v4_0, *)
extension EnvironmentValues {
    /// A Boolean value that indicates whether the display or environment currently requires
    /// reduced luminance.
    ///
    /// When you detect this condition, lower the overall brightness of your view.
    /// For example, you can change large, filled shapes to be stroked, and choose
    /// less bright colors:
    ///
    ///     @Environment(\.isLuminanceReduced) var isLuminanceReduced
    ///
    ///     var body: some View {
    ///         if isLuminanceReduced {
    ///             Circle()
    ///                 .stroke(Color.gray, lineWidth: 10)
    ///         } else {
    ///             Circle()
    ///                 .fill(Color.white)
    ///         }
    ///     }
    ///
    /// In addition to the changes that you make, the system could also
    /// dim the display to achieve a suitable brightness. By reacting to
    /// `isLuminanceReduced`, you can preserve contrast and readability
    /// while helping to satisfy the reduced brightness requirement.
    ///
    /// > Note: On watchOS, the system typically sets this value to `true` when the user
    /// lowers their wrist, but the display remains on. Starting in watchOS 8, the system keeps your
    /// view visible on wrist down by default. If you want the system to blur the screen
    /// instead, as it did in earlier versions of watchOS, set the value for the
    /// [WKSupportsAlwaysOnDisplay](https://developer.apple.com/documentation/bundleresources/information-property-list/wksupportsalwaysondisplay)
    /// key in your app's
    /// [Information Property List](https://developer.apple.com/documentation/bundleresources/information-property-list)
    /// file to `false`.
    public var isLuminanceReduced: Bool {
        get { self[ReducedLuminanceKey.self] }
        set { self[ReducedLuminanceKey.self] = newValue }
    }
}
