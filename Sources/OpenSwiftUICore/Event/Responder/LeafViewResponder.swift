//
//  LeafViewResponder.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: WIP
//  ID: A7CB304DFEF7D87240811B051B15E2CD (SwiftUICore)

package import Foundation
import OpenSwiftUI_SPI

// MARK: - ContentResponder

package protocol ContentResponder {
    func contains(points: UnsafeBufferPointer<CGPoint>, size: CGSize) -> BitVector64
    func contentPath(size: CGSize) -> Path
    func contentPath(size: CGSize, kind: ContentShapeKinds) -> Path
}

extension ContentResponder {
    package func contains(points: UnsafeBufferPointer<CGPoint>, size: CGSize) -> BitVector64 {
        points.mapBool { size.contains(point: $0) }
    }

    package func contentPath(size: CGSize) -> Path {
        Path(CGRect(origin: .zero, size: size))
    }

    package func contentPath(size: CGSize, kind: ContentShapeKinds) -> Path {
        if kind == .interaction || !_SemanticFeature_v3.isEnabled {
            return contentPath(size: size)
        } else {
            return Path()
        }
    }
}

// MARK: - TrivialContentResponder

package struct TrivialContentResponder: ContentResponder {
    package init() {
        _openSwiftUIEmptyStub()
    }
}

// MARK: - ContentPathObservers

struct ContentPathObservers {
    private struct Observer {
        weak var value: (any ContentPathObserver)?
    }

    private var observers: [Observer] = []

    @inline(__always)
    mutating func addObserver(_ observer: any ContentPathObserver) {
        guard !observers.contains(where: { $0.value === observer }) else { return }
        observers.append(Observer(value: observer))
    }

    @inline(__always)
    mutating func notifyDidChange(for parent: ViewResponder) {
        let oldObservers = observers
        observers = []
        for observer in oldObservers {
            guard let value = observer.value else { continue }
            value.respondersDidChange(for: parent)
        }
    }

    mutating func notifyPathChanged(for parent: ViewResponder, changes: ContentPathChanges, transform: (old: ViewTransform, new: ViewTransform)) {
        let oldObservers = observers
        observers = []
        for observer in oldObservers {
            var result = true
            guard let value = observer.value else { continue }
            value.contentPathDidChange(for: parent, changes: changes, transform: transform, finished: &result)
            guard !result else { continue }
            observers.append(observer)
        }
    }
}
