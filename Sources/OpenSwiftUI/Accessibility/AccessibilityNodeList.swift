import OpenAttributeGraphShims

// FIXME
struct AccessibilityNodeList {
    var nodes: [AccessibilityNode]
    var version: DisplayList.Version
}

class AccessibilityNode {
    // TODO
}

// TODO
struct AccessibilityNodeProxy {
    static func makeProxyForIdentifiedView(
        with list: AccessibilityNodeList?,
        environment: EnvironmentValues
    ) -> AccessibilityNodeProxy? {
        nil
    }
}

// MARK: - AccessibilityNodesKey [6.4.41]

struct AccessibilityNodesKey: PreferenceKey {
    static let defaultValue = AccessibilityNodeList(nodes: [], version: .init())

    static func reduce(value: inout AccessibilityNodeList, nextValue: () -> AccessibilityNodeList) {
        let next = nextValue()
        value.version.combine(with: next.version)
        value.nodes.append(contentsOf: next.nodes)
    }
}

extension PreferencesInputs {
    @inline(__always)
    var requiresAccessibilityNodes: Bool {
        get { contains(AccessibilityNodesKey.self) }
        set {
            if newValue {
                add(AccessibilityNodesKey.self)
            } else {
                remove(AccessibilityNodesKey.self)
            }
        }
    }
}

extension _ViewOutputs {
    @inline(__always)
    var accessibilityNodes: Attribute<AccessibilityNodeList>? {
        get { self[AccessibilityNodesKey.self] }
        set { self[AccessibilityNodesKey.self] = newValue }
    }
}
