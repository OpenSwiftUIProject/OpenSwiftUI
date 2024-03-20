protocol ViewRendererHost {
    // TODO
    var viewGraph: ViewGraph { get set }
    var isRendering: Bool { get set }
}

extension ViewRendererHost {
    func invalidateProperties(_ properties: ViewRendererHostProperties, mayDeferUpdate: Bool) {
        fatalError("TODO")
    }
    
    func startProfiling() {
        fatalError("TODO")
    }
    
    func stopProfiling() {
        fatalError("TODO")
    }
    
    func render(interval: Double, updateDisplayList: Bool = true) {
        Update.begin()
        defer { Update.end() }
        guard !isRendering else {
            return
        }
        // TODO
        viewGraph.flushTransactions()
        // updateOutputs
    }
}


struct ViewRendererHostProperties: OptionSet {
    let rawValue: UInt16
}
