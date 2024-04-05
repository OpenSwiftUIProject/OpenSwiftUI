internal import OpenGraphShims

public struct _ViewInputs {
    var base: _GraphInputs
    var preferences: PreferencesInputs
    var transform: Attribute<ViewTransform>
    var position: Attribute<ViewOrigin>
    var containerPosition: Attribute<ViewOrigin>
    var size: Attribute<ViewSize>
    var safeAreaInsets: OptionalAttribute<SafeAreaInsets>
    
    @inline(__always)
    func detechedEnvironmentInputs() -> Self {
        var newInputs = self
        newInputs.base = self.base.detechedEnvironmentInputs()
        return newInputs
    }
    
    func makeIndirectOutputs() -> _ViewOutputs {
        struct AddPreferenceVisitor: PreferenceKeyVisitor {
            var outputs = _ViewOutputs()
            mutating func visit<Key: PreferenceKey>(key: Key.Type) {
                let source = ViewGraph.current.intern(Key.defaultValue, id: 0)
                let indirect = IndirectAttribute(source: source)
                outputs.appendPreference(key: Key.self, value: Attribute(identifier: indirect.identifier))
            }
        }
        var visitor = AddPreferenceVisitor()
        preferences.keys.forEach { key in
            key.visitKey(&visitor)
        }
        var outputs = visitor.outputs
        outputs.setLayoutComputer(self) {
            let indirect = IndirectAttribute(source: ViewGraph.current.$defaultLayoutComputer)
            return Attribute(identifier: indirect.identifier)
        }
        return outputs
    }
        
    // MARK: Options
        
    @inline(__always)
    var enableLayout: Bool {
        get { base.enableLayout }
        // TODO: setter
    }
}
