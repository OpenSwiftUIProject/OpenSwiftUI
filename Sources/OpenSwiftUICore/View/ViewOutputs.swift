import OpenGraphShims

/// The output (aka synthesized) attributes returned by each view.
public struct _ViewOutputs {
    private var preferences = PreferencesOutputs()
    @OptionalAttribute var layoutComputer: LayoutComputer?
    
    subscript<Key: PreferenceKey>(_ keyType: Key.Type) -> Attribute<Key.Value>? {
        get { preferences[keyType] }
        set { preferences[keyType] = newValue }
    }
    
    func attachIndirectOutputs(to targetOutputs: _ViewOutputs) {
        #if canImport(Darwin)
        preferences.forEach { key, value in
            guard let targetValue = targetOutputs.preferences.first(where: { targetKey, _ in
                targetKey == key
            })?.value else {
                return
            }
            value.source = targetValue
        }
        if let identifier = $layoutComputer?.identifier,
           let source = targetOutputs.$layoutComputer?.identifier {
            identifier.source = source
        }
        #endif
    }
    
    func detachIndirectOutputs() {
        #if canImport(Darwin)
        struct ResetPreference: PreferenceKeyVisitor {
            var dst: AnyAttribute
            func visit<Key: PreferenceKey>(key: Key.Type) {
                let graphHost = dst.graph.graphHost()
                let source = graphHost.intern(Key.defaultValue, id: .defaultValue)
                dst.source = source.identifier
            }
        }
        preferences.forEach { key, value in
            var visitor = ResetPreference(dst: value)
            key.visitKey(&visitor)
        }
        if let layoutComputer = $layoutComputer {
            layoutComputer.identifier.source = unsafeDowncast(layoutComputer.graph.graphHost(), to: ViewGraph.self).$defaultLayoutComputer.identifier
        }
        #endif
    }
    
    mutating func appendPreference<Key: PreferenceKey>(key: Key.Type, value: Attribute<Key.Value>) {
        preferences.appendPreference(key: key, value: value)
    }
    
    @inline(__always)
    mutating func setLayoutComputer(_ inputs: _ViewInputs, _ layoutComputer: () -> Attribute<LayoutComputer>) {
        guard inputs.enableLayout else {
            return
        }
        $layoutComputer = layoutComputer()
    }
    
    #if canImport(Darwin)
    @inline(__always)
    func forEach(body: (
        _ key: AnyPreferenceKey.Type,
        _ value: AnyAttribute
    ) throws -> Void
    ) rethrows {
        try preferences.forEach(body: body)
    }
    #endif
}
