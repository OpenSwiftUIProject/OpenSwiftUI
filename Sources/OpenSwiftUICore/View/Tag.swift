//
//  Tag.swift
//  OpenSwiftUICore
//
//  Audited for 6.5.4
//  Status: Complete
//  ID: 0F8CE0FEFF8003CACFB16F1C88624A9F (SwiftUICore)

// MARK: - View + Tag

@available(OpenSwiftUI_v1_0, *)
extension View {

    /// Sets the unique tag value of this view.
    ///
    /// Use this modifier to differentiate among certain selectable views,
    /// like the possible values of a ``Picker`` or the tabs of a ``TabView``.
    /// Tag values can be of any type that conforms to the
    /// [Hashable](https://developer.apple.com/documentation/swift/hashable) protocol.
    ///
    /// This modifier will write the tag value for the type `V`, as well as
    /// `Optional<V>` if `includeOptional` is enabled. Containers checking for
    /// tags of either type will see the value as set.
    ///
    /// In the example below, the ``ForEach`` loop in the ``Picker`` view
    /// builder iterates over the `Flavor` enumeration. It extracts the string
    /// value of each enumeration element for use in constructing the row
    /// label, and uses the enumeration value as input to the `tag(_:)`
    /// modifier.
    ///
    ///     struct FlavorPicker: View {
    ///         enum Flavor: String, CaseIterable, Identifiable {
    ///             case chocolate, vanilla, strawberry
    ///             var id: Self { self }
    ///         }
    ///
    ///         @State private var selectedFlavor: Flavor? = nil
    ///
    ///         var body: some View {
    ///             Picker("Flavor", selection: $selectedFlavor) {
    ///                 ForEach(Flavor.allCases) { flavor in
    ///                     Text(flavor.rawValue)
    ///                         .tag(flavor)
    ///                 }
    ///             }
    ///         }
    ///     }
    ///
    /// The selection type of the ``Picker`` is an `Optional<Flavor>` and so it
    /// will look for tags on its contents of `Optional<Flavor>`type. Since the
    /// tag modifier defaults to having `includeOptional` enabled, even though
    /// the tag for each option is a non-optional `Flavor`, the tag modifier
    /// writes values for both the non-optional, and optional versions of the
    /// value, allowing the contents to be selectable by the ``Picker``.
    ///
    /// A ``ForEach`` automatically applies a default tag to each enumerated
    /// view using the `id` parameter of the corresponding element. If
    /// the element's `id` parameter and the picker's `selection` input
    /// have exactly the same type, or the same type but optional, you can omit
    /// the explicit tag modifier.
    ///
    /// To see examples that don't require an explicit tag, see ``Picker``.
    ///
    /// - Parameter tag: A [Hashable](https://developer.apple.com/documentation/swift/hashable)
    ///   value to use as the view's tag.
    /// - Parameter includeOptional: If the tag value for `Optional<V>` should
    ///   also be set.
    ///
    /// - Returns: A view with the specified tag set.
    @_alwaysEmitIntoClient
    nonisolated public func tag<V>(_ tag: V, includeOptional: Bool = true) -> some View where V: Hashable {
        _trait(TagValueTraitKey<V>.self, .tagged(tag))
            ._trait(
                TagValueTraitKey<V?>.self,
                includeOptional ? .tagged(Optional(tag)) : .untagged
            )
    }

    /// Sets the view as acting as explicit untagged / auxiliary content that
    /// will not be wrapped by container views.
    ///
    /// For example, `Picker` treats its contents as option button labels.
    /// A view that is marked as `untagged()` will result
    /// in the view not being considered an option, and just an extra element
    /// in the picker.
    @inlinable
    nonisolated public func _untagged() -> some View {
        _trait(IsAuxiliaryContentTraitKey.self, true)
    }

    @usableFromInline
    @MainActor
    @preconcurrency
    func tag<V>(_ tag: V) -> some View where V: Hashable {
        _trait(TagValueTraitKey<V>.self, .tagged(tag))
    }
}

// MARK: - TagValueTraitKey

