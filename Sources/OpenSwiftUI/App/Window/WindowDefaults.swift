//
//  WindowDefaults.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: DC3B6BB33515D28F933944098F93ADC2 (SwiftUI)

import Foundation
import OpenAttributeGraphShims
@_spi(ForOpenSwiftUIOnly)
import OpenSwiftUICore

// MARK: - Scene + defaultPosition

@available(OpenSwiftUI_v4_0, *)
@available(iOS, unavailable)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
@available(visionOS, unavailable)
extension Scene {

    /// Sets a default position for a window.
    ///
    /// The first time your app opens a window from a particular scene
    /// declaration, the system places the window at the center of the screen by
    /// default. For scene types that support multiple simultaneous windows, the
    /// system offsets each additional window by a small amount to avoid
    /// completely obscuring existing windows.
    ///
    /// You can override the default placement of the first window by
    /// applying a scene modifier that indicates where to place the window
    /// relative to the screen bounds. For example, you can request that the
    /// system place a new window in the bottom trailing corner of the screen:
    ///
    ///     @main
    ///     struct MyApp: App {
    ///         var body: some Scene {
    ///             WindowGroup {
    ///                 ContentView()
    ///             }
    ///             .defaultPosition(.bottomTrailing)
    ///         }
    ///     }
    ///
    /// The system aligns the point in the window that corresponds to the
    /// specified ``UnitPoint`` with the point in the screen that corresponds
    /// to the same unit point.
    ///
    /// You typically use one of the predefined unit points --- like
    /// ``UnitPoint/bottomTrailing`` in the above example --- but
    /// you can also use a custom unit point. For example, the following
    /// modifier aligns the point that's one quarter of the way from the
    /// leading edge of the window with the point that's one quarter of
    /// the way from the leading edge of the screen, while centering the
    /// window in the y-dimension:
    ///
    ///     WindowGroup {
    ///         ContentView()
    ///     }
    ///     .defaultPosition(UnitPoint(x: 0.25, y: 0.5))
    ///
    /// The modifier affects any scene type that creates windows in macOS,
    /// namely:
    ///
    ///  * ``WindowGroup``
    ///  * ``Window``
    ///  * ``DocumentGroup``
    ///  * ``Settings``
    ///
    /// The value that you provide acts only as an initial default. During state
    /// restoration, the system restores the window to the position that it
    /// last occupied.
    ///
    /// - Parameter position: A ``UnitPoint`` that specifies where to place a
    ///   newly opened window relative to the screen bounds.
    ///
    /// - Returns: A scene that uses a default position for new windows.
    nonisolated public func defaultPosition(_ position: UnitPoint) -> some Scene {
        modifier(WindowDefaultsPropertyModifier(property: .position(position)))
    }
}

// MARK: - Scene + defaultSize

@available(OpenSwiftUI_v4_0, *)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
extension Scene {

    /// Sets a default size for a window.
    ///
    /// Use this scene modifier to indicate a default initial size for a new
    /// window that the system creates from a ``Scene`` declaration. For
    /// example, you can request that new windows that a ``WindowGroup``
    /// generates occupy 600 points in the x-dimension and 400 points in
    /// the y-dimension:
    ///
    ///     @main
    ///     struct MyApp: App {
    ///         var body: some Scene {
    ///             WindowGroup {
    ///                 ContentView()
    ///             }
    ///             .defaultSize(CGSize(width: 600, height: 400))
    ///         }
    ///     }
    ///
    /// The size that you specify acts only as a default for when the window
    /// first appears. People can later resize the window using interface
    /// controls that the system provides. Also, during state restoration,
    /// the system restores windows to their most recent size rather than
    /// the default size.
    ///
    /// If you specify a default size that's outside the range of the window's
    /// inherent resizability in one or both dimensions, the system clamps the
    /// affected dimension to keep it in range. You can configure the
    /// resizability of a scene using the
    /// ``Scene/windowResizability(_:)``
    /// modifier.
    ///
    /// The default size modifier affects any scene type that creates windows
    /// in macOS, namely:
    ///
    ///  * ``WindowGroup``
    ///  * ``Window``
    ///  * ``DocumentGroup``
    ///  * ``Settings``
    ///
    /// If you want to specify the input directly in terms of width and height,
    /// use ``Scene/defaultSize(width:height:)`` instead.
    ///
    /// - Parameter size: The default size for new windows created from a scene.
    ///
    /// - Returns: A scene that uses a default size for new windows.
    nonisolated public func defaultSize(_ size: CGSize) -> some Scene {
        defaultSize(width: size.width, height: size.height)
    }

