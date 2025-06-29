//
//  ContentPathObservers.swift
//  OpenSwiftUICore
//
//  Status: Complete
//  ID: A7CB304DFEF7D87240811B051B15E2CD (SwiftUICore?)

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
        var failedObservers: [Observer] = []
        for observer in oldObservers {
            var result = true
            guard let value = observer.value else { continue }
            value.contentPathDidChange(for: parent, changes: changes, transform: transform, finished: &result)
            guard !result else { continue }
            failedObservers.append(observer)
        }
    }
}
