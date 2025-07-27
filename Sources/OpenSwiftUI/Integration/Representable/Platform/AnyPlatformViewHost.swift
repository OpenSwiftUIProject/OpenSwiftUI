//
//  AnyPlatformViewHost.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete

@_spi(ForOpenSwiftUIOnly)
import OpenSwiftUICore
import OpenGraphShims

// MARK: - AnyPlatformViewHost

protocol AnyPlatformViewHost: AnyObject {
    var responder: PlatformViewResponder? { get }
}

// MARK: - AnyPlatformViewProviderHost

protocol AnyPlatformViewProviderHost {
    associatedtype PlatformViewProvider

    var representedViewProvider: PlatformViewProvider { get }
}

// MARK: - PlatformLayoutContainer

protocol PlatformLayoutContainer: AnyObject {
    func enqueueLayoutInvalidation()
}

// MARK: - EmptyPreferenceImporter

class EmptyPreferenceImporter {
    init(graph: ViewGraph) {
        _openSwiftUIBaseClassAbstractMethod()
    }

    func writePreferences(
        to outputs: inout _ViewOutputs,
        inputs: _ViewInputs
    ) {
        _openSwiftUIBaseClassAbstractMethod()
    }
}

// MARK: - PlatformViewLayoutInvalidator

struct PlatformViewLayoutInvalidator {
    weak var graphHost: GraphHost?
    var layoutComputer: WeakAttribute<LayoutComputer>
}

// FIXME: Gesture System

#if canImport(AppKit)
class NSViewResponder {}
#elseif canImport(UIKit)
class UIViewResponder {}
#endif
