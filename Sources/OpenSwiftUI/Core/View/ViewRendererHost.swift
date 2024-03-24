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
    var isRendering: Bool { get set }
    func requestUpdate(after: Double)
}

extension ViewRendererHost {
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
        Update.begin()
        defer { Update.end() }
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

struct ViewRendererHostProperties: OptionSet {
    let rawValue: UInt16
}
