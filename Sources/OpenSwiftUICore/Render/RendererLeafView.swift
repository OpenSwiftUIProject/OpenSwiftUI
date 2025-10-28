//
//  RendererLeafView.swift
//  OpenSwiftUICore
//
//  Audited for 6.0.87
//  ID: 65609C35608651F66D749EB1BD9D2226 (SwiftUICore)
//  Status: WIP

package import Foundation
package import OpenAttributeGraphShims

// MARK: - RendererLeafView [TODO]

package protocol RendererLeafView: ContentResponder, PrimitiveView, UnaryView {
    static var requiresMainThread: Bool { get }
    func content() -> DisplayList.Content.Value
}

extension RendererLeafView {
    package static var requiresMainThread: Bool {
        false
    }
    
    func contains(points: [PlatformPoint], size: CGSize) -> BitVector64 {
        _openSwiftUIUnimplementedFailure()
    }
    
    package static func makeLeafView(view: _GraphValue<Self>, inputs: _ViewInputs) -> _ViewOutputs {
        var outputs = _ViewOutputs()
        
        if inputs.preferences.requiresDisplayList {
            let identity = DisplayList.Identity()
            inputs.pushIdentity(identity)
            
            outputs.preferences.displayList = Attribute(
                LeafDisplayList(
                    identity: identity,
                    view: view.value,
                    position: inputs.animatedPosition(),
                    size: inputs.animatedCGSize(),
                    containerPosition: inputs.containerPosition,
                    options: inputs.displayListOptions,
                    contentSeed: DisplayList.Seed()
                )
            )
        }
        
        if inputs.preferences.requiresViewResponders {
            outputs.preferences.viewResponders = Attribute(
                LeafResponderFilter(
                    data: view.value,
                    size: inputs.animatedSize(),
                    position: inputs.animatedPosition(),
                    transform: inputs.transform
                )
            )
        }
        
        // TODO
//        outputs.makeContentPathPreferenceWriter(
//            inputs: inputs,
//            contentResponder: view.value
//        )
        
        return outputs
    }
}

package struct LeafResponderFilter<Data>: StatefulRule {
    @Attribute private var data: Data
    @Attribute private var size: ViewSize
    @Attribute private var position: CGPoint
    @Attribute private var transform: ViewTransform
    package private(set) lazy var responder = LeafViewResponder<Data>()
    
    package init(
        data: Attribute<Data>,
        size: Attribute<ViewSize>,
        position: Attribute<CGPoint>,
        transform: Attribute<ViewTransform>
    ) {
        self._data = data
        self._size = size
        self._position = position
        self._transform = transform
    }
    
    package typealias Value = [ViewResponder]
    
    package func updateValue() {
        _openSwiftUIUnimplementedWarning()
    }
}

package final class LeafViewResponder<Data>: ViewResponder {
    // TODO
}

// MARK: - LeafViewLayout

package protocol LeafViewLayout {
    func spacing() -> Spacing
    func sizeThatFits(in proposedSize: _ProposedSize) -> CGSize
}

extension LeafViewLayout {
    package func spacing() -> Spacing {
        Spacing()
    }

    package static func makeLeafLayout(_ outputs: inout _ViewOutputs, view: _GraphValue<Self>, inputs: _ViewInputs) {
        guard inputs.requestsLayoutComputer else {
            return
        }
        outputs.layoutComputer = Attribute(LeafLayoutComputer(view: view.value))
    }
}

// MARK: - LeafLayoutComputer

private struct LeafLayoutComputer<V>: StatefulRule, AsyncAttribute, CustomStringConvertible where V: LeafViewLayout {
    @Attribute
    package var view: V

    typealias Value = LayoutComputer

    mutating func updateValue() {
        let engine = LeafLayoutEngine(view)
        update(to: engine)
    }

    var description: String { "LeafLayoutComputer" }
}

// MARK: - LeafLayoutEngine

package struct LeafLayoutEngine<V>: LayoutEngine where V: LeafViewLayout {
    package let view: V

    private var cache: ViewSizeCache

    package init(_ view: V) {
        self.view = view
        self.cache = ViewSizeCache()
    }

    package func spacing() -> Spacing {
        view.spacing()
    }

    package mutating func sizeThatFits(_ proposedSize: _ProposedSize) -> CGSize {
        let view = view
        return cache.get(proposedSize) {
            view.sizeThatFits(in: proposedSize)
        }
    }
}

// MARK: - LeafDisplayList [WIP]

private struct LeafDisplayList<V>: StatefulRule, CustomStringConvertible where V: RendererLeafView {
    let identity: DisplayList.Identity
    @Attribute var view: V
    @Attribute var position: ViewOrigin
    @Attribute var size: CGSize
    @Attribute var containerPosition: ViewOrigin
    let options: DisplayList.Options
    var contentSeed: DisplayList.Seed

    typealias Value = DisplayList

    static var flags: Flags {
        V.requiresMainThread ? .mainThread : []
    }

    mutating func updateValue() {
        let (view, viewChanged) = $view.changedValue()
        let content = view.content()
        let version = DisplayList.Version(forUpdate: ())
        if viewChanged {
            contentSeed = .init(version)
        }
        var item = DisplayList.Item(
            .content(DisplayList.Content(content, seed: contentSeed)),
            frame: CGRect(
                origin: CGPoint(position - containerPosition),
                size: size
            ),
            identity: identity,
            version: version
        )
        item.canonicalize(options: options)
        value = DisplayList(item)
    }

    var description: String { "LeafDisplayList" }
}
