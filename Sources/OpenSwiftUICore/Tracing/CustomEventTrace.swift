//
//  CustomEventTrace.swift
//  OpenSwiftUICore
//
//  Status: Blocked by Graph.addTraceEvent
//  Audited for 6.5.4
//  ID: 97DBD3D593583A413B8B642264BC61AE (SwiftUICore)

package import OpenAttributeGraphShims

// MARK: - CustomEventCategory

package enum CustomEventCategory: Int8 {
    case unknown = 0
    case observable = 0x4F   // "O"
    case transaction = 0x54  // "T"
    case action = 0x41       // "A"
    case graph = 0x47        // "G"
    case animation = 0x42    // "B"
}

// MARK: - CustomEventTrace

package struct CustomEventTrace {
    package class Recorder {
        var graph: Graph
        var cefOp: UnsafeMutablePointer<Int8>

        package init(graph: Graph) {
            self.graph = graph

            self.cefOp = UnsafeMutablePointer<Int8>.allocate(capacity: 7)
            self.cefOp.initialize(repeating: 0, count: 7)
            "CEF_".withCString { source in
                self.cefOp.update(from: source, count: 4)
            }
        }
    }

    package enum ObservableEventType: Int8 {
        case firedWithTransaction = 0x46  // "F"
    }
    
    package enum TransactionEventType: Int8 {
        case begin = 0x42                     // "B"
        case end = 0x45                       // "E"
        case append = 0x41                    // "A"
        case enqueue = 0x51                   // "Q"
        case continueAsNewTransaction = 0x4E  // "N"
        case continueAsContinuation = 0x43    // "C"
    }
    
    package enum ActionEventType: Int8 {
        package enum Reason: UInt32 {
            case onAppear = 0x41          // "A"
            case onChange = 0x43          // "C"
            case onDisappear = 0x44       // "D"
            case gesture = 0x47           // "G"
            case didReleaseButton = 0x52  // "R"
        }

        case enqueue = 0x45          // "E"
        case start = 0x53            // "S"
        case finish = 0x46           // "F"
        case gestureMetadata = 0x47  // "G"
    }

    package enum GraphEventType: Int8 {
        case setNeedsUpdate = 0x4E  // "N"
    }

    package enum AnimationEventType: Int8 {
        case animationBegin = 1
        case animationEnd = 2
        case animationAttrUpdate = 3
        case animationScheduleTick = 4
        case animationTick = 5
        case animationRetarget = 6
    }

    private static var enabledCategories: [Bool] = Array(repeating: false, count: 256)
    
    package static var isEnabled: Swift.Bool {
        recorder != nil
    }
    
    package static var recorder: CustomEventTrace.Recorder? = nil
    
    package static func register(graph: Graph) {
        recorder = Recorder(graph: graph)
    }

    package static func incrementTraceIDThreadSafe(id: inout UInt32) -> UInt32 {
        return UInt32(OSAtomicAdd32(2, &id)) / 2
    }
    
    package static func setEnabledCategory(_ category: CustomEventCategory, enabled: Bool) {
        enabledCategories[Int(category.rawValue)] = enabled
    }
    
    @inline(__always)
    package static func trace<Value>(_ category: CustomEventCategory, _ eventType: Int8, value: Value) {
        guard enabledCategories[Int(category.rawValue)], let recorder else {
            return
        }
        recorder.cefOp[4] = category.rawValue
        recorder.cefOp[5] = eventType
        _openSwiftUIUnimplementedWarning()
        // recorder.graph.addTraceEvent(recorder.cefOp, value: value)
    }

    package static func observableFireWithTransaction(transaction: UInt32, key: AnyKeyPath?, attribute: AnyAttribute) {
        trace(
            .observable,
            ObservableEventType.firedWithTransaction.rawValue,
            value: (transaction, key, attribute)
        )
    }

    package static func transactionBegin(_ id: UInt32) {
        trace(
            .transaction,
            TransactionEventType.begin.rawValue,
            value: id
        )
    }

    package static func transactionEnd(_ id: UInt32) {
        trace(
            .transaction,
            TransactionEventType.end.rawValue,
            value: id
        )
    }

    package static func transactionAppend(to id: UInt32) {
        trace(
            .transaction,
            TransactionEventType.append.rawValue,
            value: id
        )
    }

    package static func transactionEnqueue(_ id: UInt32) {
        trace(
            .transaction,
            TransactionEventType.enqueue.rawValue,
            value: id
        )
    }
 
    package static func transactionContinueAsNewTransaction(_ id: UInt32) {
        trace(
            .transaction,
            TransactionEventType.continueAsNewTransaction.rawValue,
            value: id
        )
    }

    package static func transactionContinueAsContinuation(_ graphHost: GraphHost) {
        trace(
            .transaction,
            TransactionEventType.continueAsContinuation.rawValue,
            value: graphHost
        )
    }

    package static func enqueueAction(_ id: UInt32, _ reason: ActionEventType.Reason?) {
        trace(
            .action,
            ActionEventType.enqueue.rawValue,
            value: (id, reason?.rawValue)
        )
    }

    package static func startAction(_ id: UInt32, _ reason: ActionEventType.Reason?) {
        trace(
            .action,
            ActionEventType.start.rawValue,
            value: (id, reason?.rawValue)
        )
    }
 
    package static func finishAction(_ id: UInt32, _ reason: ActionEventType.Reason?) {
        trace(
            .action,
            ActionEventType.finish.rawValue,
            value: (id, reason?.rawValue)
        )
    }

    package static func additionalInfo(_ id: UInt32, info: AnyAttribute?) {
        trace(
            .action,
            ActionEventType.gestureMetadata.rawValue,
            value: (id, info)
        )
    }

    package static func animationBegin(attribute: AnyAttribute?, propertyType: Any.Type, function: Animation.Function) {
        var duration = Double.nan
        var delay = Double.nan
        var speed = 1.0
        var repeatCount = Double.nan
        extractFunctionData(function, &duration, &delay, &speed, &repeatCount)
        trace(
            .animation,
            AnimationEventType.animationBegin.rawValue,
            value: (attribute, propertyType, duration, delay, speed, repeatCount)
        )
    }

    package static func animationEnd(_ attribute: AnyAttribute?) {
        trace(
            .animation,
            AnimationEventType.animationEnd.rawValue,
            value: attribute
        )
    }

    package static func animationAttrUpdate(_ attribute: AnyAttribute?) {
        trace(
            .animation,
            AnimationEventType.animationAttrUpdate.rawValue,
            value: attribute
        )
    }

    package static func animationScheduleTick(attribute: AnyAttribute?, time: Time) {
        trace(
            .animation,
            AnimationEventType.animationScheduleTick.rawValue,
            value: (attribute, time.seconds)
        )
    }

    package static func animationTick(onMain: Bool, time: Time) {
        trace(
            .animation,
            AnimationEventType.animationTick.rawValue,
            value: (onMain, time.seconds)
        )
    }

    package static func animationRetarget(attribute: AnyAttribute?, propertyType: Any.Type, function: Animation.Function) {
        var duration = Double.nan
        var delay = Double.nan
        var speed = 1.0
        var repeatCount = Double.nan
        extractFunctionData(function, &duration, &delay, &speed, &repeatCount)
        trace(
            .animation,
            AnimationEventType.animationRetarget.rawValue,
            value: (attribute, propertyType, duration, delay, speed, repeatCount)
        )
    }
    
    private static func extractFunctionData(
        _ function: Animation.Function,
        _ duration: inout Double,
        _ delay: inout Double,
        _ speed: inout Double,
        _ repeatCount: inout Double
    ) {
        switch function {
        case let .linear(value),
            let .circularEaseIn(value),
            let .circularEaseOut(value),
            let .circularEaseInOut(value),
            let .bezier(value, _, _),
            let .spring(value, _, _, _, _):
            duration = value
        case .customFunction:
            break
        case let .delay(value, nested):
            if delay.isNaN {
                delay = value / speed
            }
            extractFunctionData(nested, &duration, &delay, &speed, &repeatCount)
        case let .speed(value, nested):
            speed *= value
            extractFunctionData(nested, &duration, &delay, &speed, &repeatCount)
        case let .`repeat`(count, _, nested):
            repeatCount *= count
            extractFunctionData(nested, &duration, &delay, &speed, &repeatCount)
        }
    }
  
    package static func setNeedsUpdate(values: ViewRendererHostProperties) {
        trace(
            .graph,
            GraphEventType.setNeedsUpdate.rawValue,
            value: values
        )
    }
}