@available(OpenSwiftUI_v1_0, *)
@usableFromInline
package struct TagValueTraitKey<V>: _ViewTraitKey where V: Hashable {
    @usableFromInline
    @frozen
    package enum Value {
        case untagged
        case tagged(V)
    }

    @inlinable
    package static var defaultValue: TagValueTraitKey<V>.Value {
        .untagged
    }
}

@available(*, unavailable)
extension TagValueTraitKey.Value: Sendable {}

@available(*, unavailable)
extension TagValueTraitKey: Sendable {}

// MARK: - IsAuxiliaryContentTraitKey

@available(OpenSwiftUI_v1_0, *)
@usableFromInline
package struct IsAuxiliaryContentTraitKey: _ViewTraitKey {
    @inlinable
    package static var defaultValue: Bool {
        false
    }
}

@available(*, unavailable)
extension IsAuxiliaryContentTraitKey: Sendable {}

extension ViewTraitCollection {
    package var isAuxiliaryContent: Bool {
        get { self[IsAuxiliaryContentTraitKey.self] }
        set { self[IsAuxiliaryContentTraitKey.self] = newValue }
    }
}

// MARK: - ViewTraitCollection + Tag

extension ViewTraitCollection {
    package func tagValue<V>(for type: V.Type) -> V? where V: Hashable {
        let value = self[TagValueTraitKey<V>.self]
        return switch value {
        case let .tagged(tag): tag
        case .untagged: nil
        }
    }

    package func tag<V>(for type: V.Type) -> V? where V: Hashable {
        let value = self[TagValueTraitKey<V>.self]
        return switch value {
        case let .tagged(tag): isAuxiliaryContent ? nil : tag
        case .untagged: nil
        }
    }

    package mutating func setTagIfUnset<V>(for type: V.Type, value: V) where V: Hashable {
        setValueIfUnset(.tagged(value), for: TagValueTraitKey<V>.self)
    }

    package mutating func setTag<V>(for type: V.Type, value: V) where V: Hashable {
        self[TagValueTraitKey<V>.self] = .tagged(value)
    }
}

// MARK: - Binding + Tag

extension Binding {
    package func selecting(_ tag: Value?) -> Binding<Bool> where Value: Hashable {
        guard let tag else {
            return .false
        }
        return self == tag
    }
}

extension Binding where Value: Hashable {
    package func projectingTagIndex(viewList: any ViewList) -> Binding<Int?> {
        projecting(TagIndexProjection<Value>(list: viewList))
    }
}

// MARK: - TagIndexProjection

private class TagIndexProjection<Value>: Projection where Value: Hashable {
    let list: any ViewList
    var nextIndex: Int? = .zero
    var indexMap: [Int: Value] = [:]
    var tagMap: [Value: Int] = [:]

    init(list: any ViewList) {
        self.list = list
    }

    func get(base: Value) -> Int? {
        if let index = tagMap[base] {
            return index
        } else {
            var i: Int? = nil
            readUntil { index, value in
                let result = value == base
                if result {
                    i = index
                }
                return result
            }
            return i
        }
    }

    func set(base: inout Value, newValue: Int?) {
        guard let newValue else {
            return
        }
        if let tag = indexMap[newValue] {
            base = tag
        } else {
            readUntil { index, value in
                let result = newValue == index
                if result {
                    base = value
                }
                return result
            }
        }
    }

    func readUntil(_ body: (Int, Value) -> Bool) {
        guard var nextIndex else {
            return
        }
        var index = nextIndex
        let result = list.applySublists(
            from: &index,
            list: nil
        ) { sublist in
            nextIndex &-= sublist.start
            defer { nextIndex &+= sublist.count }
            let traits = sublist.traits
            guard let tag = traits.tag(for: Value.self) else {
                return true
            }
            tagMap[tag] = nextIndex
            var index = nextIndex
            var count = list.count
            Swift.precondition(index + count >= index)
            while count != 0 {
                indexMap[index] = tag
                index &+= 1
                count &-= 1
            }
            return !body(nextIndex, tag)
        }
        self.nextIndex = result ? nil : nextIndex
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }

    static func == (lhs: TagIndexProjection<Value>, rhs: TagIndexProjection<Value>) -> Bool {
        lhs === rhs
    }
}
