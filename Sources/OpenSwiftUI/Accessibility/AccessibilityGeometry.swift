//
//  AccessibilityGeometry.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: EE68159C4F54001FA5A3813EBA5DD945 (SwiftUI)

import Foundation
import OpenAttributeGraphShims
@_spi(ForOpenSwiftUIOnly)
@_spi(Private)
import OpenSwiftUICore
import struct OpenSwiftUICore.UniqueID

// MARK: - AccessibilityGeometryStorage

class AccessibilityGeometryStorage: CustomStringConvertible {
    var needsUpdatePath = false
    var needsUpdateFrame = false
    private var transform: ViewTransform?
    private var size: CGSize?
    private var cachedFrame: CGRect?
    private var viewResponders: [WeakBox<ViewResponder>] = []
    private var observer: PathObserver?
    private var cachedPath: Path?
    private weak var accessibilityNode: AccessibilityNode?

    init(for node: AccessibilityNode) {
        accessibilityNode = node
    }

    var frame: CGRect? {
        if needsUpdateFrame {
            updateFrame()
        }
        return cachedFrame
    }

    var path: Path? {
        if needsUpdatePath {
            updatePath()
        }
        return cachedPath
    }

    func updateSize(_ size: CGSize) {
        needsUpdateFrame = true
        self.size = size
    }

    func updateTransform(_ transform: ViewTransform) {
        needsUpdateFrame = true
        self.transform = transform
    }

    func updatePath(_ path: Path) {
        needsUpdatePath = false
        if !path.isEmpty, !path.boundingRect.standardized.isEmpty {
            cachedPath = path
        }
    }

    func updateViewResponders(_ responders: [ViewResponder]) {
        needsUpdatePath = true
        observer = nil
        viewResponders = responders.map { WeakBox($0) }
    }

    func viewResponder<Responder>(ofType type: Responder.Type) -> Responder? where Responder: ViewResponder {
        guard let responder = viewResponders.first(where: { $0.base is Responder }) else {
            return nil
        }
        return (responder.base as! Responder)
    }

    var description: String {
        """
        <AccessibilityGeometryStorage: \(address(of: self))>
            ▿ transform: \(String(describing: transform))
            ▿ size: \(String(describing: size))
            ▿ cachedFrame: \(String(describing: cachedFrame))
            ▿ needsUpdateFrame: \(needsUpdateFrame)
            ▿ cachedPath: \(String(describing: cachedPath))
            ▿ needsUpdatePath: \(needsUpdatePath)
            ▿ viewResponders: \(viewResponders.compactMap(\.base))
            ▿ observer: \(String(describing: observer))
        """
    }

    private func updateFrame() {
        needsUpdateFrame = false
        guard let size, let transform else { return }
        var frame = CGRect(origin: .zero, size: size)
        frame.convert(to: .global, transform: transform)
        cachedFrame = frame
    }

    private func updatePath() {
        needsUpdatePath = false
        var path = Path()
        for responder in viewResponders.compactMap(\.base) {
            if observer == nil {
                observer = PathObserver()
                observer?.delegate = self
            }
            var contentPath = Path()
            responder.addContentPath(to: &contentPath, kind: .accessibility, in: .global, observer: observer!)
            if contentPath.isEmpty {
                responder.addContentPath(to: &contentPath, kind: .interaction, in: .global, observer: observer!)
            }
            guard !contentPath.isEmpty, !contentPath.boundingRect.standardized.isEmpty else {
                continue
            }
            if contentPath.boundingRect.contains(path.boundingRect) {
                path = contentPath
            } else if !path.boundingRect.contains(contentPath.boundingRect) {
                path.formTrivialUnion(contentPath)
            }
        }
        guard !path.isEmpty else { return }
        var previousElement: Path.Element?
        var subpathCount = 0
        path.forEach { element in
            switch (element, previousElement) {
            case (.move, .move?):
                break
            case (.move, _):
                subpathCount += 1
            default:
                break
            }
            previousElement = element
        }
        if subpathCount != 1 {
            path = Path(roundedRect: path.boundingRect.standardized, cornerRadius: 5, style: .continuous)
        }
        cachedPath = path
    }

    private class PathObserver: TrivialContentPathObserver {
        weak var delegate: AccessibilityGeometryStorage?

