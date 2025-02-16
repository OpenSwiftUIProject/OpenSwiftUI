package import OpenGraphShims

extension Subgraph {
    package func willRemove() {
        forEach(.removable) { attribute in
            let type = attribute._bodyType
            if let removableType = type as? RemovableAttribute.Type {
                removableType.willRemove(attribute: attribute)
            }
        }
    }

    package func didReinsert() {
        forEach(.removable) { attribute in
            let type = attribute._bodyType
            if let removableType = type as? RemovableAttribute.Type {
                removableType.didReinsert(attribute: attribute)
            }
        }
    }

    package func willInvalidate(isInserted: Bool) {
        forEach(isInserted ? [.removable, .invalidatable] : [.invalidatable]) { attribute in
            let type = attribute._bodyType
            if let invalidatableType = type as? InvalidatableAttribute.Type {
                invalidatableType.willInvalidate(attribute: attribute)
            } else if isInserted, let removableType = type as? RemovableAttribute.Type {
                removableType.willRemove(attribute: attribute)
            }
        }
    }
}
