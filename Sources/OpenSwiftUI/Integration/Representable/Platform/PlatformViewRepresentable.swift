//
//  PlatformViewRepresentable.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: WIP
//  ID: A513612C07DFA438E70B9FA90719B40D (SwiftUI)

#if os(iOS) || os(visionOS)
import UIKit
typealias PlatformView = UIView
typealias PlatformScrollView = UIScrollView
typealias PlatformViewController = UIViewController
typealias PlatformHostingController = UIHostingController
typealias PlatformViewResponder = UIViewResponder
#elseif os(macOS)
import AppKit
typealias PlatformView = NSView
typealias PlatformScrollView = NSScrollView
typealias PlatformViewController = NSViewController
typealias PlatformHostingController = NSHostingController
typealias PlatformViewResponder = NSViewResponder
#else
import Foundation
typealias PlatformView = NSObject
typealias PlatformScrollView = NSObject
typealias PlatformViewController = NSObject
typealias PlatformHostingController = NSObject
typealias PlatformViewResponder = NSObject
#endif

import COpenSwiftUI
@_spi(ForOpenSwiftUIOnly)
import OpenSwiftUICore
import OpenAttributeGraphShims

// MARK: - PlatformViewRepresentable

protocol PlatformViewRepresentable: View {
    associatedtype PlatformViewProvider

    associatedtype Coordinator

    static var dynamicProperties: DynamicPropertyCache.Fields { get }

    func makeViewProvider(context: Context) -> PlatformViewProvider

    func updateViewProvider(_ provider: PlatformViewProvider, context: Context)

    func resetViewProvider(_ provider: PlatformViewProvider, coordinator: Coordinator, destroy: () -> Void)

    static func dismantleViewProvider(_ provider: PlatformViewProvider, coordinator: Coordinator)

    static func platformView(for provider: PlatformViewProvider) -> PlatformView

    func makeCoordinator() -> Coordinator

    func _identifiedViewTree(in provider: PlatformViewProvider) -> _IdentifiedViewTree

    func sizeThatFits(_ proposal: ProposedViewSize, provider: PlatformViewProvider, context: PlatformViewRepresentableContext<Self>) -> CGSize?

    func overrideSizeThatFits(_ size: inout CGSize, in proposedSize: _ProposedSize, platformView: PlatformViewProvider)

    func overrideLayoutTraits(_ traits: inout _LayoutTraits, for provider: PlatformViewProvider)

    static func modifyBridgedViewInputs(_ inputs: inout _ViewInputs)

    static var isViewController: Bool { get }

    static func shouldEagerlyUpdateSafeArea(_ provider: PlatformViewProvider) -> Bool

    static func layoutOptions(_ provider: PlatformViewProvider) -> LayoutOptions

    typealias Context = PlatformViewRepresentableContext<Self>

    typealias LayoutOptions = _PlatformViewRepresentableLayoutOptions
}

// MARK: - PlatformViewRepresentable + Extension [WIP]

extension PlatformViewRepresentable {
    static var dynamicProperties: DynamicPropertyCache.Fields {
        DynamicPropertyCache.fields(of: Self.self)
    }

    nonisolated static func _makeView(view: _GraphValue<Self>, inputs: _ViewInputs) -> _ViewOutputs {
        #if canImport(Darwin)
        guard !inputs.archivedView.isArchived else {
            var outputs = _ViewOutputs()
            guard inputs.preferences.requiresDisplayList else {
                return outputs
            }
            let identity = DisplayList.Identity()
            inputs.pushIdentity(identity)
            outputs.displayList = Attribute(
                PlatformArchivedDisplayList(
                    identity: identity,
                    view: view.value,
                    position: inputs.animatedPosition(),
                    size: inputs.animatedSize(),
                    containerPosition: inputs.containerPosition
                )
            )
            return outputs
        }
        var inputs = inputs
        let bridge = PreferenceBridge()
        let fields = dynamicProperties
        let buffer = _DynamicPropertyBuffer(
            fields: fields,
            container: view,
            inputs: &inputs.base
        )
        let child = Attribute(
            PlatformViewChild(
                view: view.value,
                environment: inputs.environment,
                transaction: inputs.transaction,
                phase: inputs.viewPhase,
                position: inputs.position,
                size: inputs.size,
                transform: inputs.transform,
                focusedValues: inputs.base[FocusedValuesInputKey.self],
                parentID: inputs.scrapeableParentID,
                bridge: bridge,
                importer: .init(graph: .current), // FIXME
                links: buffer,
                coordinator: nil,
                platformView: nil
            )
        )
        buffer.traceMountedProperties(to: view, fields: fields)
        // TODO
        var outputs = PlatformViewChild<Self>.Value.makeDebuggableView(view: .init(child), inputs: inputs)
        // TODO
        return outputs
        #else
        _openSwiftUIUnimplementedFailure()
        #endif
    }

