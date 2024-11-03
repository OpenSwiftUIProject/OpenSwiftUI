//
//  View_Indirect.swift
//  OpenSwiftUICore
//
//  Audited for iOS 18.0
//  Status: Complete

package import OpenGraphShims

extension _ViewInputs {
    func makeIndirectOutputs() -> _ViewOutputs {
        let indirectPreferenceOutputs = preferences.makeIndirectOutputs()
        var outputs = _ViewOutputs()
        outputs.preferences = indirectPreferenceOutputs
        guard requestsLayoutComputer else {
            return outputs
        }
        let defaultLayoutComputer = CoreGlue.shared.makeDefaultLayoutComputer().value
        @IndirectAttribute(source: defaultLayoutComputer)
        var indirect: LayoutComputer
        outputs.layoutComputer = $indirect
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
        
    package func attachIndirectOutputs(to childOutputs: _ViewOutputs) {
        preferences.attachIndirectOutputs(to: childOutputs.preferences)
        if let target = layoutComputer?.identifier,
           let source = childOutputs.layoutComputer?.identifier {
            target.source = source
        }
    }

    package func detachIndirectOutputs() {
        preferences.detachIndirectOutputs()
        if let target = layoutComputer?.identifier {
            target.source = .nil
        }
    }
    #endif
}
