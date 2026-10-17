//
//  PreviewProvider.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: 3CB3B2F1CA8243F6B014197D76486C71 (SwiftUI)

import COpenSwiftUI
public import OpenSwiftUICore

#if canImport(DeveloperToolsSupport)
public import DeveloperToolsSupport
#endif

// MARK: - PreviewProvider

/// Produces a list of PreviewProviders.
@available(OpenSwiftUI_v1_0, *)
public protocol _PreviewProviderLocator {
    static var previewProviders: [any _PreviewProvider.Type] { get }
}

/// Existential base type.
@available(OpenSwiftUI_v1_0, *)
@preconcurrency
@MainActor
public protocol _PreviewProvider {
    static var _previews: Any { get }

    static var _platform: PreviewPlatform? { get }
}

/// A type that produces view previews in Xcode.
///
/// > Important: You can use this protocol to define a preview manually, but
///   you typically use a preview macro like ``Preview(_:body:)`` instead.
///
/// You can create an Xcode preview by declaring a structure that conforms to
/// the `PreviewProvider` protocol. Implement the required
/// ``PreviewProvider/previews-swift.type.property`` computed property,
/// and return the view to display:
///
///     struct CircleImage_Previews: PreviewProvider {
///         static var previews: some View {
///             CircleImage()
///         }
///     }
///
/// Xcode statically discovers preview providers in your project and generates
/// previews for any providers currently open in the source editor.
/// Xcode generates the preview using the current run destination as a hint
/// for which device to display. For example, Xcode shows the following preview
/// if you've selected an iOS target to run on the iPhone 12 Pro Max simulator:
///
/// ![A screenshot of the Xcode canvas previewing a circular image on an
/// iPhone in the portrait orientation.](PreviewProvider-1)
///
/// When you create a new file (File > New > File)
/// and choose the OpenSwiftUI view template, Xcode automatically inserts a
/// preview structure at the bottom of the file that you can configure.
/// You can also create new preview structures in an existing OpenSwiftUI
/// view file by choosing Editor > Create Preview.
///
/// Customize the preview's appearance by adding view modifiers, just like you
/// do when building a custom ``View``. This includes preview-specific
/// modifiers that let you control aspects of the preview, like the device
/// orientation:
///
///     struct CircleImage_Previews: PreviewProvider {
///         static var previews: some View {
///             CircleImage()
///                 .previewInterfaceOrientation(.landscapeLeft)
///         }
///     }
///
/// ![A screenshot of the Xcode canvas previewing a circular image on an
/// iPhone in the landscape left orientation.](PreviewProvider-2)
///
/// For the complete list of preview customizations,
/// see <doc:Previews-in-Xcode>.
///
/// Xcode creates different previews for each view in your preview,
/// so you can see variations side by side. For example, you
/// might want to see a view's light and dark appearances simultaneously:
///
///     struct CircleImage_Previews: PreviewProvider {
///         static var previews: some View {
///             CircleImage()
///             CircleImage()
///                 .preferredColorScheme(.dark)
///         }
///     }
///
/// Use a ``Group`` when you want to maintain different previews, but apply a
/// single modifier to all of them:
///
///     struct CircleImage_Previews: PreviewProvider {
///         static var previews: some View {
///             Group {
///                 CircleImage()
///                 CircleImage()
///                     .preferredColorScheme(.dark)
///             }
///             .previewLayout(.sizeThatFits)
///         }
///     }
///
/// ![A screenshot of the Xcode canvas previewing a circular image twice,
/// once with a light appearance and once with a dark appearance. Both
/// previews take up only as much room as they need to fit the circular
/// image.](PreviewProvider-3)
@available(OpenSwiftUI_v1_0, *)
@preconcurrency
@MainActor
public protocol PreviewProvider: _PreviewProvider {
    /// The type to preview.
    ///
    /// When you create a preview, Swift infers this type from your
    /// implementation of the required
    /// ``PreviewProvider/previews-swift.type.property`` property.
    associatedtype Previews: View

    /// A collection of views to preview.
    ///
    /// Implement a computed `previews` property to indicate the content to
    /// preview. Xcode generates a preview for each view that you list. You
    /// can apply ``View`` modifiers to the views, like you do
    /// when creating a custom view. For a preview, you can also use
    /// various preview-specific modifiers that customize the preview.
    /// For example, you can choose a specific device for the preview
    /// by adding the ``View/previewDevice(_:)`` modifier:
    ///
    ///     struct CircleImage_Previews: PreviewProvider {
    ///         static var previews: some View {
    ///             CircleImage()
    ///                 .previewDevice(PreviewDevice(rawValue: "iPad Pro (11-inch)"))
    ///         }
    ///     }
    ///
    /// For the full list of preview-specific modifiers,
    /// see <doc:Previews-in-Xcode>.
    @ViewBuilder
    static var previews: Previews { get }

