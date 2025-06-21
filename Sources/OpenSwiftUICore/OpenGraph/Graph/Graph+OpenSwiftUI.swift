import OpenGraphShims

extension Graph {
    static func startTracing(options: Graph.TraceFlags?) {
        Graph.startTracing(nil, options: options ?? ProcessEnvironment.tracingOptions)
    }

    static func stopTracing() {
        Graph.stopTracing(nil)
    }
}
