//
//  StyledTextResponder.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: E86B54AF130CC92E23B03D8EFE1DCF2E (SwiftUICore)

package import Foundation
package import OpenAttributeGraphShims

// MARK: - StyledTextResponder

final package class StyledTextResponder: ViewResponder, AnyGestureResponder {
    package typealias Data = ShapeStyledResponderData<StyledTextContentView>

    @Attribute package var view: StyledTextContentView
    @Attribute package var styles: _ShapeStyle_Pack
    package let inputs: _ViewInputs
    package let viewSubgraph: Subgraph
    package var helper: ContentResponderHelper<Data>
    package var childSubgraph: Subgraph?
    package var childViewSubgraph: Subgraph?
    package lazy var gestureGraph: GestureGraph = GestureGraph(rootResponder: self)
    package lazy var bindingBridge: EventBindingBridge & GestureGraphDelegate = {
        let bridge = inputs.makeEventBindingBridge(
            bindingManager: gestureGraph.eventBindingManager,
            responder: self
        )
        gestureGraph.delegate = bridge
        return bridge
    }()
    package var _gestureContainer: AnyObject?

    package init(
        view: Attribute<StyledTextContentView>,
        styles: Attribute<_ShapeStyle_Pack>,
        inputs: _ViewInputs
    ) {
        self._view = view
        self._styles = styles
        self.inputs = inputs
        viewSubgraph = view.subgraph
        helper = ContentResponderHelper()
        super.init()
    }

    override package var gestureContainer: AnyObject? {
        guard viewSubgraph.isValid,
              let data = helper.data,
              data.view.text.storage?.hasLinkAttributes == true else {
            return nil
        }
        if let container = _gestureContainer {
            return container
        }
        guard viewSubgraph.isValid else {
            return nil
        }
        _gestureContainer = inputs.makeGestureContainer(responder: self)
        return _gestureContainer!
    }

    package var eventSources: [any EventBindingSource] {
        bindingBridge.eventSources
    }

    package var gestureType: any Any.Type {
        AnyGesture<Void>.self
    }

    package var relatedAttribute: AnyAttribute {
        $view.identifier
    }

    package var isValid: Bool {
        _gestureContainer != nil && viewSubgraph.isValid
    }

    package func detachContainer() {
        _gestureContainer = nil
    }

    package func update() {
        let (view, viewChanged) = $view.changedValue()
        let (styles, stylesChanged) = $styles.changedValue()
        helper.update(
            data: (Data(view: view, styles: styles), viewChanged || stylesChanged),
            size: inputs.size.changedValue(),
            position: inputs.position.changedValue(),
            transform: inputs.transform.changedValue(),
            parent: self
        )
    }

    override package func containsGlobalPoints(
        _ points: [CGPoint],
        cacheKey: UInt32?,
        options: ContainsPointsOptions
    ) -> ContainsPointsResult {
        var result = helper.containsGlobalPoints(points, cacheKey: cacheKey, options: options, children: [])
        if viewSubgraph.isValid,
           view.text.storage?.hasLinkAttributes == true,
           !options.contains(.useZDistanceAsPriority) {
            result.priority = ViewResponder.gestureContainmentPriority
        }
        return result
    }

    override package func addContentPath(
        to path: inout Path,
        kind: ContentShapeKinds,
        in space: CoordinateSpace,
        observer: (any ContentPathObserver)?
    ) {
        helper.addContentPath(to: &path, kind: kind, in: space, observer: observer)
    }

    override package func extendPrintTree(string: inout String) {
        let position = helper.globalPosition
        string += "[\(helper.size.width), \(helper.size.height)] @\((position.x, position.y))"
    }

    override package func bindEvent(_ event: any EventType) -> ResponderNode? {
        guard GestureContainerFeature.isEnabled,
              let event = HitTestableEvent(event) else {
            return nil
        }
        return hitTest(globalPoint: event.hitTestLocation, radius: event.hitTestRadius)
    }

    override package func makeGesture(inputs: _GestureInputs) -> _GestureOutputs<Void> {
        makeWrappedGesture(inputs: inputs) { childInputs in
            AnyGesture<Void>._makeGesture(
                gesture: _GraphValue($view.text[keyPath: \.gesture]),
                inputs: childInputs
            )
        }
    }

    override package func resetGesture() {
        childSubgraph = nil
        childViewSubgraph = nil
    }
}

// MARK: - StyledTextResponderFilter

struct StyledTextResponderFilter: StatefulRule {
    let responder: StyledTextResponder

    typealias Value = [ViewResponder]

    mutating func updateValue() {
        responder.update()
        if !hasValue {
            value = [responder]
        }
    }
}

// MARK: - ResolvedStyledText + Gesture

extension ResolvedStyledText {
    fileprivate var gesture: AnyGesture<Void> {
        struct State: GestureStateProtocol {
            var url: URL?
        }
        guard let storage, storage.hasLinkAttributes else {
            return AnyGesture(EmptyGesture())
        }
        return AnyGesture(
            SizeGesture { [text = self, cachedText = self] size in
                OpenURLGesture(base: State.gesture(
                    content: SingleTapGesture<TappableSpatialEvent>()
                ) { state, phase in
                    if let url = state.url {
                        guard text.storage == cachedText.storage else {
                            return .failed
                        }
                        return phase.withValue(url)
                    } else {
                        switch phase {
                        case .possible(nil):
                            return .possible(nil)
                        case .failed:
                            return .failed
                        case let .possible(event?),
                             let .active(event),
                             let .ended(event):
                            guard let url = text.linkURL(at: event.location, in: size) else {
                                return .failed
                            }
                            state.url = url
                            return phase.withValue(url)
                        }
                    }
                }).map { _ in () }
            }
        )
    }
}

// MARK: - OpenURLGesture

private struct OpenURLGesture<Base>: Gesture where Base: Gesture, Base.Value == URL {
    var base: Base
    @Environment(\.openURL) var openURL: OpenURLAction

    var body: some Gesture {
        base.onEnded { url in
            openURL(url)
        }
    }
}

// MARK: - NSAttributedString + Link Attributes

extension NSAttributedString {
    var hasLinkAttributes: Bool {
        var result = false
        enumerateAttribute(.kitLink, in: range) { value, _, stop in
            if URL(urlValue: value) != nil {
                result = true
                stop.pointee = true
            }
        }
        return result
    }
}

// MARK: - URL + extension

extension URL {
    package init?(urlValue: Any?) {
        if let urlValue = urlValue as? URL {
            self = urlValue
        } else if let urlValue = urlValue as? String {
            self.init(string: urlValue)
        } else {
            return nil
        }
    }
}
