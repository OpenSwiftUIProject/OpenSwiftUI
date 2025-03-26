//
//  ImpossibleActor.swift
//  OpenSwiftUICore
//
//  Audited for iOS 18.0
//  Status: Complete

@globalActor
public actor _ImpossibleActor: Sendable {
    public static var shared = _ImpossibleActor()
}

@_marker
@_ImpossibleActor
public protocol _RemoveGlobalActorIsolation {}
