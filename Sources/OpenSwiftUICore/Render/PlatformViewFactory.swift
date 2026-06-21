//
//  PlatformViewFactory.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: 7A45621CE16223183E03CAC88E8C5E60 (SwiftUICore)

package import Foundation
package import OpenQuartzCoreShims

// MARK: - AnyViewFactory

package protocol AnyViewFactory {
    var viewType: any Any.Type { get }

    func encoding() -> (id: String, data: any Codable)?
}

extension AnyViewFactory {
    package func encoding() -> (id: String, data: any Codable)? {
        nil
    }
}

extension AnyViewFactory where Self: View {
    package var viewType: any Any.Type {
        Self.self
    }
}

// MARK: - PlatformLayerFactory

package protocol PlatformLayerFactory: AnyViewFactory {
    var platformLayerType: CALayer.Type { get }

    func updatePlatformLayer(_ layer: CALayer)

    func renderPlatformLayer(
        in ctx: GraphicsContext,
        size: CGSize,
        renderer: DisplayList.GraphicsRenderer
    )
}

extension PlatformLayerFactory {
    package func renderPlatformLayer(
        in ctx: GraphicsContext,
        size: CGSize,
        renderer: DisplayList.GraphicsRenderer
    ) {
        if case .ignored = renderer.platformViewMode {
            return
        }
        Log.externalWarning("Unable to render flattened version of \(viewType).")
        // TODO: GraphicsContext
        ctx.renderMissingPlatformView(size: size)
    }
}

// MARK: - PlatformViewFactory

package protocol PlatformViewFactory: AnyViewFactory {
    func makePlatformView() -> AnyObject?

    func updatePlatformView(_ view: inout AnyObject)

    func renderPlatformView(
        in ctx: GraphicsContext,
        size: CGSize,
        renderer: DisplayList.GraphicsRenderer
    )

    var features: DisplayList.Features { get }
}

extension PlatformViewFactory {
    package func renderPlatformView(
        in ctx: GraphicsContext,
        size: CGSize,
        renderer: DisplayList.GraphicsRenderer
    ) {
        if case .ignored = renderer.platformViewMode {
            return
        }
        Log.externalWarning("Unable to render flattened version of \(viewType).")
        // TODO: GraphicsContext
        ctx.renderMissingPlatformView(size: size)
    }

    package var features: DisplayList.Features {
        [.required]
    }
}

extension RendererLeafView where Self: PlatformViewFactory {
    package func content() -> DisplayList.Content.Value {
        .platformView(self)
    }
}

// MARK: - PlatformGroupFactory [TODO]

package protocol PlatformGroupFactory: AnyViewFactory {
    func makePlatformGroup() -> AnyObject?

    func needsUpdateFor(newValue: any PlatformGroupFactory) -> Bool

    func updatePlatformGroup(_ view: inout AnyObject)

    func platformGroupContainer(_ view: AnyObject) -> AnyObject

    func renderPlatformGroup(
        _ list: DisplayList,
        in ctx: GraphicsContext,
        size: CGSize,
        renderer: DisplayList.GraphicsRenderer
    )

    var features: DisplayList.Features { get }
}

extension PlatformGroupFactory {
    package func renderPlatformGroup(
        _ list: DisplayList,
        in ctx: GraphicsContext,
        size: CGSize,
        renderer: DisplayList.GraphicsRenderer
    ) {
        var ctx = ctx
        renderer.render(list: list, in: &ctx)
    }

    package var features: DisplayList.Features {
        [.required]
    }
}

// MARK: - DisplayList.ViewFactory

package protocol _DisplayList_ViewFactory: AnyViewFactory {
    func makeView() -> AnyView

    var identity: DisplayList.Identity { get }
}

extension DisplayList.ViewFactory {
    package var identity: DisplayList.Identity {
        .none
    }
}

extension RendererLeafView where Self: _DisplayList_ViewFactory {
    package func content() -> DisplayList.Content.Value {
        .view(self)
    }
}

// MARK: - ViewDecoders

