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
    var centersRootView: Bool = true
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
    var cachedSizeThatFits: CGSize = .invalidValue
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
    var disabledOutputs: Outputs = []
    var mainUpdates: Int = 0
    var needsFocusUpdate: Bool = false
    var nextUpdate: (views: NextUpdate, gestures: NextUpdate) = (NextUpdate(time: .infinity), NextUpdate(time: .infinity))
    // TODO
    
    init<Body: View>(rootViewType: Body.Type, requestedOutputs: Outputs) {
        #if canImport(Darwin)
        self.rootViewType = rootViewType
        self.requestedOutputs = requestedOutputs
        
        let data = GraphHost.Data()
        OGSubgraph.current = data.globalSubgraph
        rootView = Attribute(type: Body.self).identifier
        _rootTransform = Attribute(RootTransform())
        _zeroPoint = Attribute(value: .zero)
        // TODO
        _proposedSize = Attribute(value: .zero)
        // TODO
        _rootGeometry = Attribute(RootGeometry()) // FIXME
        _position = _rootGeometry.origin()
        _dimensions = _rootGeometry.size()
        _updateSeed = Attribute(value: .zero)
        // FIXME
        makeRootView = { view, inputs in
            let rootView = _GraphValue<Body>(view.unsafeCast(to: Body.self))
            return Body._makeView(view: rootView, inputs: inputs)
        }
        super.init(data: data)
        OGSubgraph.current = nil
        #else
        fatalError("TOOD")
        #endif
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
        #if canImport(Darwin)
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
            fatalError("TODO")
        }
        mainUpdates &-= 1
        #endif
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
    override var parentHost: GraphHost? {
        // TODO: _preferenceBridge
        nil
    }
    
    override func instantiateOutputs() {
        // TODO
    }
    
    override func uninstantiateOutputs() {
        // TODO
    }
    
    override func timeDidChange() {
        nextUpdate.views = NextUpdate(time: .infinity)
    }
    
    override func isHiddenForReuseDidChange() {
        // TODO
    }
}

extension ViewGraph {
    struct NextUpdate {
        var time: Time
        var _interval: Double
        var reasons: Set<UInt32>
        
        @inline(__always)
        init(time: Time) {
            self.time = time
            _interval = .infinity
            reasons = []
        }
        
        // TODO: AnimatorState.nextUpdate
        mutating func interval(_ value: Double, reason: UInt32?) {
            if value == .zero {
                if _interval > 1 / 60 {
                    _interval = .infinity
                }
            } else {
                _interval = min(value, _interval)
            }
            if let reason {
                reasons.insert(reason)
            }
        }
    }
}

extension ViewGraph {
    struct Outputs: OptionSet {
        let rawValue: UInt8
        
        static var layout: Outputs { .init(rawValue: 1 << 4) }
    }
}

private struct RootTransform: Rule {
    var value: ViewTransform {
        let graph = GraphHost.currentHost as! ViewGraph
        guard let delegate = graph.delegate else {
            return ViewTransform()
        }
        return delegate.rootTransform()
    }
}

struct RootGeometry: Rule {
    var value: ViewGeometry {
        // FIXME
        .zero
    }
}