        func contentPathDidChange(for parent: ViewResponder) {
            guard let delegate else { return }
            delegate.needsUpdatePath = true
            delegate.cachedPath = nil
        }
    }
}

// MARK: - ViewModifier + Accessibility Geometry

extension ViewModifier {
    nonisolated static func makeAccessibilityGeometryTransform(
        for nodeList: Attribute<AccessibilityNodeList>?,
        kind: Attribute<ContentShapeKinds>?,
        inputs: _ViewInputs,
        outputs: _ViewOutputs
    ) -> Attribute<AccessibilityNodeList> {
        var nodes = nodeList ?? outputs.accessibilityNodes ?? Attribute(value: AccessibilityNodesKey.defaultValue)
        guard inputs.needsGeometry else { return nodes }
        if inputs.needsAccessibilityViewResponders {
            nodes = Attribute(ViewResponderTransform(
                nodeList: nodes,
                accessibilityEnabled: inputs.accessibilityEnabled,
                viewResponders: .init(outputs.preferences.viewResponders),
                kind: .init(kind),
                token: nodeList.map { AccessibilityAttachmentToken($0) }
            ))
            nodes.flags = .removable
        }
        if inputs.needsAccessibilityGeometry {
            nodes = Attribute(GeometryTransform(
                nodeList: nodes,
                accessibilityEnabled: inputs.accessibilityEnabled,
                size: inputs.size,
                position: inputs.position,
                transform: inputs.transform,
                kind: .init(kind),
                token: nodeList.map { AccessibilityAttachmentToken($0) }
            ))
            nodes.flags = .removable
        }
        return nodes
    }
}

// MARK: - View + Accessibility Geometry

extension View {
    func accessibilityIgnoreViewResponders() -> some View {
        modifier(IgnoreViewRespondersModifier())
    }

    func accessibilityCaptureViewResponders() -> some View {
        modifier(CaptureViewRespondersModifier())
    }
}

// MARK: - IgnoreViewRespondersModifier

private struct IgnoreViewRespondersModifier: PrimitiveViewModifier, ViewInputsModifier {
    nonisolated static func _makeViewInputs(
        modifier _: _GraphValue<Self>,
        inputs: inout _ViewInputs
    ) {
        inputs.needsAccessibilityViewResponders = false
    }
}

// MARK: - CaptureViewRespondersModifier

private struct CaptureViewRespondersModifier: PrimitiveViewModifier, ViewInputsModifier {
    nonisolated static func _makeViewInputs(
        modifier _: _GraphValue<Self>,
        inputs: inout _ViewInputs
    ) {
        inputs.needsAccessibilityViewResponders = true
    }
}

// MARK: - ViewResponderTransform

private struct ViewResponderTransform: StatefulRule, RemovableAttribute, CustomStringConvertible {
    @Attribute var nodeList: AccessibilityNodeList
    @Attribute var accessibilityEnabled: Bool
    @OptionalAttribute var viewResponders: [ViewResponder]?
    @OptionalAttribute var kind: ContentShapeKinds?
    let token: AccessibilityAttachmentToken?
    var idHash: Int = 0

    typealias Value = AccessibilityNodeList

    mutating func updateValue() {
        let (nodeList, nodesChanged) = $nodeList.changedValue()
        guard accessibilityEnabled,
              kind == nil || kind!.contains(.accessibility) || kind!.contains(.interaction),
              nodeList.nodes.count == 1 || nodeList.nodes.filter({ !$0.visibility.resolvesToHidden }).count == 1 else {
            value = nodeList
            return
        }
        var idsChanged = false
        if nodesChanged {
            var hasher = Hasher()
            for node in nodeList.nodes {
                hasher.combine(node.id)
            }
            let hash = hasher.finalize()
            idsChanged = hash != idHash
            idHash = hash
        }
        let (responders, respondersChanged) = $viewResponders?.changedValue() ?? ([], false)
        guard idsChanged || respondersChanged else {
            value = nodeList
            return
        }
        let token = token ?? AccessibilityAttachmentToken(attribute)
        if nodeList.nodes.count == 1 {
            let node = nodeList.nodes[0]
            if !node.hasAttachment(token: token) {
                node.addAttachment(.properties(.init()), isInPlatformItemList: false, token: token)
            }
            node.updateViewResponders(responders, token: token)
        } else {
            for node in nodeList.nodes where !node.visibility.resolvesToHidden {
                if !node.hasAttachment(token: token) {
                    node.addAttachment(.properties(.init()), isInPlatformItemList: false, token: token)
                }
                node.updateViewResponders(responders, token: token)
            }
        }
        value = nodeList
    }