package struct ViewDecoders {
    package typealias DecodableViewFactory = Decodable & AnyViewFactory

    fileprivate struct DecodableFactoryDecoder {
        var decode: (Data, ProtobufDecoder) throws -> any AnyViewFactory
    }

    @AtomicBox
    fileprivate static var shared: ViewDecoders = .init()

    @AtomicBox
    fileprivate static var factoryDecoders: [String: DecodableFactoryDecoder] = [:]

    package static func registerDecodableFactoryType<T, U>(
        _ factoryType: T.Type,
        forType type: U.Type
    ) where T: Decodable, T: AnyViewFactory {
        registerDecodableFactoryType(
            factoryType,
            forID: _typeName(type, qualified: true)
        )
    }

    package static func registerDecodableFactoryType<T>(
        _ factoryType: T.Type,
        forID id: String
    ) where T: Decodable, T: AnyViewFactory {
        shared.decodableFactoryTypes[id] = factoryType
        factoryDecoders[id] = DecodableFactoryDecoder { data, decoder in
            try decoder.value(fromBinaryPlist: data, type: T.self)
        }
    }

    package static func registerStandard(_ body: () -> Void) {
        body()
    }

    fileprivate static func factoryDecoder(forID id: String) -> DecodableFactoryDecoder? {
        factoryDecoders[id]
    }

    fileprivate var decodableFactoryTypes: [String: any DecodableViewFactory.Type] = [:]

    fileprivate var hasRegisteredStandardDecoders = false
}

// MARK: - EmptyViewFactory [TODO]

package struct EmptyViewFactory: AnyViewFactory {
    package var viewType: any Any.Type {
        EmptyView.self
    }

    package init() {
        _openSwiftUIEmptyStub()
    }
}

extension EmptyViewFactory: PlatformLayerFactory {
    private class MissingLayer: CALayer {
        #if canImport(QuartzCore)
        required init?(coder: NSCoder) {
            super.init(coder: coder)
        }

        override init(layer: Any) {
            super.init(layer: layer)
        }

        override init() {
            super.init()
        }

        override func draw(in ctx: CGContext) {
            GraphicsContext.renderingTo(
                cgContext: ctx,
                environment: .init(),
                deviceScale: nil
            ) { context in
                // TODO: RB setup
                context.renderMissingPlatformView(size: bounds.size)
            }
        }

        override var needsDisplayOnBoundsChange: Bool {
            get { true }
            set {}
        }
        #endif
    }

    package var platformLayerType: CALayer.Type {
        MissingLayer.self
    }

    package func updatePlatformLayer(_ view: CALayer) {
        _openSwiftUIEmptyStub()
    }

    package func renderPlatformLayer(
        in ctx: GraphicsContext,
        size: CGSize,
        renderer: DisplayList.GraphicsRenderer
    ) {
        // TODO: RB
        ctx.renderMissingPlatformView(size: size)
    }
}

extension EmptyViewFactory: PlatformViewFactory {
    package func makePlatformView() -> AnyObject? {
        nil
    }

    package func updatePlatformView(_ view: inout AnyObject) {
        _openSwiftUIEmptyStub()
    }

    package var features: DisplayList.Features {
        [.required]
    }

    package func renderPlatformView(
        in ctx: GraphicsContext,
        size: CGSize,
        renderer: DisplayList.GraphicsRenderer
    ) {
        // TODO: RB
        ctx.renderMissingPlatformView(size: size)
    }
}

extension EmptyViewFactory: PlatformGroupFactory {
    package func makePlatformGroup() -> AnyObject? {
        nil
    }

    package func needsUpdateFor(newValue: any PlatformGroupFactory) -> Bool {
        false
    }

    package func updatePlatformGroup(_ view: inout AnyObject) {
        _openSwiftUIEmptyStub()
    }

    package func platformGroupContainer(_ view: AnyObject) -> AnyObject {
        view
    }

    package func renderPlatformGroup(
        _ list: DisplayList,
        in ctx: GraphicsContext,
        size: CGSize,
        renderer: DisplayList.GraphicsRenderer
    ) {
        // TODO: RB
        ctx.renderMissingPlatformView(size: size)
    }
}

extension EmptyViewFactory: DisplayList.ViewFactory {
    package func makeView() -> AnyView {
        AnyView(EmptyView())
    }
}

// MARK: - CodableViewFactory

struct CodableViewFactory: ProtobufMessage {
    var factory: any AnyViewFactory

    private enum Error: Swift.Error {
        case missingView(String)
        case invalidView
    }

    init(from decoder: inout ProtobufDecoder) throws {
        var id: String?
        var data = Data()
        while let field = try decoder.nextField() {
            switch field.tag {
            case 1:
                id = try decoder.stringField(field)
            case 2:
                data = try decoder.messageField(field)
            default:
                try decoder.skipField(field)
            }
        }
        guard let id else {
            factory = EmptyViewFactory()
            return
        }
        guard let factoryDecoder = ViewDecoders.factoryDecoder(forID: id) else {
            throw Error.missingView(id)
        }
        factory = try factoryDecoder.decode(data, decoder)
    }

    func encode(to encoder: inout ProtobufEncoder) throws {
        guard let encoding = factory.encoding() else {
            encoder.archiveHost?.failedToEncodeView(type: factory.viewType)
            return
        }
        try encoder.stringField(1, encoding.id)
        let data = try encoder.binaryPlistData(for: encoding.data)
        try encoder.messageField(2, data)
    }

}
