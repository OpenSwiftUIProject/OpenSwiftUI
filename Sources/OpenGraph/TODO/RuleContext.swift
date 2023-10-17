public struct RuleContext<A> {
    public var attribute: Attribute<A>

    public init(attribute: Attribute<A>) {
        self.attribute = attribute
    }
}
