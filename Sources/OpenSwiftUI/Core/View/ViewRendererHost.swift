//
//  ViewRendererHost.swift
//  OpenSwiftUI
//
//  Audited for RELEASE_2021
//  Status: WIP

internal import OpenGraphShims

protocol ViewRendererHost: ViewGraphDelegate {
    var viewGraph: ViewGraph { get }
    var currentTimestamp: Time { get set }
    var propertiesNeedingUpdate: ViewRendererHostProperties { get set }
    func addImplicitPropertiesNeedingUpdate(to properties: inout ViewRendererHostProperties)
    var isRendering: Bool { get set }
    func updateRootView()
    func requestUpdate(after: Double)
}

// MARK: - ViewRendererHost's default implementation for ViewGraphDelegate

extension ViewRendererHost {
    func updateViewGraph<Value>(body: (ViewGraph) -> Value) -> Value {
        Update.perform {
            OGGraph.withoutUpdate {
                updateGraph()
                return body(viewGraph)
            }
        }
    }
}

extension ViewRendererHost {
    func initializeViewGraph() {
        viewGraph.delegate = self
        // TODO: Signpost related
    }
    
    func invalidateProperties(_ properties: ViewRendererHostProperties, mayDeferUpdate: Bool) {
        Update.lock.withLock {
            guard !propertiesNeedingUpdate.contains(properties) else {
                return
            }
            propertiesNeedingUpdate.insert(properties)
            viewGraph.setNeedsUpdate(mayDeferUpdate: mayDeferUpdate)
            requestUpdate(after: .zero)
        }
    }
    
    func startProfiling() {
        OGGraph.startProfiling(viewGraph.graph)
    }
    
    func stopProfiling() {
        OGGraph.stopProfiling(viewGraph.graph)
    }
    
    func render(interval: Double, updateDisplayList: Bool = true) {
        Update.perform {
            guard !isRendering else {
                return
            }
            let update = { [self] in
                currentTimestamp.advancing(by: interval)
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
    
    static func makeRootView<V: View>(_ view: V) -> some View {
        view/*.modifier(HitTestBindingModifier())*/
    }
    
    func updateGraph() {
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
    
    func invalidate() {
        viewGraph.delegate = nil
        // TODO: Signpost.viewHost
    }
}

struct ViewRendererHostProperties: OptionSet {
    let rawValue: UInt16
    
    static var rootView: ViewRendererHostProperties { ViewRendererHostProperties(rawValue: 1 << 0) }
}