    var body: Never {
        bodyError()
    }
}

#if canImport(Darwin)

extension PlatformViewRepresentable where PlatformViewProvider: PlatformView {
    static func platformView(for provider: PlatformViewProvider) -> PlatformView {
        provider
    }

    static var isViewController: Bool { false }
}

extension PlatformViewRepresentable where PlatformViewProvider: PlatformViewController {
    static func platformView(for provider: PlatformViewProvider) -> PlatformView {
        provider.view
    }

    static var isViewController: Bool { true }
}

// MARK: - PlatformViewChild

struct PlatformViewChild<Content: PlatformViewRepresentable>: StatefulRule {
    @Attribute var view: Content
    @Attribute var environment: EnvironmentValues
    @Attribute var transaction: Transaction
    @Attribute var phase: _GraphInputs.Phase
    @Attribute var position: ViewOrigin
    @Attribute var size: ViewSize
    @Attribute var transform: ViewTransform
    @OptionalAttribute var focusedValues: FocusedValues?
    let parentID: ScrapeableID
    let bridge: PreferenceBridge
    let importer: EmptyPreferenceImporter
    var links: _DynamicPropertyBuffer
    var coordinator: Content.Coordinator?
    var platformView: PlatformViewHost<Content>?
    var resetSeed: UInt32
    let tracker: PropertyList.Tracker

    init(
        view: Attribute<Content>,
        environment: Attribute<EnvironmentValues>,
        transaction: Attribute<Transaction>,
        phase: Attribute<_GraphInputs.Phase>,
        position: Attribute<ViewOrigin>,
        size: Attribute<ViewSize>,
        transform: Attribute<ViewTransform>,
        focusedValues: OptionalAttribute<FocusedValues>,
        parentID: ScrapeableID,
        bridge: PreferenceBridge,
        importer: EmptyPreferenceImporter,
        links: _DynamicPropertyBuffer,
        coordinator: Content.Coordinator?,
        platformView: PlatformViewHost<Content>?,
        resetSeed: UInt32 = 0
    ) {
        self._view = view
        self._environment = environment
        self._transaction = transaction
        self._phase = phase
        self._position = position
        self._size = size
        self._transform = transform
        self._focusedValues = focusedValues
        self.parentID = parentID
        self.bridge = bridge
        self.importer = importer
        self.links = links
        self.coordinator = coordinator
        self.platformView = platformView
        self.resetSeed = resetSeed
        self.tracker = .init()
    }

    var representedViewProvider: Content.PlatformViewProvider? {
        guard let platformView else {
            return nil
        }
        return platformView.representedViewProvider
    }

    typealias Value = ViewLeafView<Content>

