//
//  Namespace.swift
//  OpenSwiftUICore
//
//  Audited for iOS 18.0
//  Status: Complete
//  ID: 79F323039D8AB6E63210271E57AD5E86 (SwiftUICore)

/// A dynamic property type that allows access to a namespace defined
/// by the persistent identity of the object containing the property
/// (e.g. a view).
@frozen
@propertyWrapper
public struct Namespace: DynamicProperty, Sendable {
    @usableFromInline
    var id: Int

    package init(id: Int) {
      self.id = id
    }

    @inlinable
    public init() { id = 0 }

    private struct Box: DynamicPropertyBox {

        typealias Property = Namespace

        var id: Int

        mutating func reset() {
            id = 0
        }

        mutating func update(property: inout Property, phase: ViewPhase) -> Bool {
            let oldID = id
            if oldID == 0 {
                id = UniqueID().value
            }
            property.id = id
            return oldID == 0
        }
    }

    public static func _makeProperty<V>(
        in buffer: inout _DynamicPropertyBuffer,
        container: _GraphValue<V>,
        fieldOffset: Int,
        inputs: inout _GraphInputs
    ) {
        buffer.append(Box(id: 0), fieldOffset: fieldOffset)
    }

    public var wrappedValue: Namespace.ID {
        guard id != .zero else {
            Log.runtimeIssues("Reading a Namespace property outside View.body. This will result in identifiers that never match any other identifier.")
            return Namespace.ID(id: UniqueID().value)
        }
        return Namespace.ID(id: id)
    }

    /// A namespace defined by the persistent identity of an
    /// `@Namespace` dynamic property.
    @frozen
    public struct ID: Hashable {
        package private(set) var id: Int

        package init(id: Int) {
            self.id = id
        }
    }
}
