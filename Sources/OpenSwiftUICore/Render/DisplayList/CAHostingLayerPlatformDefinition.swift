//
//  CAHostingLayerPlatformDefinition.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: E2A63CF3FB15FAD08FBE4CE6D0C83E51 (SwiftUICore)

#if canImport(QuartzCore)
import OpenSwiftUI_SPI
import QuartzCore
import QuartzCore_Private
import OpenRenderBoxShims

// MARK: - CAHostingLayerPlatformDefinition

final class CAHostingLayerPlatformDefinition: PlatformViewDefinition, @unchecked Sendable {
    override static var system: PlatformViewDefinition.System { .caLayer }

    override static func makeView(kind: PlatformViewDefinition.ViewKind) -> AnyObject {
        let layer = CALayer()
        if kind == .mask {
            let maskLayer = CALayer()
            layer.mask = maskLayer
            initLayer(layer.mask!, kind: .inherited)
        }
        initLayer(layer, kind: kind)
        return layer
    }

    override static func makeLayerView(type: CALayer.Type, kind: PlatformViewDefinition.ViewKind) -> AnyObject {
        let layer = type.init()
        initLayer(layer, kind: kind)
        return layer
    }

    override static func makePlatformView(view: AnyObject, kind: PlatformViewDefinition.ViewKind) {
        let layer = view as! CALayer
        Self.initLayer(layer, kind: kind)
    }

    override static func makeDrawingView(options: PlatformDrawableOptions) -> any PlatformDrawable {
        let layer: CALayer & PlatformDrawable
        if options.isAccelerated && ORBDevice.isSupported() {
            layer = RBDrawingLayer(options: options)
        } else {
            layer = CGDrawingLayer(options: options)
        }
        layer.contentsGravity = .topLeft
        initLayer(layer, kind: .drawing)
        return layer
    }

    override static func setPath(_ path: Path, shapeView: AnyObject) {
        _openSwiftUIEmptyStub()
    }

    override static func setProjectionTransform(_ transform: ProjectionTransform, projectionView: AnyObject) {
        let layer = projectionView as! CALayer
        layer.transform = CATransform3D(transform)
    }

    override static func getRBLayer(drawingView: AnyObject) -> AnyObject? {
        drawingView as? ORBLayer
    }

    override static func setIgnoresEvents(_ state: Bool, of view: AnyObject) {
        let layer = unsafeBitCast(view, to: CALayer.self)
        layer.allowsHitTesting = !state
    }

    private static func initLayer(_ layer: CALayer, kind: PlatformViewDefinition.ViewKind) {
        layer.delegate = CAPlatformLayerDelegate.shared
        layer.anchorPoint = .zero
        switch kind {
        case .color, .image, .shape:
            layer.allowsEdgeAntialiasing = true
        case .inherited, .geometry, .projection, .affine3D, .mask:
            layer.allowsGroupOpacity = false
            layer.allowsGroupBlending = false
        default:
            break
        }
    }
}

// MARK: - CAPlatformLayerDelegate

final class CAPlatformLayerDelegate: NSObject, CALayerDelegate {
    static let shared = CAPlatformLayerDelegate()

    func action(for layer: CALayer, forKey event: String) -> (any CAAction)? {
        _CANullAction()
    }
}

// MARK: - CGDrawingLayer

private final class CGDrawingLayer: CALayer, PlatformDrawable {
    var content: PlatformDrawableContent = .init()
    var state: PlatformDrawableContent.State = .init()
    var options: PlatformDrawableOptions {
        didSet {
            guard oldValue != options else { return }
            updateOptions()
        }
    }

    init(options: PlatformDrawableOptions) {
        self.options = options
        super.init()
        updateOptions()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func updateOptions() {
        isOpaque = options.isOpaque
        contentsFormat = options.caLayerContentsFormat
    }

    static var allowsContentsMultiplyColor: Bool { true }

    func update(content: PlatformDrawableContent?, required: Bool) -> Bool {
        if let content {
            self.content = content
        }
        setNeedsDisplay()
        return true
    }

    func makeAsyncUpdate(
        content: PlatformDrawableContent,
        required: Bool,
        layer: CALayer,
        bounds: CGRect
    ) -> (() -> Void)? {
        nil
    }

    func setContentsScale(_ scale: CGFloat) {
        contentsScale = scale
    }

    func drawForTesting(in displayList: ORBDisplayList) {
        var state = PlatformDrawableContent.State()
        content.draw(in: displayList, size: bounds.size, state: &state)
    }

    override func draw(in ctx: CGContext) {
        content.draw(
            in: ctx,
            size: bounds.size,
            contentsScale: contentsScale,
            state: &state
        )
    }
}

// MARK: - RBDrawingLayer

private final class RBDrawingLayer: ORBLayer, PlatformDrawable {
    var options: PlatformDrawableOptions {
        didSet {
            guard oldValue != options else { return }
            updateOptions()
        }
    }

    private struct State {
        var content: PlatformDrawableContent = .init()
        var renderer: PlatformDrawableContent.State = .init()
    }

    @AtomicBox
    private var state: RBDrawingLayer.State = .init()

    init(options: PlatformDrawableOptions) {
        self.options = options
        super.init()
        updateOptions()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func updateOptions() {
        isOpaque = options.isOpaque
        options.update(rbLayer: self)
    }

    static var allowsContentsMultiplyColor: Bool { false }

    func update(content: PlatformDrawableContent?, required: Bool) -> Bool {
        guard required || !options.rendersAsynchronously || isDrawableAvailable else {
            return false
        }
        if let content {
            state.content = content
        }
        setNeedsDisplay()
        return true
    }

    func makeAsyncUpdate(
        content: PlatformDrawableContent,
        required: Bool,
        layer: CALayer,
        bounds: CGRect
    ) -> (() -> Void)? {
        guard required || !options.rendersAsynchronously || isDrawableAvailable else {
            return nil
        }
        return { [self] in
            state.content = content
            display(withBounds: bounds) { displayList in
                self.draw(in: displayList, size: bounds.size)
            }
        }
    }

    func setContentsScale(_ scale: CGFloat) {
        contentsScale = scale
    }

    func drawForTesting(in displayList: ORBDisplayList) {
        var s = PlatformDrawableContent.State()
        state.content.draw(in: displayList, size: bounds.size, state: &s)
    }

    private func draw(in displayList: ORBDisplayList, size: CGSize) {
        var renderer = $state.access { state in
            let saved = state.renderer
            state.renderer = PlatformDrawableContent.State()
            return saved
        }
        let content = state.content
        content.draw(in: displayList, size: size, state: &renderer)
        $state.access { state in
            state.renderer = renderer
        }
    }
}

#endif
