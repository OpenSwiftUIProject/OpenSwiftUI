internal import OpenGraphShims

public struct _ViewOutputs {
    private var preferences = PreferencesOutputs()
    @OptionalAttribute
    var layoutComputer: LayoutComputer?
    
    subscript<Key: PreferenceKey>(_ keyType: Key.Type) -> Attribute<Key.Value>? {
        get { preferences[keyType] }
        set { preferences[keyType] = newValue }
    }
    
    func attachIndirectOutputs(to outputs: _ViewOutputs) {
        // TODO
    }
    
    func detachIndirectOutputs() {
        // TODO
    }
}
