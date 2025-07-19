//
//  EmptyViewRendererHost.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete

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
        viewGraph.setRootView(EmptyView())
        initializeViewGraph()
        Update.end()
    }

    package func requestUpdate(after delay: Double) {}

    package func updateRootView() {}

    package func updateEnvironment() {}

    package func updateSize() {}

    package func updateSafeArea() {}

    package func updateContainerSize() {}

    package func forEachIdentifiedView(body: (_IdentifiedViewProxy) -> Void) {}
}