    /// Sets a default width and height for a window.
    ///
    /// Use this scene modifier to indicate a default initial size for a new
    /// window that the system creates from a ``Scene`` declaration. For
    /// example, you can request that new windows that a ``WindowGroup``
    /// generates occupy 600 points in the x-dimension and 400 points in
    /// the y-dimension:
    ///
    ///     @main
    ///     struct MyApp: App {
    ///         var body: some Scene {
    ///             WindowGroup {
    ///                 ContentView()
    ///             }
    ///             .defaultSize(width: 600, height: 400)
    ///         }
    ///     }
    ///
    /// The size that you specify acts only as a default for when the window
    /// first appears. People can later resize the window using interface
    /// controls that the system provides. Also, during state restoration,
    /// the system restores windows to their most recent size rather than
    /// the default size.
    ///
    /// If you specify a default size that's outside the range of the window's
    /// inherent resizability in one or both dimensions, the system clamps the
    /// affected dimension to keep it in range. You can configure the
    /// resizability of a scene using the
    /// ``Scene/windowResizability(_:)``
    /// modifier.
    ///
    /// The default size modifier affects any scene type that creates windows
    /// in macOS, namely:
    ///
    ///  * ``WindowGroup``
    ///  * ``Window``
    ///  * ``DocumentGroup``
    ///  * ``Settings``
    ///
    /// If you want to specify the size input in terms of size instance,
    /// use ``Scene/defaultSize(_:)`` instead.
    ///
    /// - Parameter width: The default width for windows created from a scene.
    /// - Parameter height: The default height for windows created from a scene.
    ///
    /// - Returns: A scene that uses a default size for new windows.
    nonisolated public func defaultSize(width: CGFloat, height: CGFloat) -> some Scene {
        modifier(WindowDefaultsPropertyModifier(property: .size(CGSize(width: width, height: height))))
    }
}

// MARK: - WindowCascadeBehavior

struct WindowCascadeBehavior {
    enum Role: Hashable {
        case automatic
        case always
        case never
        case positionOnly
    }

    var role: Role

    static var automatic: WindowCascadeBehavior {
        .init(role: .automatic)
    }

    static var always: WindowCascadeBehavior {
        .init(role: .always)
    }

    static var never: WindowCascadeBehavior {
        .init(role: .never)
    }

    static var positionOnly: WindowCascadeBehavior {
        .init(role: .positionOnly)
    }
}

extension Scene {
    @available(iOS, unavailable)
    @available(tvOS, unavailable)
    @available(watchOS, unavailable)
    @available(visionOS, unavailable)
    func windowCascadeBehavior(_ behavior: WindowCascadeBehavior) -> some Scene {
        #if os(macOS)
        transformPreference(SceneList.Key.self) { list in
            for index in list.items.indices {
                list.items[index].cascadeBehavior = behavior.role
            }
        }
        #else
        _openSwiftUIUnreachableCode()
        #endif
    }
}

@available(iOS, unavailable)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
@available(visionOS, unavailable)
enum WindowSizeConstants {
    static let defaultProposedSize = _ProposedSize(width: 900, height: 450)
}

// MARK: - WindowDefaultsPropertyModifier

@available(iOS, unavailable)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
@available(visionOS, unavailable)
private struct WindowDefaultsPropertyModifier: PrimitiveSceneModifier {
    enum Property {
        case position(UnitPoint)
        case size(CGSize)
    }

    var property: Property

    static func _makeScene(
        modifier: _GraphValue<Self>,
        inputs: _SceneInputs,
        body: @escaping (_Graph, _SceneInputs) -> _SceneOutputs
    ) -> _SceneOutputs {
        var outputs = body(_Graph(), inputs)
        if inputs.preferences.requiresSceneList {
            outputs.preferences.sceneList = Attribute(
                UpdateSceneList(
                    modifier: modifier.value,
                    sceneList: OptionalAttribute(outputs.preferences.sceneList)
                )
            )
        }
        return outputs
    }

    struct UpdateSceneList: Rule {
        @Attribute var modifier: WindowDefaultsPropertyModifier
        @OptionalAttribute var sceneList: SceneList?

        var value: SceneList {
            guard let sceneList else {
                return SceneList(items: [])
            }
            return SceneList(items: sceneList.items.map { item in
                var item = item
                switch modifier.property {
                case let .position(position):
                    item.defaultPosition = position
                case let .size(size):
                    item.defaultSize = size
                }
                return item
            })
        }
    }
}
