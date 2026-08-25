//
//  ArchivableViewModifier.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: AEFE64754898958178E5A28858968BE8 (SwiftUI)

import OpenAttributeGraphShims
import OpenCoreGraphicsShims
@_spi(ForOpenSwiftUIOnly)
public import OpenSwiftUICore

// MARK: - _ArchivableViewModifier

@_spi(Private)
@available(OpenSwiftUI_v2_0, *)
public protocol _ArchivableViewModifier: Decodable, Encodable, ViewModifier {}

// MARK: - _ArchivableViewModifier + Default implementation

@_spi(Private)
@available(OpenSwiftUI_v2_0, *)
extension _ArchivableViewModifier {
    public static func registerDecoder() {
        ViewDecoders.registerDecodableFactoryType(
            ArchivableFactory<Self>.self,
            forType: Self.self
        )
    }

    nonisolated public static func _makeView(
        modifier: _GraphValue<Self>,
        inputs: _ViewInputs,
        body: @escaping (_Graph, _ViewInputs) -> _ViewOutputs
    ) -> _ViewOutputs {
        makeArchivableView(modifier: modifier, inputs: inputs, body: body)
    }

    nonisolated public static func _makeViewList(
        modifier: _GraphValue<Self>,
        inputs: _ViewListInputs,
        body: @escaping (_Graph, _ViewListInputs) -> _ViewListOutputs
    ) -> _ViewListOutputs {
        makeMultiViewList(modifier: modifier, inputs: inputs, body: body)
    }

    nonisolated public static func _viewListCount(
        inputs: _ViewListCountInputs,
        body: (_ViewListCountInputs) -> Int?
    ) -> Int? {
        body(inputs)
    }

    nonisolated static func makeArchivableView(
        modifier: _GraphValue<Self>,
        inputs: _ViewInputs,
        body: @escaping (_Graph, _ViewInputs) -> _ViewOutputs
    ) -> _ViewOutputs {
        guard inputs.archivedView.isArchived else {
            return makeView(modifier: modifier, inputs: inputs, body: body)
        }

        var childInputs = inputs
        childInputs.containerPosition = inputs.animatedPosition()
        var outputs = body(_Graph(), childInputs)
        if inputs.preferences.requiresDisplayList {
            let identity = DisplayList.Identity()
            inputs.pushIdentity(identity)
            outputs.displayList = Attribute(
                ArchivableDisplayList(
                    identity: identity,
                    modifier: modifier.value,
                    position: inputs.animatedPosition(),
                    size: inputs.animatedSize(),
                    containerPosition: inputs.containerPosition,
                    content: .init(outputs.displayList),
                    options: inputs[DisplayList.Options.self]
                )
            )
        }
        return outputs
    }
}

// MARK: - ArchivableViewModifier

protocol ArchivableViewModifier: _ArchivableViewModifier {
    func sizeThatFits(in proposedSize: _ProposedSize, child: LayoutProxy) -> CGSize
}

// MARK: - ArchivableFactory

private struct ArchivableFactory<Modifier>: Codable, _DisplayList_ViewFactory where Modifier: Decodable, Modifier: Encodable, Modifier: ViewModifier {
    var modifier: Modifier
    var identity: DisplayList.Identity
    var size: CGSize

    init(modifier: Modifier, identity: DisplayList.Identity, size: CGSize) {
        self.modifier = modifier
        self.identity = identity
        self.size = size
    }

    func makeView() -> AnyView {
        AnyView(
            ArchivablePlaceholder(identity: identity, size: size)
                .modifier(modifier)
        )
    }

    var viewType: any Any.Type {
        Modifier.self
    }

    func encoding() -> (id: String, data: any Codable)? {
        (_typeName(Modifier.self), self)
    }
}

// MARK: - ArchivablePlaceholder

struct ArchivablePlaceholder: RendererLeafView, LeafViewLayout {
    var identity: DisplayList.Identity
    var size: CGSize

    nonisolated static func _makeView(
        view: _GraphValue<Self>,
        inputs: _ViewInputs
    ) -> _ViewOutputs {
        var outputs = makeLeafView(view: view, inputs: inputs)
        makeLeafLayout(&outputs, view: view, inputs: inputs)
        return outputs
    }

    func sizeThatFits(in proposedSize: _ProposedSize) -> CGSize {
        size
    }

    func content() -> DisplayList.Content.Value {
        .placeholder(id: identity)
    }
}

// MARK: - ArchivableDisplayList

private struct ArchivableDisplayList<Modifier>: Rule where Modifier: Decodable, Modifier: Encodable, Modifier: ViewModifier {
    let identity: DisplayList.Identity
    @Attribute var modifier: Modifier
    @Attribute var position: CGPoint
    @Attribute var size: ViewSize
    @Attribute var containerPosition: CGPoint
    @OptionalAttribute var content: DisplayList?
    let options: DisplayList.Options

    var value: DisplayList {
        let content = content ?? DisplayList()
        let factory = ArchivableFactory(
            modifier: modifier,
            identity: identity,
            size: size.value
        )
        var item = DisplayList.Item(
            .effect(.view(factory), content),
            frame: CGRect(
                origin: CGPoint(position - containerPosition),
                size: size.value
            ),
            identity: identity,
            version: .init(forUpdate: ())
        )
        item.canonicalize(options: options)
        return DisplayList(item)
    }
}
