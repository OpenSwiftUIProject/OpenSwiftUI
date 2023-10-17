public protocol Rule: _AttributeBody {
    associatedtype Value
    static var initialValue: Value? { get }
    var value: Value { get }
}

extension Rule {
    public static var initialValue: Value? {
        // TODO
        nil
    }

    // TODO: More extension here
}
