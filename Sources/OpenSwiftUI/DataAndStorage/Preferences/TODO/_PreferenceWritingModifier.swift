@frozen
public struct _PreferenceWritingModifier<Key>: ViewModifier where Key: PreferenceKey {
    public var value: Key.Value
    public typealias Body = Never
    @inlinable public init(key _: Key.Type = Key.self, value: Key.Value) {
        self.value = value
    }
    //  public static func _makeView(modifier: _GraphValue<_PreferenceWritingModifier<Key>>, inputs: _ViewInputs, body: @escaping (_Graph, _ViewInputs) -> _ViewOutputs) -> _ViewOutputs
    //  public static func _makeViewList(modifier: _GraphValue<_PreferenceWritingModifier<Key>>, inputs: _ViewListInputs, body: @escaping (_Graph, _ViewListInputs) -> _ViewListOutputs) -> _ViewListOutputs
}

//extension _PreferenceWritingModifier: Equatable where Key.Value: Equatable {
//    public static func == (a: _PreferenceWritingModifier<Key>, b: _PreferenceWritingModifier<Key>) -> Bool
//}
