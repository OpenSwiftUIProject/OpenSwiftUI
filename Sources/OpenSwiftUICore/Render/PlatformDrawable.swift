//
//  PlatformDrawable.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: WIP

public import CoreGraphics
public import QuartzCore
import OpenAttributeGraphShims
import OpenRenderBoxShims
import CoreAnimation_Private

// MARK: - PlatformDrawable

@_spi(DisplayList_ViewSystem)
@available(OpenSwiftUI_v6_0, *)
public protocol PlatformDrawable: AnyObject {
    var options: PlatformDrawableOptions { get set }

    static var allowsContentsMultiplyColor: Bool { get }

    func update(content: PlatformDrawableContent?, required: Bool) -> Bool

    func makeAsyncUpdate(
        content: PlatformDrawableContent,
        required: Bool,
        layer: CALayer,
        bounds: CGRect
    ) -> (() -> Void)?

    func setContentsScale(_ scale: CGFloat)

    func drawForTesting(in: RBDisplayList) -> ()
}

// MARK: - PlatformDrawableContent

@_spi(DisplayList_ViewSystem)
@available(OpenSwiftUI_v6_0, *)
public struct PlatformDrawableContent: @unchecked Sendable {
    public struct State {
        package var mode: DisplayList.GraphicsRenderer.PlatformViewMode

        package var _renderer: DisplayList.GraphicsRenderer?

        package init() {
            _openSwiftUIUnimplementedFailure()
        }

        package init(platformViewMode: DisplayList.GraphicsRenderer.PlatformViewMode) {
            _openSwiftUIUnimplementedFailure()
        }

        package mutating func renderer() -> DisplayList.GraphicsRenderer {
            _openSwiftUIUnimplementedFailure()
        }
    }

    public init() {
        _openSwiftUIUnimplementedFailure()
    }

    public func draw(
        in ctx: CGContext,
        size: CGSize,
        contentsScale: CGFloat,
        state: inout PlatformDrawableContent.State
    ) {
        _openSwiftUIUnimplementedFailure()
    }

    public func draw(
        in list: RBDisplayList,
        size: CGSize,
        state: inout PlatformDrawableContent.State
    ) {
        _openSwiftUIUnimplementedFailure()
    }
}

@_spi(DisplayList_ViewSystem)
@available(*, unavailable)
extension PlatformDrawableContent.State: Sendable {}

// MARK: - PlatformDrawableOptions [Blocked by RBLayer]

@_spi(DisplayList_ViewSystem)
@available(OpenSwiftUI_v6_0, *)
public struct PlatformDrawableOptions: Equatable, Sendable {
    var base: RasterizationOptions

    public var isAccelerated: Bool {
        base.isAccelerated
    }

    public var isOpaque: Bool {
        base.isOpaque
    }

    public var rendersAsynchronously: Bool {
        base.rendersAsynchronously
    }

    public var rendersFirstFrameAsynchronously: Bool {
        base.rendersFirstFrameAsynchronously
    }

    public var caLayerContentsFormat: CALayerContentsFormat {
        var format = CALayerContentsFormat.automatic
        if base.flags.contains(.rgbaContext) {
            format = .RGBA8Uint
        }
        if base.flags.contains(.alphaOnly) {
            format = .A8
        }
        return format
    }

    public func update(rbLayer: AnyObject) {
        // TODO: RBLayer
        _openSwiftUIUnimplementedFailure()
    }
}
