//
//  _RemoveGlobalActor.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: E36588D6F4797F7C6EF26CC7E1C2D1CE

@globalActor
public actor _ImpossibleActor: Sendable {
    public static var shared = _ImpossibleActor()
    
    public nonisolated var unownedExecutor: UnownedSerialExecutor {
        _ImpossibleExecutor().asUnownedSerialExecutor()
    }
}

private final class _ImpossibleExecutor: SerialExecutor {
    func enqueue(_ job: consuming ExecutorJob) {
        preconditionFailure("_RemoveGlobalActorIsolation is not intended to be used as a stand-alone protocol with a global actor isolation.")
    }
}

@_marker
@_ImpossibleActor
public protocol _RemoveGlobalActorIsolation {}