    /// The platform on which to run the provider.
    ///
    /// Xcode infers the platform for a preview based on the currently
    /// selected target. If you have a multiplatform target and want to
    /// suggest a particular target for a preview, implement the
    /// `platform` computed property to provide a hint,
    /// and specify one of the ``PreviewPlatform`` values:
    ///
    ///     struct CircleImage_Previews: PreviewProvider {
    ///         static var previews: some View {
    ///             CircleImage()
    ///         }
    ///
    ///         static var platform: PreviewPlatform? {
    ///             PreviewPlatform.tvOS
    ///         }
    ///     }
    ///
    /// Xcode ignores this value unless you have a multiplatform target.
    static var platform: PreviewPlatform? { get }
}

@available(OpenSwiftUI_v1_0, *)
extension PreviewProvider {
    public static var platform: PreviewPlatform? { nil }

    public static var _previews: Any { previews }

    public static var _platform: PreviewPlatform? { platform }
}

// MARK: - PreviewPlatform

/// Platforms that can run the preview.
///
/// Xcode infers the platform for a preview based on the currently
/// selected target. If you have a multiplatform target and want to
/// suggest a particular target for a preview, implement the
/// ``PreviewProvider/platform-75xu4`` computed property as a hint,
/// and specify one of the preview platforms:
///
///     struct CircleImage_Previews: PreviewProvider {
///         static var previews: some View {
///             CircleImage()
///         }
///
///         static var platform: PreviewPlatform? {
///             PreviewPlatform.tvOS
///         }
///     }
@available(OpenSwiftUI_v1_0, *)
public enum PreviewPlatform: Hashable, Sendable {
    /// Specifies iOS as the preview platform.
    case iOS

    /// Specifies macOS as the preview platform.
    case macOS

    /// Specifies tvOS as the preview platform.
    case tvOS

    /// Specifies watchOS as the preview platform.
    case watchOS
}

// MARK: - PreviewDevice

/// A simulator device that runs a preview.
///
/// Create a preview device by name, like "iPhone X", or by model number,
/// like "iPad8,1". Use the device in a call to the ``View/previewDevice(_:)``
/// modifier to set a preview device that doesn't change when you change the
/// run destination in Xcode:
///
///     struct CircleImage_Previews: PreviewProvider {
///         static var previews: some View {
///             CircleImage()
///                 .previewDevice(PreviewDevice(rawValue: "iPad Pro (11-inch)"))
///         }
///     }
///
/// You can get a list of supported preview device names by using the
/// `xcrun` command in the Terminal app:
///
///     % xcrun simctl list devicetypes
///
/// Additionally, you can use the following values for macOS platform
/// development:
/// - "Mac"
/// - "Mac Catalyst"
@available(OpenSwiftUI_v1_0, *)
public struct PreviewDevice: RawRepresentable, ExpressibleByStringLiteral, Sendable {
    public let rawValue: String

    public init(rawValue: String) {
        self.rawValue = rawValue
    }

    public init(stringLiteral: String) {
        self.init(rawValue: stringLiteral)
    }
}

// MARK: - PreviewContext

/// A key type for a preview context.
///
/// The default value is `nil`.
@available(OpenSwiftUI_v2_0, *)
public protocol PreviewContextKey {
    /// The type of the value returned by the key.
    associatedtype Value

    /// The default value of the key.
    static var defaultValue: Value { get }
}

/// A context type for use with a preview.
@available(OpenSwiftUI_v2_0, *)
public protocol PreviewContext {
    /// Returns the context's value for a key, or the key's default value
    /// if the context doesn't define a value for the key.
    subscript<Key>(key: Key.Type) -> Key.Value where Key: PreviewContextKey { get }
}

// MARK: - InterfaceOrientation

/// The orientation of the interface from the user's perspective.
///
/// By default, device previews appear right side up, using orientation
/// ``InterfaceOrientation/portrait``. You can change the orientation
/// with a call to the ``View/previewInterfaceOrientation(_:)`` modifier:
///
///     struct CircleImage_Previews: PreviewProvider {
///         static var previews: some View {
///             CircleImage()
///                 .previewInterfaceOrientation(.landscapeRight)
///         }
///     }
@available(OpenSwiftUI_v3_0, *)
public struct InterfaceOrientation: CaseIterable, Identifiable, Equatable, Sendable {
    private enum Orientation: String, CaseIterable {
        case portrait
        case portraitUpsideDown
        case landscapeLeft
        case landscapeRight
    }

