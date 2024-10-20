//
//  ViewRendererHost.swift
//  OpenSwiftUI
//
//  Audited for RELEASE_2021
//  Status: WIP

internal import OpenGraphShims

// MARK: - ViewRendererHostProperties

package struct ViewRendererHostProperties: OptionSet {
    package let rawValue: UInt16
    package init(rawValue: UInt16) {
        self.rawValue = rawValue
    }
    package static let rootView: ViewRendererHostProperties = .init(rawValue: 1 << 0)
    package static let environment: ViewRendererHostProperties = .init(rawValue: 1 << 1)
    package static let focusedValues: ViewRendererHostProperties = .init(rawValue: 1 << 2)
    package static let transform: ViewRendererHostProperties = .init(rawValue: 1 << 3)
    package static let size: ViewRendererHostProperties = .init(rawValue: 1 << 4)
    package static let safeArea: ViewRendererHostProperties = .init(rawValue: 1 << 5)
    package static let scrollableContainerSize: ViewRendererHostProperties = .init(rawValue: 1 << 6)
    package static let focusStore: ViewRendererHostProperties = .init(rawValue: 1 << 7)
    package static let accessibilityFocusStore: ViewRendererHostProperties = .init(rawValue: 1 << 8)
    package static let focusedItem: ViewRendererHostProperties = .init(rawValue: 1 << 9)
    package static let accessibilityFocus: ViewRendererHostProperties = .init(rawValue: 1 << 10)
    package static let all: ViewRendererHostProperties  = [.rootView, .environment, .focusedValues, .transform, .size, .safeArea, .scrollableContainerSize, .focusStore, .accessibilityFocusStore, .focusedItem, .accessibilityFocus]
}

// MARK: - ViewRenderingPhase

package enum ViewRenderingPhase {
    case none
    case rendering
    case renderingAsync
}

@available(*, unavailable)
extension ViewRenderingPhase: Sendable {}

package protocol ViewRendererHost: ViewGraphDelegate {
    var viewGraph: ViewGraph { get }
    var currentTimestamp: Time { get set }
    var propertiesNeedingUpdate: ViewRendererHostProperties { get set }
    var renderingPhase: ViewRenderingPhase { get set }
    var externalUpdateCount: Int { get set }
    func updateRootView()
    func updateEnvironment()
    func updateFocusedItem()
    func updateFocusedValues()
    func updateTransform()
    func updateSize()
    func updateSafeArea()
    func updateScrollableContainerSize()
    func updateFocusStore()
    func updateAccessibilityFocus()
    func updateAccessibilityFocusStore()
    func updateAccessibilityEnvironment()
    func requestUpdate(after delay: Double)
    func renderDisplayList(_ list: DisplayList, asynchronously: Bool, time: Time, nextTime: Time, targetTimestamp: Time?, version: DisplayList.Version, maxVersion: DisplayList.Version) -> Time
    func didRender()
}

extension ViewRendererHost {
    package var isRendering: Bool {
        fatalError("TODO")
    }
}

// TODO: FIXME

extension ViewRendererHost {
    package func updateViewGraph<Value>(body: (ViewGraph) -> Value) -> Value {
        Update.dispatchImmediately {
            OGGraph.withoutUpdate {
                updateGraph()
                return body(viewGraph)
            }
        }
    }
}

extension ViewRendererHost {
    package func initializeViewGraph() {
        viewGraph.delegate = self
        // TODO: Signpost related
    }
    
    package func invalidateProperties(_ properties: ViewRendererHostProperties, mayDeferUpdate: Bool) {
        Update.locked {
            guard !propertiesNeedingUpdate.contains(properties) else {
                return
            }
            propertiesNeedingUpdate.insert(properties)
            viewGraph.setNeedsUpdate(mayDeferUpdate: mayDeferUpdate)
            requestUpdate(after: .zero)
        }
    }
    
    package func startProfiling() {
        OGGraph.startProfiling(viewGraph.graph)
    }
    
    package func stopProfiling() {
        OGGraph.stopProfiling(viewGraph.graph)
    }
    
    package func render(interval: Double, updateDisplayList: Bool = true) {
        Update.dispatchImmediately {
            guard !isRendering else {
                return
            }
            let update = { [self] in
                currentTimestamp += interval
                let time = currentTimestamp
                viewGraph.flushTransactions()
                // Signpost.renderUpdate
                // TODO
                viewGraph.updateOutputs(at: time)
            }
            if Signpost.render.isEnabled {
                // TODO: Signpost related
                update()
            } else {
                update()
            }
        }
    }
    
    package static func makeRootView<V: View>(_ view: V) -> some View {
        view/*.modifier(HitTestBindingModifier())*/
    }
    
    package func updateGraph() {
        var properties = propertiesNeedingUpdate
        addImplicitPropertiesNeedingUpdate(to: &properties)
        guard !properties.isEmpty else { return }
        Update.syncMain {
            func update(_ property: ViewRendererHostProperties, body: () -> Void) {
                if properties.contains(property) {
                    propertiesNeedingUpdate.remove(property)
                }
                body()
            }
            update(.rootView) { updateRootView() }
            // TODO:
        }
    }
    
    package func invalidate() {
        viewGraph.delegate = nil
        // TODO: Signpost.viewHost
    }
}

// MARK: - EmptyViewRendererHost

final package class EmptyViewRendererHost: ViewRendererHost {
    package let viewGraph: ViewGraph
    package var propertiesNeedingUpdate: ViewRendererHostProperties = []
    package var renderingPhase: ViewRenderingPhase = .none
    package var externalUpdateCount: Int = .zero
    package var currentTimestamp: Time = .zero
    package init(environment: EnvironmentValues = EnvironmentValues()) {
        Update.begin()
        viewGraph = ViewGraph(rootViewType: EmptyView.self, requestedOutputs: [])
        viewGraph.setEnvironment(environment)
        initializeViewGraph()
        Update.end()
    }
    package func requestUpdate(after delay: Double) {}
    package func updateRootView() {}
    package func updateEnvironment() {}
    package func updateSize() {}
    package func updateSafeArea() {}
    package func updateScrollableContainerSize() {}
    package func renderDisplayList(_ list: DisplayList, asynchronously: Bool, time: Time, nextTime: Time, targetTimestamp: Time?, version: DisplayList.Version, maxVersion: DisplayList.Version) -> Time {
        .infinity
    }
    package func forEachIdentifiedView(body: (_IdentifiedViewProxy) -> Void) {}
}