    mutating func updateValue() {
        Signpost.platformUpdate.traceInterval(
            object: nil,
            "PlatformUpdate: (%p) %{public}@ [ %p ]",
            [
                attribute.graph.graphIdentity(),
                "\(Content.self)",
                platformView.map { UInt(bitPattern: Unmanaged.passUnretained($0).toOpaque()) } ?? 0,
            ]
        ) {
            var (view, viewChanged) = $view.changedValue()
            let (phase, phaseChanged) = $phase.changedValue()
            var (environment, environmentChanged) = $environment.changedValue()
            let (focusedValues, focusedValuesChanged) = $focusedValues?.changedValue() ?? (.init(), false)
            if phase.resetSeed != resetSeed {
                links.reset()
                resetPlatformView()
                resetSeed = phase.resetSeed
            }
            let linksChanged = withUnsafeMutablePointer(to: &view) { pointer in
                links.update(container: pointer, phase: phase)
            }
            var changed = linksChanged || !hasValue || viewChanged || phaseChanged || AnyAttribute.currentWasModified
            let transaction = Graph.withoutUpdate {
                if coordinator == nil {
                    coordinator = view.makeCoordinator()
                }
                return self.transaction
            }
            environment.preferenceBridge = bridge
            let context: PlatformViewRepresentableContext<Content>
            if let platformView {
                if environmentChanged, tracker.hasDifferentUsedValues(environment.plist) {
                    tracker.reset()
                    changed = true
                }
                if platformView.isPlatformFocusContainerHost {
                    environment.focusGroupID = .inferred
                }
                let env = EnvironmentValues(environment.plist, tracker: tracker)
                Graph.withoutUpdate {
                    if phaseChanged  || environmentChanged {
                        platformView.updateEnvironment(
                            env.removingTracker(),
                            viewPhase: phase
                        )
                    }
                    if focusedValuesChanged {
                        platformView.focusedValues = focusedValues
                    }
                }
                context = PlatformViewRepresentableContext<Content>(
                    coordinator: coordinator!,
                    preferenceBridge: bridge,
                    transaction: transaction,
                    environmentStorage: .eager(env)
                )
            } else {
                tracker.reset()
                changed = true
                let env = EnvironmentValues(environment.plist, tracker: tracker)
                context = PlatformViewRepresentableContext<Content>(
                    coordinator: coordinator!,
                    preferenceBridge: bridge,
                    transaction: transaction,
                    environmentStorage: .eager(env)
                )
                let host = ViewGraph.viewRendererHost
                platformView = withObservation {
                    Graph.withoutUpdate {
                        context.values.asCurrent {
                            PlatformViewHost(
                                view.makeViewProvider(context: context),
                                host: host,
                                environment: env.removingTracker(),
                                viewPhase: phase,
                                importer: importer
                            )
                        }
                    }
                }
            }
            guard changed else {
                return
            }
            let host = ViewGraph.viewRendererHost
            withObservation {
                Graph.withoutUpdate {
                    guard let provider = representedViewProvider else {
                        return
                    }
                    if let host {
                        Update.ensure {
                            host.performExternalUpdate {
                                context.values.asCurrent {
                                    view.updateViewProvider(provider, context: context)
                                }
                            }
                        }
                    } else {
                        context.values.asCurrent {
                            view.updateViewProvider(provider, context: context)
                        }
                    }
                }
            }
            value = ViewLeafView(
                content: view,
                platformView: platformView!,
                coordinator: coordinator!
            )
        }
    }

    mutating func resetPlatformView() {
        guard let coordinator,
              let representedViewProvider else {
            return
        }
        view.resetViewProvider(representedViewProvider, coordinator: coordinator) {
            Content.dismantleViewProvider(representedViewProvider, coordinator: coordinator)
            reset()
        }
    }
}

extension PlatformViewChild: ObservedAttribute {
    mutating func destroy() {
        links.destroy()
        if let coordinator, let representedViewProvider {
            Update.syncMain {
                Content.dismantleViewProvider(representedViewProvider, coordinator: coordinator)
            }
            reset()
        }
        bridge.invalidate()
    }

    private mutating func reset() {
        coordinator = nil
        platformView = nil
    }
}

extension PlatformViewChild: InvalidatableAttribute {
    static func willInvalidate(attribute: AnyAttribute) {
        let pointer = attribute.info.body
            .assumingMemoryBound(to: PlatformViewChild.self)
        pointer[].bridge.invalidate()
    }
}

extension PlatformViewChild: RemovableAttribute {
    static func willRemove(attribute: AnyAttribute) {
        let pointer = attribute.info.body
            .assumingMemoryBound(to: PlatformViewChild.self)
        pointer[].bridge.removedStateDidChange()
    }

    static func didReinsert(attribute: AnyAttribute) {
        let pointer = attribute.info.body
            .assumingMemoryBound(to: PlatformViewChild.self)
        pointer[].bridge.removedStateDidChange()
    }
}

