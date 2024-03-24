//
//  ViewGraph.swift
//  OpenSwiftUI
//
//  Audited for RELEASE_2021
//  Status: WIP
//  ID: D63C4EB7F2B205694B6515509E76E98B

internal import OpenGraphShims
import Foundation

final class ViewGraph: GraphHost {
    let rootViewType: Any.Type
    let makeRootView: (OGAttribute, _ViewInputs) -> _ViewOutputs
    weak var delegate: ViewGraphDelegate?
    var centersRootView: Bool
    let rootView: OGAttribute
    @Attribute var rootTransform: ViewTransform
    @Attribute var zeroPoint: ViewOrigin
    // TODO
    @Attribute var proposedSize: ViewSize
    // TODO
    @Attribute var rootGeometry: ViewGeometry
    @Attribute var position: ViewOrigin
    @Attribute var dimensions: ViewSize
    @Attribute var updateSeed: UInt32
    // TODO
    var cachedSizeThatFits: CGSize
    var sizeThatFitsObserver: SizeThatFitsObserver? {
        didSet {
            guard let _ = sizeThatFitsObserver else {
                return
            }
            guard requestedOutputs.contains(.layout) else {
                fatalError("Cannot use sizeThatFits without layout output")
            }
        }
    }
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
    
    @inline(__always)
    func updateOutputs(at time: Time) {
        beginNextUpdate(at: time)
        updateOutputs()
    }
    
    private func beginNextUpdate(at time: Time) {
        setTime(time)
        updateSeed &+= 1
        mainUpdates = graph.mainUpdates
    }
    
    private func updateOutputs() {
        instantiateIfNeeded()
        
        let oldCachedSizeThatFits = cachedSizeThatFits
        
        var preferencesChanged = false
        var observedSizeThatFitsChanged = false
        var updatedOutputs: Outputs = []
        
        var counter1 = 0
        repeat {
            counter1 &+= 1
            inTransaction = true
            var counter2 = 0
            repeat {
                let conts = continuations
                continuations = []
                for continuation in conts {
                    continuation()
                }
                counter2 &+= 1
                data.globalSubgraph.update(flags: .active)
            } while (continuations.count != 0 && counter2 != 8)
            inTransaction = false
            preferencesChanged = preferencesChanged || updatePreferences()
            observedSizeThatFitsChanged = observedSizeThatFitsChanged || updateObservedSizeThatFits()
            updatedOutputs.formUnion(updateRequestedOutputs())
        } while (data.globalSubgraph.isDirty(1) && counter1 != 8)
        
        guard preferencesChanged || observedSizeThatFitsChanged || !updatedOutputs.isEmpty || needsFocusUpdate else {
            return
        }
        if Thread.isMainThread {
            if preferencesChanged {
                delegate?.preferencesDidChange()
            }
            if observedSizeThatFitsChanged {
                sizeThatFitsObserver?.callback(oldCachedSizeThatFits, self.cachedSizeThatFits)
            }
            if !requestedOutputs.isEmpty {
                delegate?.outputsDidChange(outputs: updatedOutputs)
            }
            if needsFocusUpdate {
                needsFocusUpdate = false
                delegate?.focusDidChange()
            }
        } else {
            // TODO
        }
        mainUpdates &-= 1
    }
    
    private func updateObservedSizeThatFits() -> Bool {
        // TODO
        return false
    }
    
    private func updateRequestedOutputs() -> Outputs {
        // TODO
        return []
    }
    
    // MARK: - Override Methods
    
    override var graphDelegate: GraphDelegate? { delegate }
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
        
        static var layout: Outputs { .init(rawValue: 1 << 4) }
    }
}
