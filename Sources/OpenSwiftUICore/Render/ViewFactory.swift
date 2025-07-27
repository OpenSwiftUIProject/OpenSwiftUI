//
//  ViewFactory.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  ID: 7A45621CE16223183E03CAC88E8C5E60 (SwiftUICore?)

package import Foundation
#if canImport(QuartzCore)
package import QuartzCore
#endif

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

// MARK: - PlatformLayerFactory [TODO]

#if canImport(QuartzCore)
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
        // TODO: render.platformViewMode
        _openSwiftUIUnimplementedFailure()
    }
}
#endif

// MARK: - PlatformViewFactory [TODO]

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
        // TODO: render.platformViewMode
        _openSwiftUIUnimplementedFailure()
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
        // TODO: RB
        _openSwiftUIUnimplementedFailure()
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

    @AtomicBox
    private static var shared: ViewDecoders = .init()

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
        _openSwiftUIUnimplementedFailure()
    }

    package static func registerStandard(_ body: () -> Void) {
        body()
    }

    private var decodableFactoryTypes: [String: any DecodableViewFactory.Type] = [:]

    private var hasRegisteredStandardDecoders = false
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

#if canImport(QuartzCore)
extension EmptyViewFactory: PlatformLayerFactory {
    private class MissingLayer: CALayer {
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
                deviceScale: .zero
            ) { _ in
                _openSwiftUIUnimplementedFailure()
            }
        }

        override var needsDisplayOnBoundsChange: Bool {
            get { true }
            set {}
        }
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
        _openSwiftUIUnimplementedFailure()
    }
}
#endif

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
        _openSwiftUIUnimplementedFailure()
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
        _openSwiftUIUnimplementedFailure()
    }

    package func renderPlatformGroup(
        _ list: DisplayList,
        in ctx: GraphicsContext,
        size: CGSize,
        renderer: DisplayList.GraphicsRenderer
    ) {
        _openSwiftUIUnimplementedFailure()
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
        _openSwiftUIUnimplementedFailure()
    }

    func encode(to encoder: inout ProtobufEncoder) throws {
        guard let encoding = factory.encoding() else {
            // TODO: encoder.archiveHost
            _openSwiftUIUnimplementedFailure()
        }
        _openSwiftUIUnimplementedFailure()
    }
}
