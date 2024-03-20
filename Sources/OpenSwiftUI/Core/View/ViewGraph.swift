//
//  ViewGraph.swift
//  OpenSwiftUI
//
//  Audited for RELEASE_2021
//  Status: WIP
//  ID: D63C4EB7F2B205694B6515509E76E98B

internal import OpenGraphShims

final class ViewGraph: GraphHost {
    let rootViewType: Any.Type
    let makeRootView: (OGAttribute, _ViewInputs) -> _ViewOutputs
    weak var delegate: ViewGraphDelegate?
    var centersRootView: Bool
    let rootView: OGAttribute

    var requestedOutputs: Outputs
    var disabledOutputs: Outputs
    var mainUpdates: Int
    var needsFocusUpdate: Bool
    var nextUpdate: NextUpdate
    
    init<Body: View>(rootViewType type: Body.Type, requestedOutputs: Outputs) {
        rootViewType = type
        fatalError("TODO")
//        super.init(data: Data())
    }
    
    override var graphDelegate: GraphDelegate? { delegate }
    
    
    private func updateOutputs() {
        // TODO
    }
}

extension ViewGraph {
    struct NextUpdate {
        var time: Time
        var _interval: Double
        var reasons: Set<UInt32>
    }
}

extension ViewGraph {
    struct Outputs: OptionSet {
        let rawValue: UInt8
    }
}
