//
//  AnyView.swift
//  OpenSwiftUI
//
//  Audited for RELEASE_2021
//  Status: WIP
//  ID: A96961F3546506F21D8995C6092F15B5

internal import OpenGraphShims

@frozen
public struct AnyView: PrimitiveView {
    var storage: AnyViewStorageBase
    // WIP
    public init<V>(_ view: V) where V : View {
        storage = .init(id: nil)
    }

    @_alwaysEmitIntoClient
    public init<V>(erasing view: V) where V : View {
        self.init(view)
    }

    // WIP
    public init?(_fromValue value: Any) {
        return nil
    }
//  public static func _makeView(view: _GraphValue<SwiftUI.AnyView>, inputs: _ViewInputs) -> _ViewOutputs
//  public static func _makeViewList(view: _GraphValue<AnyView>, inputs: _ViewListInputs) -> _ViewListOutputs

    // WIP
    init<V: View>(_ view: V, id: UniqueID?) {
        storage = .init(id: nil)
    }
}

@usableFromInline
class AnyViewStorageBase {
    let id: UniqueID?
    
    init(id: UniqueID?) {
        self.id = id
    }
    
    private var type: Any.Type { fatalError() }
    private var canTransition: Bool { fatalError() }
    private func matches(_ other: AnyViewStorageBase) -> Bool { fatalError() }
    private func makeChild(
        uniqueID: UInt32,
        container: Attribute<AnyViewInfo>,
        inputs: _ViewInputs
    ) { fatalError() }
    func child<Value>() -> Value { fatalError() }
    private func makeViewList(
        view: _GraphValue<AnyView>,
        inputs: _ViewListInputs
    ) -> _ViewListOutputs {
        fatalError()
    }
    private func visitContent<Vistor: ViewVisitor>(_ visitor: inout Vistor) {
        fatalError()
    }
}

private struct AnyViewInfo {
    var item: AnyViewStorageBase
    var subgraph: OGSubgraph
    var uniqueID: UInt32
}

private struct AnyViewContainer: StatefulRule, AsyncAttribute {
    @Attribute var view: Attribute<AnyView>
    let inputs: _ViewInputs
    let outputs: _ViewOutputs
    let parentSubgraph: OGSubgraph
    
    typealias Value = AnyViewInfo
    
    func updateValue() {
        
    }
}
