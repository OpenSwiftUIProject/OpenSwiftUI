//
//  NamedColor.swift
//  OpenSwiftUICore
//
//  Audited for iOS 18.0
//  Status: Blocked by CUINamedColor
//  ID: F70ADAD69423F89598F901BDE477D497 (SwiftUICore)

#if canImport(Darwin) && OPENSWIFTUI_LINK_COREUI
public import Foundation
package import CoreUI

final class CUINamedColor: NSObject {} // FIXME

package protocol CoreUINamedColorProvider {
    // static func effectiveCGColor(cuiColor: CUINamedColor, in environment: EnvironmentValues) -> CGColor?
}

extension EnvironmentValues {
    private struct CoreUINamedColorProviderKey: EnvironmentKey {
        static var defaultValue: (any CoreUINamedColorProvider.Type)? { nil }
    }

    package var cuiNamedColorProvider: (any CoreUINamedColorProvider.Type)? {
        get { self[CoreUINamedColorProviderKey.self] }
        set { self[CoreUINamedColorProviderKey.self] = newValue }
    }
}

extension Color {
    private struct NamedColor: ColorProvider {
        var name: String

        var bundle: Bundle?

        func resolveCGColor(in environment: EnvironmentValues) -> CGColor? {
            preconditionFailure("TODO")
        }

        func resolve(in environment: EnvironmentValues) -> Color.Resolved {
            guard let cgColor = resolveCGColor(in: environment) else {
                let bundlePath = if let bundle {
                    bundle.bundlePath
                } else {
                    "main bundle (\(Bundle.main.bundlePath)"
                }
                Log.externalWarning("No color named '\(name)' found in asset catalog for \(bundlePath)")
                return .clear
            }
            return Resolved(failableCGColor: cgColor) ?? .clear
        }
    }

    /// Creates a color from a color set that you indicate by name.
    ///
    /// Use this initializer to load a color from a color set stored in an
    /// Asset Catalog. The system determines which color within the set to use
    /// based on the environment at render time. For example, you
    /// can provide light and dark versions for background and foreground
    /// colors:
    ///
    /// ![A screenshot of color sets for foreground and background colors,
    ///   each with light and dark variants,
    ///   in an Asset Catalog.](Color-init-1)
    ///
    /// You can then instantiate colors by referencing the names of the assets:
    ///
    ///     struct Hello: View {
    ///         var body: some View {
    ///             ZStack {
    ///                 Color("background")
    ///                 Text("Hello, world!")
    ///                     .foregroundStyle(Color("foreground"))
    ///             }
    ///             .frame(width: 200, height: 100)
    ///         }
    ///     }
    ///
    /// OpenSwiftUI renders the appropriate colors for each appearance:
    ///
    /// ![A side by side comparison of light and dark appearance screenshots
    ///   of the same content. The light variant shows dark text on a light
    ///   background, while the dark variant shows light text on a dark
    ///   background.](Color-init-2)
    ///
    /// - Parameters:
    ///   - name: The name of the color resource to look up.
    ///   - bundle: The bundle in which to search for the color resource.
    ///     If you don't indicate a bundle, the initializer looks in your app's
    ///     main bundle by default.
    public init(_ name: String, bundle: Bundle? = nil) {
        self.init(provider: NamedColor(name: name, bundle: bundle))
    }

    /// A way to specify where to load "main bundle" colors from.
    public static let _mainNamedBundle: Bundle? = nil
}

private struct NamedColorInfo {
    var color: CUINamedColor
}
#endif

#if canImport(Darwin) && canImport(DeveloperToolsSupport)
public import DeveloperToolsSupport

extension Color {
    /// Initialize a `Color` with a color resource.
    public init(_ resource: ColorResource) {
        preconditionFailure("TODO")
    }
}
#endif
