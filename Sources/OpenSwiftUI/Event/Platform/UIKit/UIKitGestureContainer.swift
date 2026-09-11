//
//  UIKitGestureContainer.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: 6F33F06695325DC57B8FF01F0A534046 (SwiftUI)

#if os(iOS) || os(visionOS)
import COpenSwiftUI
import OpenAttributeGraphShims
@_spi(ForOpenSwiftUIOnly)
import OpenSwiftUICore
import UIKit

// MARK: - UIKitGestureContainer

class UIKitGestureContainer: UIResponder, _UIGestureRecognizerContainer {
    weak var responder: (any AnyGestureContainingResponder)? = nil

    var subgraphObserver: Int? = nil

    private var registeredGestureRecognizers: [WeakBox<UIGestureRecognizer>] = []

    var _actingParentContainer: (any _UIGestureRecognizerContainer)? = nil

    init(responder: any AnyGestureContainingResponder) {
        self.responder = responder
        super.init()
        subgraphObserver = responder.viewSubgraph.addObserver { [weak self] in
            guard let self else { return }
            unregister()
            subgraphObserver = nil
        }
    }

    @objc var _proxyView: UIView? {
        responder?.host?.as(UIView.self)
    }

    override var description: String {
        let name = responder.map { "\($0.gestureType)" } ?? "nil"
        var result = "UIKitGestureContainer<\(name)>"
        if let responder = responder as? any AnyGestureResponder,
           responder.exclusionPolicy != .default {
            result += " \(responder.exclusionPolicy)"
        }
        result += " \(address(of: self))"
        return result
    }

    override var next: UIResponder? {
        (_actingParentContainer as? UIResponder) ?? (_parentContainer as? UIResponder) ?? _proxyView
    }

    var gestureRecognizers: [UIGestureRecognizer] {
        guard let responder else { return [] }
        var recognizers: [UIGestureRecognizer] = []
        Update.ensure {
            recognizers = responder.eventSources.compactMap { $0.as(UIGestureRecognizer.self) }
        }
        registeredGestureRecognizers.reserveCapacity(recognizers.count)
        for recognizer in recognizers {
            _UIGestureRecognizerRegisterInContainer(recognizer, self)
            registeredGestureRecognizers.append(WeakBox(recognizer))
        }
        return recognizers
    }

    var _parentContainer: (any _UIGestureRecognizerContainer)? {
        guard let responder else { return nil }
        var parent = responder.parent
        while let current = parent {
            if let container = current.gestureContainer {
                return (container as! any _UIGestureRecognizerContainer)
            } else if let view = (current as? UIViewResponder)?.hostView {
                return view
            } else {
                parent = current.parent
                continue
            }
        }
        return responder.host?.as(UIView.self)
    }

    var _childContainers: [any _UIGestureRecognizerContainer] {
        responder?.childGestureContainers ?? []
    }

    var _eventReceivingWindow: UIWindow? {
        _proxyView?.window
    }

    func addGestureRecognizer(_ gestureRecognizer: UIGestureRecognizer) {
        _openSwiftUIEmptyStub()
    }

    func removeGestureRecognizer(_ gestureRecognizer: UIGestureRecognizer) {
        _openSwiftUIEmptyStub()
    }

    func _compareGestureRecognizerContainer(_ container: any _UIGestureRecognizerContainer) -> ComparisonResult {
        _UIGestureRecognizerContainerCompare(self, container, false)
    }

    private func unregister() {
        responder?.detachContainer()
        for recognizer in registeredGestureRecognizers {
            if let recognizer = recognizer.base {
                _UIGestureRecognizerUnregisterFromContainer(recognizer, self)
            }
        }
        registeredGestureRecognizers = []
    }
}

// MARK: - ViewResponder + Gesture Containers

extension ViewResponder {
    var childGestureContainers: [UIResponder & _UIGestureRecognizerContainer] {
        var containers: [UIResponder & _UIGestureRecognizerContainer] = []
        for child in children {
            if let container = child.gestureContainer {
                containers.append(container as! (UIResponder & _UIGestureRecognizerContainer))
            } else if let view = (child as? UIViewResponder)?.hostView {
                containers.append(view)
            } else {
                containers.append(contentsOf: child.childGestureContainers)
            }
        }
        return containers
    }
}

// MARK: - UIKitGestureContainerFactory

struct UIKitGestureContainerFactory: GestureContainerFactory {
    static func makeGestureContainer(responder: any AnyGestureContainingResponder) -> AnyObject {
        UIKitGestureContainer(responder: responder)
    }
}

// MARK: - printGestureContainerAncestors

func printGestureContainerAncestors(_ container: any _UIGestureRecognizerContainer) {
    let description = _UIGestureRecognizerContainerAncestralDescription(container) { container in
        if let container = container as? UIKitGestureContainer {
            container.description
        } else {
            "\(Metadata(type(of: container)).description) \(address(of: container))"
        }
    }
    Log.eventDebug("GESTURE CONTAINERS\n" + description)
}
#endif