extension PlatformViewChild: ScrapeableAttribute {
    static func scrapeContent(from ident: AnyAttribute) -> ScrapeableContent.Item? {
        let pointer = ident.info.body
            .assumingMemoryBound(to: PlatformViewChild.self)
        guard let platformView = pointer[].platformView else {
            return nil
        }
        return .init(
            .platformView(platformView),
            ids: .none,
            pointer[].parentID,
            position: pointer[].$position,
            size: pointer[].$size,
            transform: pointer[].$transform,
        )
    }
}

// MARK: - PlatformViewHost + FocusContainer

extension PlatformViewHost {
    private struct UnarySubtreeSequence: Sequence {
        weak var root: PlatformView?

        func makeIterator() -> AnyIterator<PlatformView> {
            var current = root
            return AnyIterator { [weak current] ()-> PlatformView? in
                #if canImport(Darwin)
                guard let node = current else {
                    return nil
                }
                current = node.subviews.first
                return node
                #else
                return nil
                #endif
            }
        }
    }

    var isPlatformFocusContainerHost: Bool {
        UnarySubtreeSequence(root: self).first { $0 is PlatformScrollView } != nil
    }
}

// MARK: - ViewLeafView

struct ViewLeafView<Content>: PrimitiveView, UnaryView where Content: PlatformViewRepresentable {
    let content: Content
    var platformView: PlatformViewHost<Content>
    var coordinator: Content.Coordinator

    init(
        content: Content,
        platformView: PlatformViewHost<Content>,
        coordinator: Content.Coordinator
    ) {
        self.content = content
        self.platformView = platformView
        self.coordinator = coordinator
    }

    var representedViewProvider: Content.PlatformViewProvider {
        platformView.representedViewProvider
    }

    func layoutTraits() -> _LayoutTraits {
        Graph.withoutUpdate {
            var traits = platformView.layoutTraits()
            content.overrideLayoutTraits(&traits, for: representedViewProvider)
            return traits
        }
    }

    func sizeThatFits(
        in proposedSize: _ProposedSize,
        environment: Attribute<EnvironmentValues>,
        context: AnyRuleContext
    ) -> CGSize {
        var size: CGSize = .zero
        Update.syncMain {
            let context = PlatformViewRepresentableContext<Content>(
                coordinator: coordinator,
                preferenceBridge: nil,
                transaction: .init(),
                environmentStorage: .lazy(environment, context)
            )
            let result: CGSize
            if let fittingSize = content.sizeThatFits(
                .init(proposedSize),
                provider: representedViewProvider,
                context: context
            ) {
                result = fittingSize
            } else {
                if enableUnifiedLayout() {
                    result = unifiedLayoutSize(in: proposedSize)
                } else {
                    let traits = layoutTraits()
                    result = proposedSize
                        .fixingUnspecifiedDimensions(at: traits.idealSize)
                        .clamped(to: traits)
                }
            }
            size = result
        }
        return size
    }

    private func unifiedLayoutSize(in proposedSize: _ProposedSize) -> CGSize {
        guard proposedSize.width != nil, proposedSize.height != nil else {
            return proposedSize.fixingUnspecifiedDimensions(at: layoutTraits().idealSize)
        }
        return proposedSize.fixingUnspecifiedDimensions()
    }

    nonisolated static func _makeView(
        view: _GraphValue<Self>,
        inputs: _ViewInputs
    ) -> _ViewOutputs {
        var outputs = _ViewOutputs()
        if inputs.preferences.requiresDisplayList {
            let identity = DisplayList.Identity()
            inputs.pushIdentity(identity)
            outputs.displayList = Attribute(
                PlatformViewDisplayList(
                    identity: identity,
                    view: view.value,
                    position: inputs.animatedPosition(),
                    containerPosition: inputs.containerPosition,
                    size: inputs.animatedSize(),
                    transform: inputs.transform,
                    environment: inputs.environment,
                    safeAreaInsets: inputs.safeAreaInsets,
                    contentSeed: .init()
                )
            )
        }
        if inputs.requestsLayoutComputer {
            outputs.layoutComputer = Attribute(
                InvalidatableLeafLayoutComputer(
                    view: view.value,
                    environment: Attribute(
                        LeafLayoutEnvironment(
                            environment: inputs.environment,
                            tracker: .init()
                        )
                    ),
                    graphHost: .currentHost
                )
            )
        }
        return outputs
    }
}

