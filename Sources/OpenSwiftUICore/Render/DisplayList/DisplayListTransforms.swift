//
//  DisplayListTransforms.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete (TBA)
//  ID: 8C82E31DBCFF23E23B8937F47207F4D1 (SwiftUICore)

package import OpenAttributeGraphShims
package import OpenCoreGraphicsShims

extension DisplayList {
    package mutating func insertLayerFilters(
        matrices: [_ForegroundLayerLevel: _ColorMatrix],
        version: DisplayList.Version,
        premultiplied: Bool
    ) {
        var transform = ForegroundTransform(
            matrices: matrices,
            version: version,
            premultiplied: premultiplied
        )
        transform.apply(to: &self)
    }

    package mutating func applyViewGraphTransform(
        time: Attribute<Time>,
        version: DisplayList.Version
    ) {
        var transform = ViewGraphTransform(
            time: time,
            version: version
        )
        transform.apply(to: &self)
    }
}

// MARK: - ForegroundTransform [TBA]

private struct ForegroundTransform {
    var matrices: [_ForegroundLayerLevel: _ColorMatrix]
    let properties: DisplayList.Properties
    let version: DisplayList.Version
    let premultiplied: Bool
    var level: _ForegroundLayerLevel = .none

    init(
        matrices: [_ForegroundLayerLevel: _ColorMatrix],
        version: DisplayList.Version,
        premultiplied: Bool
    ) {
        self.matrices = matrices
        self.version = version
        self.premultiplied = premultiplied
        properties = matrices.keys.reduce(into: []) { properties, level in
            properties.formUnion(level.properties)
        }
    }

    mutating func apply(to displayList: inout DisplayList) {
        var result = NewList(version: version)

        for var item in displayList.items {
            let itemProperties = item.properties.intersection(properties)
            if level != .none || itemProperties.isEmpty {
                result.append(item, level: level, transform: self)
            } else if let fallbackLevel = transform(
                &item,
                properties: itemProperties
            ) {
                result.append(item, level: fallbackLevel, transform: self)
            } else {
                result.flushPendingItems(transform: self)
                result.append(item)
            }
        }
        result.flushPendingItems(transform: self)
        displayList = DisplayList(result.items)
    }

    private mutating func transform(
        _ item: inout DisplayList.Item,
        properties itemProperties: DisplayList.Properties
    ) -> _ForegroundLayerLevel? {
        switch item.value {
        case .empty:
            break
        case var .content(content):
            guard case let .flattened(nestedDisplayList, origin, options) = content.value else {
                break
            }
            var transformedDisplayList = nestedDisplayList
            apply(to: &transformedDisplayList)
            content.value = .flattened(transformedDisplayList, origin, options)
            item.value = .content(content)
        case let .effect(effect, displayList):
            var transformedDisplayList = displayList
            switch effect {
            case let .properties(effectProperties):
                let childLevel = _ForegroundLayerLevel(
                    effectProperties.intersection(properties)
                )
                let rawLevel = childLevel.properties.rawValue
                if rawLevel & (rawLevel &- 1) == 0 {
                    var transform = self
                    transform.level = childLevel
                    transform.apply(to: &transformedDisplayList)
                } else {
                    apply(to: &transformedDisplayList)
                }
                item.value = .effect(effect, transformedDisplayList)
            case let .filter(filter):
                guard let filterMatrix = _ColorMatrix(
                    filter,
                    premultiplied: premultiplied
                ) else {
                    return fallbackLevel(for: itemProperties)
                }
                var transform = self
                for (level, matrix) in transform.matrices {
                    transform.matrices[level] = matrix * filterMatrix
                }
                transform.apply(to: &transformedDisplayList)
                item.value = .effect(.identity, transformedDisplayList)
            default:
                apply(to: &transformedDisplayList)
                item.value = .effect(effect, transformedDisplayList)
            }
        case let .states(states):
            var states = states
            for index in states.indices {
                apply(to: &states[index].1)
            }
            item.value = .states(states)
        }
        return nil
    }

    private func fallbackLevel(
        for properties: DisplayList.Properties
    ) -> _ForegroundLayerLevel {
        if properties.contains(.foregroundLayer) {
            .primary
        } else if properties.contains(.secondaryForegroundLayer) {
            .secondary
        } else if properties.contains(.tertiaryForegroundLayer) {
            .tertiary
        } else if properties.contains(.quaternaryForegroundLayer) {
            .quaternary
        } else {
            .none
        }
    }

    // MARK: - ViewGraphTransform.NewList

    private struct NewList {
        var items: [DisplayList.Item] = []
        var pendingItems: [DisplayList.Item] = []
        var pendingLevel: _ForegroundLayerLevel = .none
        var pendingFrame: CGRect = .null
        var pendingVersion: DisplayList.Version