    private let orientation: Orientation

    public static var allCases: [InterfaceOrientation] {
        Orientation.allCases.map { InterfaceOrientation(orientation: $0) }
    }

    public var id: String { orientation.rawValue }

    /// The device is in portrait mode, with the top of the device on top.
    public static let portrait = InterfaceOrientation(orientation: .portrait)

    /// The device is in portrait mode, but is upside down.
    public static let portraitUpsideDown = InterfaceOrientation(orientation: .portraitUpsideDown)

    /// The device is in landscape mode, with the top of the device on the left.
    public static let landscapeLeft = InterfaceOrientation(orientation: .landscapeLeft)

    /// The device is in landscape mode, with the top of the device on the right.
    public static let landscapeRight = InterfaceOrientation(orientation: .landscapeRight)
}

// MARK: - View + Preview Traits

@available(OpenSwiftUI_v1_0, *)
extension View {
    /// Overrides the device for a preview.
    ///
    /// By default, Xcode automatically chooses a preview device based
    /// on your currently selected run destination. If you want to
    /// choose a device that doesn't change based on Xcode settings,
    /// provide a ``PreviewDevice`` instance that you initialize with
    /// the name or model of a specific device:
    ///
    ///     struct CircleImage_Previews: PreviewProvider {
    ///         static var previews: some View {
    ///             CircleImage()
    ///                 .previewDevice(PreviewDevice(rawValue: "iPad Pro (11-inch)"))
    ///         }
    ///     }
    ///
    /// You can get a list of supported preview device names, like "iPhone 11",
    /// "iPad Pro (11-inch)", and "Apple Watch Series 5 - 44mm", by using the
    /// `xcrun` command in the Terminal app:
    ///
    ///     % xcrun simctl list devicetypes
    ///
    /// Additionally, you can use the following values for macOS platform
    /// development:
    /// - "Mac"
    /// - "Mac Catalyst"
    ///
    /// - Parameter value: A device to use for preview, or `nil` to let Xcode
    ///   automatically choose a device based on the run destination.
    /// - Returns: A preview that uses the given device.
    @inlinable
    nonisolated public func previewDevice(_ value: PreviewDevice?) -> some View {
        _trait(PreviewDeviceTraitKey.self, value)
    }

    /// Overrides the size of the container for the preview.
    ///
    /// By default, previews use the ``PreviewLayout/device`` layout,
    /// which places the view inside a visual representation of the chosen
    /// device. You can instead tell a preview to use a different layout
    /// by choosing one of the ``PreviewLayout`` values, like
    /// ``PreviewLayout/sizeThatFits``:
    ///
    ///     struct CircleImage_Previews: PreviewProvider {
    ///         static var previews: some View {
    ///             CircleImage()
    ///                 .previewLayout(.sizeThatFits)
    ///         }
    ///     }
    ///
    /// - Parameter value: A layout to use for preview.
    /// - Returns: A preview that uses the given layout.
    @inlinable
    nonisolated public func previewLayout(_ value: PreviewLayout) -> some View {
        _trait(PreviewLayoutTraitKey.self, value)
    }

    /// Sets a user visible name to show in the canvas for a preview.
    ///
    /// Apply this modifier to a view inside your ``PreviewProvider``
    /// implementation to associate a display name with that view's preview:
    ///
    ///     struct CircleImage_Previews: PreviewProvider {
    ///         static var previews: some View {
    ///             CircleImage()
    ///                 .previewDisplayName("Circle")
    ///         }
    ///     }
    ///
    /// ![A screenshot of the Xcode preview canvas cropped to just the top of a
    /// preview, highlighting the name in the preview's title bar, which is set
    /// to the word circle.](View-previewDisplayName-1)
    ///
    /// Add a name when you have multiple previews together in the canvas that
    /// you need to tell apart. The default value is `nil`, in which case
    /// Xcode displays a default string.
    ///
    /// - Parameter value: A name for the preview.
    /// - Returns: A preview that uses the given name.
    @inlinable
    nonisolated public func previewDisplayName(_ value: String?) -> some View {
        _trait(PreviewDisplayNameTraitKey.self, value)
    }

    /// Declares a context for the preview.
    ///
    /// - Parameter value: The context for the preview; the default is `nil`.
    @available(OpenSwiftUI_v2_0, *)
    @inlinable
    nonisolated public func previewContext<C>(_ value: C) -> some View where C: PreviewContext {
        _trait(PreviewContextTraitKey.self, value)
    }

