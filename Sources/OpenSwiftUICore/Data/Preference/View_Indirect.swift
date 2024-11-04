//
//  View_Indirect.swift
//  OpenSwiftUICore
//
//  Audited for iOS 18.0
//  Status: Complete

#if canImport(Darwin)
package import OpenGraphShims
#else
import OpenGraphShims
#endif

extension _ViewInputs {
    func makeIndirectOutputs() -> _ViewOutputs {
        let indirectPreferenceOutputs = preferences.makeIndirectOutputs()
        var outputs = _ViewOutputs()
        outputs.preferences = indirectPreferenceOutputs
        guard requestsLayoutComputer else {
            return outputs
        }
        #if canImport(Darwin)
        let defaultLayoutComputer = CoreGlue.shared.makeDefaultLayoutComputer().value
        @IndirectAttribute(source: defaultLayoutComputer)
        var indirect: LayoutComputer
        outputs.layoutComputer = $indirect
        #endif
        return outputs
    }
}

extension _ViewOutputs {
    #if canImport(Darwin)
    package func setIndirectDependencies(_ dependency: AnyAttribute?) {
        preferences.setIndirectDependencies(dependency)
        if let target = layoutComputer?.identifier {
            target.indirectDependency = dependency
        }
    }
    #endif

        
    package func attachIndirectOutputs(to childOutputs: _ViewOutputs) {
        #if canImport(Darwin)
        preferences.attachIndirectOutputs(to: childOutputs.preferences)
        if let target = layoutComputer?.identifier,
           let source = childOutputs.layoutComputer?.identifier {
            target.source = source
        }
        #endif
    }

    package func detachIndirectOutputs() {
        #if canImport(Darwin)
        preferences.detachIndirectOutputs()
        if let target = layoutComputer?.identifier {
            target.source = .nil
        }
        #endif
    }
}
