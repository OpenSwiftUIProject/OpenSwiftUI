internal import OpenGraphShims

extension OGSubgraph {
    func willRemove() {
        OGSubgraph.apply(self, flags: .removable) { attribute in
            let type = attribute._bodyType
            if let removableType = type as? RemovableAttribute.Type {
                removableType.willRemove(attribute: attribute)
            }
        }
    }

    func didReinsert() {
        OGSubgraph.apply(self, flags: .removable) { attribute in
            let type = attribute._bodyType
            if let removableType = type as? RemovableAttribute.Type {
                removableType.didReinsert(attribute: attribute)
            }
        }
    }

    func willInvalidate(isInserted: Bool) {
        OGSubgraph.apply(self, flags: isInserted ? [.removable, .invalidatable] : [.invalidatable]) { attribute in
            let type = attribute._bodyType
            if let invalidatableType = type as? InvalidatableAttribute.Type {
                invalidatableType.willInvalidate(attribute: attribute)
            } else if isInserted, let removableType = type as? RemovableAttribute.Type {
                removableType.willRemove(attribute: attribute)
            }
        }
    }
}
