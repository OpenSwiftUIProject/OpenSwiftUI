//
//  RendererConfiguration.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete

public import Foundation
public import OpenCoreGraphicsShims

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
        #if !OPENSWIFTUI_SWIFTUI_RENDERER
        /// A renderer that writes a textual representation of the display list
        /// to standard output.
        @_spi(StdoutRenderer)
        indirect case stdout(_ options: _RendererConfiguration.StdoutOptions = .init())

        #if os(WASI) && !OPENSWIFTUI_SWIFTUI_RENDERER
        /// A renderer that forwards a static display-list frame to a web
        /// surface owned by the embedding application.
        @_spi(WebRenderer)
        indirect case web(_ options: _RendererConfiguration.WebOptions)
        #endif
        #endif
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

    #if !OPENSWIFTUI_SWIFTUI_RENDERER
    /// Returns a configuration to render the display list to standard output.
    @_spi(StdoutRenderer)
    public static func stdout(_ options: _RendererConfiguration.StdoutOptions = .init()) -> _RendererConfiguration {
        _RendererConfiguration(renderer: .stdout(options))
    }

    #if os(WASI) && !OPENSWIFTUI_SWIFTUI_RENDERER
    /// Returns a configuration that renders display-list frames to a web
    /// surface owned by the embedding application.
    @_spi(WebRenderer)
    public static func web(_ options: _RendererConfiguration.WebOptions) -> _RendererConfiguration {
        _RendererConfiguration(renderer: .web(options))
    }
    #endif
    #endif

    /* OpenSwiftUI Addition End */

    /* OpenSwiftUI Addition Begin */

    // MARK: - _RendererConfiguration.StdoutOptions

    /// Options for the `stdout` renderer.
    @_spi(StdoutRenderer)
    public struct StdoutOptions {
        /// The representation written by the stdout renderer.
        public enum ViewMode: Equatable {
            /// Writes the display list as a sequence of textual render commands.
            case displayList

            /// Renders the display list into a terminal-cell canvas.
            case terminal
        }

        /// The terminal color capability used by terminal view mode.
        public enum ColorMode: Equatable {
            /// Detects color support from standard output and the process
            /// environment.
            case automatic

            /// Does not emit ANSI color escape sequences.
            case monochrome

            /// Emits colors from the 16-color ANSI palette.
            case ansi16

            /// Emits colors from the 256-color ANSI palette.
            case ansi256

            /// Emits 24-bit ANSI colors.
            case trueColor
        }

        /// The dimensions of a terminal-cell canvas.
        public struct TerminalSize {
            /// The number of columns in the canvas.
            public var columns: Int

            /// The number of rows in the canvas.
            public var rows: Int

            public init(columns: Int, rows: Int) {
                self.columns = columns
                self.rows = rows
            }
        }

        /// The surface size reported by the stdout renderer.
        public var surface: CGSize = defaultSurfaceSize

        /// The representation written by the stdout renderer.
        public var viewMode: ViewMode = .displayList

        /// The color capability used by terminal view mode.
        public var colorMode: ColorMode = .automatic

        /// An optional terminal size override. When `nil`, the renderer reads
        /// the size from standard output and falls back to 80 columns by 24
        /// rows.
        public var terminalSize: TerminalSize?

        // TODO: Get from host platform API
        private static let defaultSurfaceSize = CGSize(width: 640.0, height: 480.0)

        public init() {}
    }

    #if os(WASI) && !OPENSWIFTUI_SWIFTUI_RENDERER
    // MARK: - _RendererConfiguration.WebOptions

    /// Options for the `web` renderer.
    @_spi(WebRenderer)
    public struct WebOptions {
        /// The logical size of the web rendering surface.
        public var surface: CGSize

        /// Receives browser pointer input for this renderer's gesture graph.
        public var eventBridge: _WebEventBridge

        /// Measures a single-line text run synchronously in logical pixels.
        public var measureText: (_WebTextMeasurementRequest) -> _WebTextMetrics

        /// Called synchronously whenever a new static frame is available.
        public var onRender: (_WebRenderFrame) -> Void

        public init(
            surface: CGSize = CGSize(width: 640.0, height: 480.0),
            eventBridge: _WebEventBridge = .init(),
            measureText: @escaping (_WebTextMeasurementRequest) -> _WebTextMetrics,
            onRender: @escaping (_WebRenderFrame) -> Void
        ) {
            self.surface = surface
            self.eventBridge = eventBridge
            self.measureText = measureText
            self.onRender = onRender
        }
    }
    #endif

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

#if os(WASI) && !OPENSWIFTUI_SWIFTUI_RENDERER
@_spi(WebRenderer)
@available(*, unavailable)
extension _RendererConfiguration.WebOptions: Sendable {}
#endif
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
