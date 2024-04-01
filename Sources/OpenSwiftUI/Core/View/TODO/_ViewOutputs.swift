internal import OpenGraphShims

public struct _ViewOutputs {
    var preferences : PreferencesOutputs = .init()
    @OptionalAttribute
    var layoutComputer: LayoutComputer?
    
    subscript<Key: PreferenceKey>(_ keyType: Key.Type) -> Attribute<Key.Value>? {
        get { preferences[keyType] }
        set { preferences[keyType] = newValue }
    }
}
