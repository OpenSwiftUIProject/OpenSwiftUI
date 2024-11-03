//
//  View+Indirect.swift
//  OpenSwiftUICore
//
//  Audited for RELEASE_2024
//  Status: WIP

package import OpenGraphShims

extension _ViewInputs {
    func makeIndirectOutputs() -> _ViewOutputs {
        #if canImport(Darwin)
        struct AddPreferenceVisitor: PreferenceKeyVisitor {
            var outputs = _ViewOutputs()
            mutating func visit<Key: PreferenceKey>(key: Key.Type) {
//                let source = ViewGraph.current.intern(Key.defaultValue, id: 0)
//                let indirect = IndirectAttribute(source: source)
//                outputs.appendPreference(key: Key.self, value: Attribute(identifier: indirect.identifier))
                fatalError()
            }
        }
        var visitor = AddPreferenceVisitor()
        preferences.keys.forEach { key in
            key.visitKey(&visitor)
        }
        var outputs = visitor.outputs
//        outputs.setLayoutComputer(self) {
//            let indirect = IndirectAttribute(source: ViewGraph.current.$defaultLayoutComputer)
//            return Attribute(identifier: indirect.identifier)
//        }
//        mutating func setLayoutComputer(_ inputs: _ViewInputs, _ layoutComputer: () -> Attribute<LayoutComputer>) {
    //        guard inputs.requestsLayoutComputer else {
    //            return
    //        }
    //        $layoutComputer = layoutComputer()
//        }
        return outputs
        #else
        fatalError("See #39")
        #endif
    }
}

extension _ViewOutputs {
    #if canImport(Darwin)
    package func setIndirectDependencies(_ dependency: AnyAttribute?) {
        fatalError()
    }
        
    package func attachIndirectOutputs(to childOutputs: _ViewOutputs) {
    //        preferences.forEach { key, value in
    //            guard let targetValue = childOutputs.preferences.first(where: { targetKey, _ in
    //                targetKey == key
    //            })?.value else {
    //                return
    //            }
    //            value.source = targetValue
    //        }
    //        if let identifier = $layoutComputer?.identifier,
    //           let source = childOutputs.$layoutComputer?.identifier {
    //            identifier.source = source
    //        }
    }


    func detachIndirectOutputs() {
    //        struct ResetPreference: PreferenceKeyVisitor {
    //            var dst: AnyAttribute
    //            func visit<Key: PreferenceKey>(key: Key.Type) {
    //                let graphHost = dst.graph.graphHost()
    //                let source = graphHost.intern(Key.defaultValue, id: .defaultValue)
    //                dst.source = source.identifier
    //            }
    //        }
    //        preferences.forEach { key, value in
    //            var visitor = ResetPreference(dst: value)
    //            key.visitKey(&visitor)
    //        }
    //        if let layoutComputer = $layoutComputer {
    //            layoutComputer.identifier.source = unsafeDowncast(layoutComputer.graph.graphHost(), to: ViewGraph.self).$defaultLayoutComputer.identifier
    //        }
    }
    #endif
}