// MARK: - ViewLeafView + PlatformViewFactory

extension ViewLeafView: PlatformViewFactory {
    func makePlatformView() -> AnyObject? {
        platformView
    }

    func updatePlatformView(_ view: inout AnyObject) {
        view = platformView
    }

    func renderPlatformView(in ctx: GraphicsContext, size: CGSize, renderer: DisplayList.GraphicsRenderer) {
        Update.syncMain {
            renderer.renderPlatformView(
                platformView,
                in: ctx,
                size: size,
                viewType: Content.self
            )
        }
    }
}

// MARK: - PlatformArchivedDisplayList

struct PlatformArchivedDisplayList<Content>: Rule where Content: PlatformViewRepresentable {
    let identity: DisplayList.Identity
    @Attribute var view: Content
    @Attribute var position: ViewOrigin
    @Attribute var size: ViewSize
    @Attribute var containerPosition: CGPoint

    init(
        identity: DisplayList.Identity,
        view: Attribute<Content>,
        position: Attribute<ViewOrigin>,
        size: Attribute<ViewSize>,
        containerPosition: Attribute<CGPoint>
    ) {
        self.identity = identity
        self._view = view
        self._position = position
        self._size = size
        self._containerPosition = containerPosition
    }

    var value: DisplayList {
        let version = DisplayList.Version(forUpdate: ())
        let contentSeed = DisplayList.Seed(version)
        let content = DisplayList.Content(
            .platformView(Factory()),
            seed: contentSeed
        )
        let frame = CGRect(
            origin: CGPoint(position - containerPosition),
            size: size.value
        )
        var item = DisplayList.Item(
            .content(content),
            frame: frame,
            identity: identity,
            version: version
        )
        item.canonicalize()
        return DisplayList(item)
    }

    struct Factory: PlatformViewFactory {
        var viewType: any Any.Type {
            Content.self
        }
        
        func makePlatformView() -> AnyObject? {
            preconditionFailure("")
        }

        func updatePlatformView(_ view: inout AnyObject) {
            preconditionFailure("")
        }
    }
}

// MARK: - InvalidatableLeafLayoutComputer

private struct InvalidatableLeafLayoutComputer<Content>: StatefulRule, CustomStringConvertible where Content: PlatformViewRepresentable {
    @Attribute var view: ViewLeafView<Content>
    @Attribute var environment: EnvironmentValues
    weak var graphHost: GraphHost?

    typealias Value = LayoutComputer

    mutating func updateValue() {
        if view.platformView.layoutInvalidator == nil {
            view.platformView.layoutInvalidator = PlatformViewLayoutInvalidator(
                graphHost: graphHost,
                layoutComputer: WeakAttribute(attribute)
            )
        }
        let engine = PlatformViewLayoutEngine(
            view: view,
            environment: $environment,
            context: AnyRuleContext(context)
        )
        update(to: engine)
    }

    var description: String {
        "InvalidatableLeafLayoutComputer"
    }
}

// MARK: - LeafLayoutEnvironment

private struct LeafLayoutEnvironment: StatefulRule {
    @Attribute var environment: EnvironmentValues
    let tracker: PropertyList.Tracker

    typealias Value = EnvironmentValues

    func updateValue() {
        let (env, envChanged) = $environment.changedValue()
        let shouldReset: Bool
        if !hasValue {
            shouldReset = true
        } else if envChanged, tracker.hasDifferentUsedValues(env.plist) {
            shouldReset = true
        } else {
            shouldReset = false
        }
        if shouldReset {
            tracker.reset()
            value = EnvironmentValues(
                environment.plist,
                tracker: tracker
            )
        }
    }
}

// MARK: - PlatformViewDisplayList

private struct PlatformViewDisplayList<Content>: StatefulRule where Content: PlatformViewRepresentable {
    let identity: DisplayList.Identity
    @Attribute var view: ViewLeafView<Content>
    @Attribute var position: ViewOrigin
    @Attribute var containerPosition: ViewOrigin
    @Attribute var size: ViewSize
    @Attribute var transform: ViewTransform
    @Attribute var environment: EnvironmentValues
    @OptionalAttribute var safeAreaInsets: SafeAreaInsets?
    var contentSeed: DisplayList.Seed