        init(version: DisplayList.Version) {
            pendingVersion = version
        }

        mutating func append(_ item: DisplayList.Item) {
            items.append(item)
        }

        mutating func append(
            _ item: DisplayList.Item,
            level: _ForegroundLayerLevel,
            transform: ForegroundTransform
        ) {
            if !pendingItems.isEmpty, pendingLevel != level {
                flushPendingItems(transform: transform)
            }
            pendingLevel = level
            pendingItems.append(item)
            pendingFrame = pendingFrame.union(item.frame)
            pendingVersion.combine(with: item.version)
        }

        mutating func flushPendingItems(transform: ForegroundTransform) {
            guard !pendingItems.isEmpty else {
                return
            }
            defer {
                pendingItems = []
                pendingFrame = .null
                pendingVersion = transform.version
            }

            guard let matrix = transform.matrices[pendingLevel], !matrix.isIdentity else {
                items.append(contentsOf: pendingItems)
                return
            }

            let frame = pendingFrame
            let origin = frame.origin
            for index in pendingItems.indices {
                pendingItems[index].frame.origin.x -= origin.x
                pendingItems[index].frame.origin.y -= origin.y
            }
            let filter = GraphicsFilter.colorMatrix(
                matrix,
                premultiplied: transform.premultiplied
            )
            let content = DisplayList(
                DisplayList.Item(
                    .effect(.compositingGroup, DisplayList(pendingItems)),
                    frame: frame,
                    identity: .none,
                    version: pendingVersion
                )
            )
            items.append(
                DisplayList.Item(
                    .effect(.filter(filter), content),
                    frame: CGRect(origin: .zero, size: frame.size),
                    identity: .none,
                    version: pendingVersion
                )
            )
        }
    }
}

// MARK: - ViewGraphTransform

private struct ViewGraphTransform {
    let time: Attribute<Time>
    let version: DisplayList.Version
    var states: [(StrongHash, DisplayList.Version)] = []

    private func needsTransform(_ features: DisplayList.Features) -> Bool {
        !features.isDisjoint(with: [.interpolatorRoots, .stateEffects]) ||
            (features.contains(.states) && !states.isEmpty)
    }

    @discardableResult
    mutating func apply(to displayList: inout DisplayList) -> DisplayList.Version {
        guard needsTransform(displayList.features) else {
            return .init()
        }
        var transformedVersion = DisplayList.Version()
        displayList.transform { item in
            switch item.value {
            case .empty:
                break
            case var .content(content):
                guard case let .flattened(nestedList, origin, options) = content.value else {
                    break
                }
                // NOTE: We can't use guard apply != .init() here
                guard needsTransform(nestedList.features) else { break }
                var list = nestedList
                let version = apply(to: &list)
                item.version.combine(with: version)
                content.value = .flattened(list, origin, options)
                content.seed = item.version.seed
                item.value = .content(content)
                transformedVersion.combine(with: version)
            case let .effect(originalEffect, nestedList):
                let version: DisplayList.Version
                let list: DisplayList
                let effect: DisplayList.Effect
                switch originalEffect {
                case let .mask(mask, options):
                    var n = nestedList
                    var v = apply(to: &n)
                    var mask = mask
                    v.combine(with: apply(to: &mask))
                    version = v
                    list = n
                    effect = .mask(mask, options)
                case let .state(hash):
                    states.append((hash, item.version))
                    var n = nestedList
                    version = apply(to: &n)
                    states.removeLast()
                    list = n
                    effect = .identity
                case let .interpolatorRoot(group, contentOrigin, contentOffset):
                    var n = nestedList
                    var v = apply(to: &n)
                    if group.rewriteDisplayList(
                        &n,
                        time: time,
                        contentOrigin: contentOrigin,
                        contentOffset: contentOffset,
                        version: self.version
                    ) {
                        v = self.version
                    }
                    version = v
                    list = n
                    effect = .identity
                default:
                    var n = nestedList
                    version = apply(to: &n)
                    list = n
                    effect = originalEffect
                }
                item.value = .effect(effect, list)
                item.version.combine(with: version)
                transformedVersion.combine(with: version)
            case let .states(values):
                guard let state = states.popLast() else {
                    break
                }
                if let value = values.first(where: { $0.0 == state.0 }) {
                    var list = value.1
                    let version = apply(to: &list)
                    item.version.combine(with: version)
                    item.value = .effect(.identity, list)
                } else {
                    item.value = .empty
                }
                item.version.combine(with: state.1)
                transformedVersion.combine(with: item.version)
                states.append(state)
            }
        }
        return transformedVersion
    }
}
