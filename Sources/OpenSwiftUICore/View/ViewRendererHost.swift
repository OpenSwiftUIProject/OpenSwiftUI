//
//  ViewRendererHost.swift
//  OpenSwiftUI
//
//  Audited for RELEASE_2021
//  Status: WIP

internal import OpenGraphShims

package protocol ViewRendererHost: ViewGraphDelegate {
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

package struct ViewRendererHostProperties: OptionSet {
    package let rawValue: UInt16
    
    package init(rawValue: UInt16) {
        self.rawValue = rawValue
    }
    
    package static var rootView: ViewRendererHostProperties { ViewRendererHostProperties(rawValue: 1 << 0) }
}
