internal import OpenGraphShims

extension OGSubgraph {
    func willRemove() {
        #if canImport(Darwin)
        OGSubgraph.apply(self, flags: .removable) { attribute in
            let type = attribute._bodyType
            if let removableType = type as? RemovableAttribute.Type {
                removableType.willRemove(attribute: attribute)
            }
        }
        #endif
    }

    func didReinsert() {
        #if canImport(Darwin)
        OGSubgraph.apply(self, flags: .removable) { attribute in
            let type = attribute._bodyType
            if let removableType = type as? RemovableAttribute.Type {
                removableType.didReinsert(attribute: attribute)
            }
        }
        #endif
    }

    func willInvalidate(isInserted: Bool) {
        #if canImport(Darwin)
        OGSubgraph.apply(self, flags: isInserted ? [.removable, .invalidatable] : [.invalidatable]) { attribute in
            let type = attribute._bodyType
            if let invalidatableType = type as? InvalidatableAttribute.Type {
                invalidatableType.willInvalidate(attribute: attribute)
            } else if isInserted, let removableType = type as? RemovableAttribute.Type {
                removableType.willRemove(attribute: attribute)
            }
        }
        #endif
    }
}
