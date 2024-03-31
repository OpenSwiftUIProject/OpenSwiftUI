//
//  PreferenceBridge.swift
//  OpenSwiftUI
//
//  Audited for RELEASE_2021
//  Status: WIP
//  ID: A9FAE381E99529D5274BA37A9BC9B074

internal import OpenGraphShims

class PreferenceBridge {
    unowned let viewGraph: ViewGraph
    private var children: [Unmanaged<ViewGraph>] = []
    var requestedPreferences: PreferenceKeys = PreferenceKeys()
    var bridgedViewInputs: PropertyList = PropertyList()
    @WeakAttribute var hostPreferenceKeys: PreferenceKeys?
    @WeakAttribute var hostPreferencesCombiner: PreferenceList?
    private var bridgedPreferences: [PreferenceBridge.BridgedPreference] = []
    
    init() {
        viewGraph = GraphHost.currentHost as! ViewGraph
    }
    
    func invalidate() {
        requestedPreferences = PreferenceKeys()
        bridgedViewInputs = PropertyList()
        for child in children {
            child.takeRetainedValue().preferenceBridge = nil
            child.release()
        }
    }
    
    func wrapInputs(_ inputs: inout _ViewInputs) {
        inputs.base.customInputs = bridgedViewInputs
        requestedPreferences.merge(inputs.preferences.keys) // Blocked by PreferenceInputs
        // WIP
//        requestedPreferences
        // TODO
    }
    
//    wrapOutputs(_: inout SwiftUI.PreferencesOutputs, inputs: SwiftUI._ViewInputs) -> ()
}

extension PreferenceBridge {
    struct BridgedPreference {
        var key: AnyPreferenceKey.Type
        var combiner: OGWeakAttribute
    }
}

private struct MergePreferenceKeys: Rule, AsyncAttribute {
    @Attribute var lhs: PreferenceKeys
    @WeakAttribute var rhs: PreferenceKeys?
    
    var value: PreferenceKeys {
        var result = lhs
        guard let rhs else {
            return result
        }
        result.merge(rhs)
        return result
    }
}

//


//; struct SwiftUI.PreferenceBridge.moveValue.AddValue {
//                            ;     var combiner: __C.AGAttribute
//                            ;     var value: __C.AGAttribute
//                            ; }
