//
//  ArchivableView.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: 6FA990C14046D436153684F76C220350 (SwiftUI)

import OpenAttributeGraphShims
public import OpenCoreGraphicsShims
@_spi(ForOpenSwiftUIOnly)
public import OpenSwiftUICore

// MARK: - _ArchivableView

@_spi(Private)
@available(OpenSwiftUI_v2_0, *)
public protocol _ArchivableView: Decodable, Encodable, View {
    func sizeThatFits(in proposedSize: _ProposedSize) -> CGSize
}

// MARK: - _ArchivableView + Default implementation

@_spi(Private)
@available(OpenSwiftUI_v2_0, *)
extension _ArchivableView {
    public static func registerDecoder() {
        ViewDecoders.registerDecodableFactoryType(
            ArchivableFactory<Self>.self,
            forType: Self.self
        )
    }

    public func sizeThatFits(in proposedSize: _ProposedSize) -> CGSize {
        proposedSize.fixingUnspecifiedDimensions()
    }

    nonisolated public static func _makeView(
        view: _GraphValue<Self>,
        inputs: _ViewInputs
    ) -> _ViewOutputs {
        guard inputs.archivedView.isArchived else {
            var inputs = inputs
            inputs.requestsLayoutComputer = false
            return makeView(view: view, inputs: inputs)
        }

        var outputs = _ViewOutputs()
        if inputs.preferences.requiresDisplayList {
            let identity = DisplayList.Identity()
            inputs.pushIdentity(identity)
            outputs.displayList = Attribute(
                ArchivableDisplayList(
                    identity: identity,
                    view: view.value,
                    position: inputs.animatedPosition(),
                    size: inputs.animatedSize(),
                    containerPosition: inputs.containerPosition,
                    contentSeed: .init()
                )
            )
        }
        if inputs.requestsLayoutComputer {
            outputs.layoutComputer = Attribute(
                ArchivableLayoutComputer(view: view.value)
            )
        }
        return outputs
    }

    nonisolated public static func _makeViewList(
        view: _GraphValue<Self>,
        inputs: _ViewListInputs
    ) -> _ViewListOutputs {
        _ViewListOutputs.unaryViewList(view: view, inputs: inputs)
    }

    nonisolated public static func _viewListCount(
        inputs: _ViewListCountInputs
    ) -> Int? {
        1
    }
}

// MARK: - ArchivableFactory

private struct ArchivableFactory<V>: Codable, _DisplayList_ViewFactory where V: _ArchivableView {
    var view: V

    func makeView() -> AnyView {
        AnyView(view)
    }

    var viewType: any Any.Type {
        V.self
    }

    func encoding() -> (id: String, data: any Codable)? {
        (_typeName(V.self), view)
    }
}

// MARK: - ArchivableLayoutComputer

private struct ArchivableLayoutComputer<V>: StatefulRule where V: _ArchivableView {
    @Attribute var view: V

    typealias Value = LayoutComputer

    mutating func updateValue() {
        update(to: Engine(view: view, cache: ViewSizeCache()))
    }

    struct Engine: LayoutEngine {
        let view: V
        var cache: ViewSizeCache

        init(view: V, cache: ViewSizeCache) {
            self.view = view
            self.cache = cache
        }

        mutating func sizeThatFits(_ proposedSize: _ProposedSize) -> CGSize {
            let view = view
            return cache.get(proposedSize) {
                view.sizeThatFits(in: proposedSize)
            }
        }
    }
}

// MARK: - ArchivableDisplayList

private struct ArchivableDisplayList<V>: StatefulRule where V: _ArchivableView {
    let identity: DisplayList.Identity
    @Attribute var view: V
    @Attribute var position: CGPoint
    @Attribute var size: ViewSize
    @Attribute var containerPosition: CGPoint
    var contentSeed: DisplayList.Seed

    typealias Value = DisplayList

    mutating func updateValue() {
        let (view, viewChanged) = $view.changedValue()
        let version = DisplayList.Version(forUpdate: ())
        if viewChanged {
            contentSeed = DisplayList.Seed(version)
        }
        let content = DisplayList.Content(
            .view(ArchivableFactory(view: view)),
            seed: contentSeed
        )
        let item = DisplayList.Item(
            .content(content),
            frame: CGRect(
                origin: CGPoint(position - containerPosition),
                size: size.value
            ),
            identity: identity,
            version: version
        )
        value = DisplayList(item)
    }
}
