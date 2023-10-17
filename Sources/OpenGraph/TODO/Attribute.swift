import _OpenGraph

@propertyWrapper
public struct Attribute<A> {
    var identifier: OGAttribute

    public var wrappedValue: A { fatalError() }
}
