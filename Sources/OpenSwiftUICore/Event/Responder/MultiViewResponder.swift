//
//  MultiViewResponder.swift
//  OpenSwiftUICore
//
//  Status: WIP

@_spi(ForOpenSwiftUIOnly)
open class MultiViewResponder: ViewResponder {
    override public init() {
        preconditionFailure("TODO")
    }

    final public override var children: [ViewResponder] {
        get { preconditionFailure("TODO") }

        set { preconditionFailure("TODO") }
    }

    final package func updateChildren(_ data: (value: [ViewResponder], changed: Bool)) {
        preconditionFailure("TODO")
    }

    open func childrenDidChange() {
        preconditionFailure("TODO")
    }

    override open func bindEvent(_ event: any EventType) -> ResponderNode? {
        preconditionFailure("TODO")
    }

    override open func resetGesture() {
        preconditionFailure("TODO")
    }

//    override open func containsGlobalPoints(
//        _ points: [PlatformPoint],
//        cacheKey: UInt32?,
//        options: ViewResponder.ContainsPointsOptions
//    ) -> (mask: BitVector64, priority: Double) {
//        preconditionFailure("TODO")
//    }

    override open func addContentPath(
        to path: inout Path,
        kind: ContentShapeKinds,
        in space: CoordinateSpace,
        observer: (any ContentPathObserver)?
    ) {
        preconditionFailure("TODO")
    }

    override open func addObserver(_ observer: any ContentPathObserver) {
        preconditionFailure("TODO")
    }

    @discardableResult
    override final public func visit(applying visitor: (ResponderNode) -> ResponderVisitorResult) -> ResponderVisitorResult {
        preconditionFailure("TODO")
    }

//    override final public var childCount: Int { preconditionFailure("TODO") }
//
//    override final public func child(at index: Int) -> ViewResponder {
//        preconditionFailure("TODO")
//    }

}

@available(*, unavailable)
extension MultiViewResponder: Sendable {}
