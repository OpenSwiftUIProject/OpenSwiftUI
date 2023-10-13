import Foundation

@frozen
public struct _PreferenceTransformModifier<Key>: ViewModifier where Key: PreferenceKey {
    public var transform: (inout Key.Value) -> Void
    public typealias Body = Never
    @inlinable public init(key _: Key.Type = Key.self, transform: @escaping (inout Key.Value) -> Void) {
        self.transform = transform
    }
//    public static func _makeView(modifier: _GraphValue<_PreferenceTransformModifier<Key>>, inputs: _ViewInputs, body: @escaping (_Graph, _ViewInputs) -> _ViewOutputs) -> _ViewOutputs {
//
//    }
}
