import _OpenGraph

public protocol Rule: _AttributeBody {
    associatedtype Value
    static var initialValue: Value? { get }
    var value: Value { get }
}

extension Rule {
    public static var initialValue: Value? { nil }

    // TODO
    public static func _update(_ value: UnsafeMutableRawPointer, attribute: OGAttribute) {
        
    }

    // TODO
    public static func _updateDefault(_ value: UnsafeMutableRawPointer) {

    }

//    public var attribute: Attribute<Value>
//    public var context: RuleContext<Value>
}
