//
//  PlatformViewRepresentable.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: WIP
//  ID: A513612C07DFA438E70B9FA90719B40D (SwiftUI)

#if canImport(AppKit)
import AppKit
typealias PlatformView = NSView
typealias PlatformViewController = NSViewController
typealias PlatformHostingController = NSHostingController
typealias PlatformViewResponder = NSViewResponder
#elseif canImport(UIKit)
import UIKit
typealias PlatformView = UIView
typealias PlatformViewController = UIViewController
typealias PlatformHostingController = UIHostingController
typealias PlatformViewResponder = UIViewResponder
#else
import Foundation
typealias PlatformView = NSObject
typealias PlatformViewController = NSObject
typealias PlatformHostingController = NSObject
typealias PlatformViewResponder = NSObject
#endif
@_spi(ForOpenSwiftUIOnly)
import OpenSwiftUICore
import OpenGraphShims

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
        // TODO
        _openSwiftUIUnimplementedFailure()
    }

    var body: Never {
        bodyError()
    }
}

#if canImport(UIKit) || canImport(AppKit)

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

#endif

// MARK: - PlatformViewChild

//struct PlatformViewChild<Representable: PlatformViewRepresentable> {
//    @Attribute var view: Representable
//    @Attribute var environment: EnvironmentValues
//    @Attribute var transaction: Transaction
//    @Attribute var phase: _GraphInputs.Phase
//    @Attribute var position: CGPoint
//    @Attribute var size: ViewSize
//    @Attribute var transform: ViewTransform
//    @OptionalAttribute var focusedValues: FocusedValues?
//    let parentID: ScrapeableID
//    let bridge: PreferenceBridge
//    let importer: EmptyPreferenceImporter
//    var links: _DynamicPropertyBuffer
//    var coordinator: Representable.Coordinator?
//    var platformView: PlatformViewHost<Representable>?
//    var resetSeed: UInt32
//    let tracker: PropertyList.Tracker
//
//    private func reset() {
//        //
//    }
//}

// MARK: - ViewLeafView [WIP] Blocked by PlatformViewDisplayList

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
            // WIP
            // PlatformViewDisplayList
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
//
//struct PlatformArchivedDisplayList<A> where A: PlatformViewRepresentable {
//    let identity: _DisplayList_Identity
//    var _view: Attribute<A>
//    var _position: Attribute<CGPoint>
//    var _size: Attribute<ViewSize>
//    var _containerPosition: Attribute<CGPoint>
//}
//
//struct PlatformViewRepresentableContext<A> where A: PlatformViewRepresentable {
//    var values: RepresentableContextValues
//    let coordinator: A.Coordinator
//}
//

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

// MARK: - PlatformViewDisplayList [WIP]

struct PlatformViewDisplayList<A> where A: PlatformViewRepresentable {
    let identity: _DisplayList_Identity
    var _view: Attribute<ViewLeafView<A>>
    var _position: Attribute<CGPoint>
    var _containerPosition: Attribute<CGPoint>
    var _size: Attribute<ViewSize>
    var _transform: Attribute<ViewTransform>
    var _environment: Attribute<EnvironmentValues>
    var _safeAreaInsets: OptionalAttribute<SafeAreaInsets>
    var contentSeed: DisplayList.Seed
}

// MARK: - PlatformViewLayoutEngine [WIP] Blocked by PlatformViewHost

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
            // TODO: PlatformViewHost
            // viewSize.value
            // view._baselineOffsetAtSize()
            _openSwiftUIUnimplementedWarning()
            return nil
        } else if k == VerticalAlignment.lastTextBaseline.key {
            // viewSize.value
            // view._baselineOffsetAtSize()
            // viewSize.height
            _openSwiftUIUnimplementedWarning()
            return nil
        } else {
            return nil
        }
    }
}