    /// Overrides the orientation of the preview.
    ///
    /// By default, device previews appear right side up, using orientation
    /// ``InterfaceOrientation/portrait``. You can
    /// change the orientation of a preview using one of the values in
    /// the ``InterfaceOrientation`` structure:
    ///
    ///     struct CircleImage_Previews: PreviewProvider {
    ///         static var previews: some View {
    ///             CircleImage()
    ///                 .previewInterfaceOrientation(.landscapeRight)
    ///         }
    ///     }
    ///
    /// - Parameter value: An orientation to use for preview.
    /// - Returns: A preview that uses the given orientation.
    @available(OpenSwiftUI_v3_0, *)
    nonisolated public func previewInterfaceOrientation(_ value: InterfaceOrientation) -> some View {
        _trait(PreviewInterfaceOrientationTraitKey.self, value)
    }
}

@available(OpenSwiftUI_v1_0, *)
@usableFromInline
struct PreviewDeviceTraitKey: _ViewTraitKey {
    @inlinable
    static var defaultValue: PreviewDevice? { nil }
}

@available(*, unavailable)
extension PreviewDeviceTraitKey: Sendable {}

@available(OpenSwiftUI_v1_0, *)
@usableFromInline
struct PreviewLayoutTraitKey: _ViewTraitKey {
    @inlinable
    static var defaultValue: PreviewLayout { .device }
}

@available(*, unavailable)
extension PreviewLayoutTraitKey: Sendable {}

@available(OpenSwiftUI_v1_0, *)
@usableFromInline
struct PreviewDisplayNameTraitKey: _ViewTraitKey {
    @inlinable
    static var defaultValue: String? { nil }
}

@available(*, unavailable)
extension PreviewDisplayNameTraitKey: Sendable {}

@available(OpenSwiftUI_v3_0, *)
@usableFromInline
struct PreviewInterfaceOrientationTraitKey: _ViewTraitKey {
    @inlinable
    static var defaultValue: InterfaceOrientation { .portrait }
}

@available(*, unavailable)
extension PreviewInterfaceOrientationTraitKey: Sendable {}

@available(OpenSwiftUI_v2_0, *)
@usableFromInline
struct PreviewContextTraitKey: _ViewTraitKey {
    @inlinable
    static var defaultValue: (any PreviewContext)? { nil }
}

@available(*, unavailable)
extension PreviewContextTraitKey: Sendable {}

// MARK: - Preview Extraction

@available(OpenSwiftUI_v1_0, *)
extension _PreviewProvider {
    /// Enumerates all preview payloads in the preview provider.
    ///
    /// Called by Xcode when gathering preview instances.
    public static var _allPreviews: [_Preview] {
        var visitor = MakePreviews(content: _previews)
        let conformance = ViewDescriptor.conformance(of: type(of: visitor.content))!
        conformance.visitType(visitor: &visitor)
        return visitor.previews
    }
}

/// Payload gathered by Xcode.
@available(OpenSwiftUI_v1_0, *)
public struct _Preview {
    let child: _VariadicView.Children.Element

    public let id: Int

    public let contentType: String

    public var content: AnyView {
        AnyView(child.view)
    }

    @available(OpenSwiftUI_v2_0, *)
    public var context: (any PreviewContext)? {
        child[PreviewContextTraitKey.self]
    }

    public var displayName: String? {
        child[PreviewDisplayNameTraitKey.self]
    }

    public var device: PreviewDevice? {
        child[PreviewDeviceTraitKey.self]
    }

    public var layout: PreviewLayout {
        child[PreviewLayoutTraitKey.self]
    }

    @available(OpenSwiftUI_v3_0, *)
    public var interfaceOrientation: InterfaceOrientation {
        child[PreviewInterfaceOrientationTraitKey.self]
    }

    @available(OpenSwiftUI_v2_3, *)
    public var colorScheme: ColorScheme? {
        child[PreviewColorSchemeTraitKey.self]
    }
}

@available(*, unavailable)
extension _Preview: Sendable {}

struct PreviewDescriptor: ProtocolDescriptor {
    static var descriptor: UnsafeRawPointer {
        _previewProviderProtocolDescriptor()
    }
}

private struct MakePreviews: ViewTypeVisitor {
    var content: Any

    var previews: [_Preview] = []

    mutating func visit<V: View>(type: V.Type) {
        previews = (content as! V)._allPreviews
    }
}

extension View {
    fileprivate var _allPreviews: [_Preview] {
        withChildrenForTest { children in
            children.enumerated().map { index, child in
                _Preview(
                    child: child,
                    id: index,
                    contentType: String(describing: type(of: child))
                )
            }
        }
    }
}