    var description: String {
        "AccessibilityViewResponderTransform"
    }

    static func willRemove(attribute: AnyAttribute) {
        _openSwiftUIEmptyStub()
    }

    static func didReinsert(attribute: AnyAttribute) {
        _openSwiftUIEmptyStub()
    }
}

// MARK: - GeometryTransform

private struct GeometryTransform: StatefulRule, RemovableAttribute, CustomStringConvertible {
    @Attribute var nodeList: AccessibilityNodeList
    @Attribute var accessibilityEnabled: Bool
    @Attribute var size: ViewSize
    @Attribute var position: CGPoint
    @Attribute var transform: ViewTransform
    @OptionalAttribute var kind: ContentShapeKinds?
    let token: AccessibilityAttachmentToken?
    var id: UniqueID = .init()

    typealias Value = AccessibilityNodeList

    mutating func updateValue() {
        let (nodeList, nodesChanged) = $nodeList.changedValue()
        guard accessibilityEnabled,
              kind == nil || kind!.contains(.accessibility) || kind!.contains(.interaction),
              nodeList.nodes.count == 1 else {
            value = nodeList
            return
        }
        let node = nodeList.nodes[0]
        let idChanged = nodesChanged && node.id != id
        let (size, sizeChanged) = $size.changedValue()
        let (position, positionChanged) = $position.changedValue()
        let (transform, transformChanged) = $transform.changedValue()
        guard idChanged || sizeChanged || positionChanged || transformChanged else {
            value = nodeList
            return
        }
        let token = token ?? AccessibilityAttachmentToken(attribute)
        var positionedTransform = transform
        positionedTransform.appendPosition(position)
        if !node.hasAttachment(token: token) {
            node.addAttachment(.properties(.init()), isInPlatformItemList: false, token: token)
        }
        if sizeChanged {
            node.updateSize(size.value, token: token)
        }
        if positionChanged || transformChanged {
            node.updateTransform(positionedTransform, token: token)
        }
        id = node.id
        value = nodeList
    }

    var description: String {
        "AccessibilityGeometryTransform"
    }

    static func willRemove(attribute: AnyAttribute) {
        _openSwiftUIEmptyStub()
    }

    static func didReinsert(attribute: AnyAttribute) {
        _openSwiftUIEmptyStub()
    }
}

// MARK: - AccessibilityFrameModifier

struct AccessibilityFrameModifier: PrimitiveViewModifier, MultiViewModifier {
    nonisolated static func _makeView(
        modifier: _GraphValue<Self>,
        inputs: _ViewInputs,
        body: @escaping (_Graph, _ViewInputs) -> _ViewOutputs
    ) -> _ViewOutputs {
        var outputs = body(_Graph(), inputs)
        if inputs.preferences.requiresAccessibilityNodes, let nodes = outputs.accessibilityNodes {
            let transform = Attribute(ViewResponderTransform(
                nodeList: nodes,
                accessibilityEnabled: inputs.accessibilityEnabled,
                viewResponders: .init(outputs.preferences.viewResponders),
                kind: .init(),
                token: AccessibilityAttachmentToken(nodes)
            ))
            transform.flags = .removable
            outputs.accessibilityNodes = transform
        }
        return outputs
    }
}

// MARK: - AccessibilityProgressViewModifier

struct AccessibilityProgressViewModifier {
    var fractionCompleted: Double?

    func body<Content>(content: Content) -> some View where Content: View {
        content
            .accessibilityIgnoreViewResponders()
            .accessibilityCombinedElement(options: [], ignoredTraits: [.isImage, .isStaticText])
            .update(AccessibilityProperties.TraitsKey.self, combining: .init(adding: .updatesFrequently))
            .update(
                AccessibilityProperties.ValueKey.self,
                combining: AccessibilityValueStorage(
                    AccessibilityProgressValue(percent: fractionCompleted),
                    description: nil
                )
            )
    }
}