    init(
        identity: DisplayList.Identity,
        view: Attribute<ViewLeafView<Content>>,
        position: Attribute<ViewOrigin>,
        containerPosition: Attribute<ViewOrigin>,
        size: Attribute<ViewSize>,
        transform: Attribute<ViewTransform>,
        environment: Attribute<EnvironmentValues>,
        safeAreaInsets: OptionalAttribute<SafeAreaInsets>,
        contentSeed: DisplayList.Seed
    ) {
        self.identity = identity
        self._view = view
        self._position = position
        self._containerPosition = containerPosition
        self._size = size
        self._transform = transform
        self._environment = environment
        self._safeAreaInsets = safeAreaInsets
        self.contentSeed = contentSeed
    }

    typealias Value = DisplayList

    mutating func updateValue() {
        let version = DisplayList.Version(forUpdate: ())
        let (view, viewChanged) = $view.changedValue()
        if viewChanged {
            contentSeed = .init(version)
        }
        var frame = CGRect(
            origin: CGPoint(position - containerPosition),
            size: size.value
        )
        let layoutOption = Content.layoutOptions(view.representedViewProvider)
        if layoutOption.contains(.propagatesSafeArea) {
            let placementContext = _PositionAwarePlacementContext(
                context: AnyRuleContext(context),
                size: _size,
                environment: _environment,
                transform: _transform,
                position: _position,
                safeAreaInsets: _safeAreaInsets
            )
            let edgeInsets = placementContext.safeAreaInsets(matching: .all)
            let isRTL = environment.layoutDirection == .rightToLeft
            let platformEdgeInsets = PlatformEdgeInsets(
                top: edgeInsets.top,
                left: isRTL ? edgeInsets.trailing : edgeInsets.leading,
                bottom: edgeInsets.bottom,
                right: isRTL ? edgeInsets.leading : edgeInsets.trailing
            )
            frame.origin -= CGSize(width: platformEdgeInsets.left, height: platformEdgeInsets.top)
            frame.size.width += edgeInsets.horizontal
            frame.size.height += edgeInsets.vertical
            view.platformView.updateSafeAreaInsets(platformEdgeInsets)
        }
        var item = DisplayList.Item(
            .content(.init(
                .platformView(view),
                seed: contentSeed
            )),
            frame: frame,
            identity: identity,
            version: version
        )
        item.canonicalize()
        value = DisplayList(item)
    }
}

// MARK: - PlatformViewLayoutEngine

private struct PlatformViewLayoutEngine<Content>: LayoutEngine where Content: PlatformViewRepresentable {
    var cache: ViewSizeCache
    var view: ViewLeafView<Content>
    var environment: Attribute<EnvironmentValues>
    var context: AnyRuleContext

    init(
        cache: ViewSizeCache = .init(),
        view: ViewLeafView<Content>,
        environment: Attribute<EnvironmentValues>,
        context: AnyRuleContext
    ) {
        self.cache = cache
        self.view = view
        self.environment = environment
        self.context = context
    }

    mutating func sizeThatFits(_ proposedSize: _ProposedSize) -> CGSize {
        cache.get(proposedSize) {
            view.sizeThatFits(
                in: proposedSize,
                environment: environment,
                context: context
            )
        }
    }

    func explicitAlignment(_ k: AlignmentKey, at viewSize: ViewSize) -> CGFloat? {
        if k == VerticalAlignment.firstTextBaseline.key {
            let baseline = view.platformView._baselineOffsets(at: viewSize.value)
            let firstTextBaseline = baseline.firstTextBaseline
            return firstTextBaseline.isNaN ? .zero : firstTextBaseline
        } else if k == VerticalAlignment.lastTextBaseline.key {
            let baseline = view.platformView._baselineOffsets(at: viewSize.value)
            let lastTextBaseline = baseline.lastTextBaseline
            let height = viewSize.height
            return lastTextBaseline.isNaN ? height : height - lastTextBaseline
        } else {
            return nil
        }
    }
}

#endif
