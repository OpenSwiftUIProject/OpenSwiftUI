//
//  RendererConfiguration.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete

public import Foundation

// MARK: - _RendererConfiguration

/// Renderer configuration for a hosting view.
@available(OpenSwiftUI_v2_0, *)
public struct _RendererConfiguration {

    /// The available renderer kind and their configuration.
    public enum Renderer {
        /// The default renderer for the current platform.
        case `default`

        /// An alternative renderer that rasterizes everything in the
        /// local process.
        indirect case rasterized(_ options: _RendererConfiguration.RasterizationOptions = .init())

        /* OpenSwiftUI Addition Begin */
        /// A renderer that writes a textual representation of the display list
        /// to standard output.
        @_spi(StdoutRenderer)
        indirect case stdout(_ options: _RendererConfiguration.StdoutOptions = .init())
        /* OpenSwiftUI Addition End */
    }

    /// The renderer kind and its specific configuration.
    public var renderer: _RendererConfiguration.Renderer

    /// The minimum time between display updates. Zero means to attempt
    /// to match the natural display update rate, infinity means to
    /// disable animations, values in between clamp the delay between
    /// animation updates.
    public var minFrameInterval: Double

    public init(renderer: _RendererConfiguration.Renderer = .default) {
        self.renderer = renderer
        self.minFrameInterval = .zero
    }

    /// Returns a configuration to render as a rasterized bitmap.
    public static func rasterized(_ options: _RendererConfiguration.RasterizationOptions = .init()) -> _RendererConfiguration {
        _RendererConfiguration(renderer: .rasterized(options))
    }

    /* OpenSwiftUI Addition Begin */

    /// Returns a configuration to render the display list to standard output.
    @_spi(StdoutRenderer)
    public static func stdout(_ options: _RendererConfiguration.StdoutOptions = .init()) -> _RendererConfiguration {
        _RendererConfiguration(renderer: .stdout(options))
    }

    /* OpenSwiftUI Addition End */

    /* OpenSwiftUI Addition Begin */

    // MARK: - _RendererConfiguration.StdoutOptions

    /// Options for the `stdout` renderer.
    @_spi(StdoutRenderer)
    public struct StdoutOptions {
        /// The surface size reported by the stdout renderer.
        public var surface: CGSize = defaultSurfaceSize

        // TODO: Get from host platform API
        private static let defaultSurfaceSize = CGSize(width: 640.0, height: 480.0)

        public init() {}
    }

    /* OpenSwiftUI Addition End */

    // MARK: - _RendererConfiguration.RasterizationOptions

    /// Options for the `rasterized` renderer.
    public struct RasterizationOptions {

        /// The color mode to use when rendering the view.
        public var colorMode: ColorRenderingMode = .nonLinear

        /// When non-nil overrides colorMode with a member of the
        /// `RBColorMode` enum, specified as its raw integer value.
        public var rbColorMode: Int32?

        /// When true the view will build and submit its command buffer
        /// asynchronously.
        public var rendersAsynchronously: Bool = false

        /// When true no alpha component is created for the view’s
        /// content. Setting this value will often require less memory.
        public var isOpaque: Bool = true

        /// When true native platform views that have been inserted
        /// into the view hierarchy (e.g. via UIViewRepresentable) will
        /// be drawn via their CALayer’s -renderInContext: method
        /// (after updating their view bounds).
        public var drawsPlatformViews: Bool = true

        /// Set this to true to avoid using buffer formats that would
        /// disable display compositing; doing so may increase memory
        /// requirements.
        public var prefersDisplayCompositing: Bool = false

        /// The maximum number of surfaces that will be allocated by
        /// the view, will currently be clamped to the range [2, 3].
        public var maxDrawableCount: Int = 3

        public init() {
            _openSwiftUIEmptyStub()
        }
    }
}

@available(*, unavailable)
extension _RendererConfiguration: Sendable {}

@available(*, unavailable)
extension _RendererConfiguration.Renderer: Sendable {}

@available(*, unavailable)
extension _RendererConfiguration.RasterizationOptions: Sendable {}

/* OpenSwiftUI Addition Begin */
@_spi(StdoutRenderer)
@available(*, unavailable)
extension _RendererConfiguration.StdoutOptions: Sendable {}
/* OpenSwiftUI Addition End */

// MARK: - RasterizationOptions + _RendererConfiguration.RasterizationOptions

extension RasterizationOptions {

    /// Convert from the public `_RendererConfiguration.RasterizationOptions`
    /// to the internal `RasterizationOptions`.
    package init(_ options: _RendererConfiguration.RasterizationOptions) {
        var flags: RasterizationOptions.Flags = .defaultFlags
        flags.formUnion(.isAccelerated)
        if options.isOpaque {
            flags.formUnion(.isOpaque)
        } else {
            flags.subtract([.isOpaque, .rendersAsynchronously, .prefersDisplayCompositing])
        }
        if options.rendersAsynchronously {
            flags.formUnion(.rendersAsynchronously)
        }
        if options.prefersDisplayCompositing {
            flags.formUnion(.prefersDisplayCompositing)
        }
        self.init(
            colorMode: options.colorMode,
            rbColorMode: options.rbColorMode,
            flags: flags,
            maxDrawableCount: Int8(truncatingIfNeeded: options.maxDrawableCount)
        )
    }
}
