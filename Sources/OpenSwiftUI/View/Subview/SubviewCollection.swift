//
//  SubviewCollection.swift
//  OpenSwiftUI
//
//  Audited for 6.5.4
//  Status: Complete

@_spi(ForOpenSwiftUIOnly) public import OpenSwiftUICore

// MARK: - Group + SubviewCollection

@_spi(DoNotImportVariadicView)
extension Group {
    @available(*, deprecated, message: "Use the public API instead.")
    @_disfavoredOverload
    public init<Base, Result>(
        elementsOf view: Base,
        @ViewBuilder transform: @escaping (SubviewCollection) -> Result
    ) where Content == GroupElementsOfContent<Base, Result>, Base: View, Result: View {
        self.init {
            GroupElementsOfContent(subviews: view) { subviews in
                transform(SubviewCollection(subviews))
            }
        }
    }
}

// MARK: - SubviewCollection

@_spi(DoNotImportVariadicView)
@available(*, deprecated, renamed: "SubviewsCollection")
public struct SubviewCollection: RandomAccessCollection {
    package var base: _VariadicView.Children

    @usableFromInline
    init(_ subviews: SubviewsCollection) {
        base = subviews.base
    }

    public subscript(index: Int) -> Subview {
        Subview(base[index])
    }

    public subscript(bounds: Range<Int>) -> Slice<SubviewCollection> {
        Slice(base: self, bounds: bounds)
    }

    public var startIndex: Int { base.startIndex }

    public var endIndex: Int { base.endIndex }

    public func selectedSubview<V>(selection: V) -> Subview? where V: Hashable {
        var start = 0
        var index = 0
        var selectedIndex: Int?
        base.list.applySublists(from: &start, list: nil) { sublist in
            if sublist.traits.tag(for: V.self) == selection,
               !sublist.traits.isAuxiliaryContent {
                selectedIndex = index
                return false
            }
            index &+= sublist.count
            return true
        }
        return selectedIndex.map { Subview(base[$0]) }
    }
}

@_spi(DoNotImportVariadicView)
@available(*, unavailable)
extension SubviewCollection: Sendable {}

@_spi(DoNotImportVariadicView)
@available(OpenSwiftUI_v6_0, *)
extension SubviewCollection: View, MultiView, PrimitiveView {
    public var body: some View {
        base
    }

    nonisolated public static func _makeViewList(
        view: _GraphValue<Self>,
        inputs: _ViewListInputs
    ) -> _ViewListOutputs {
        _VariadicView.Children._makeViewList(view: view[\.base], inputs: inputs)
    }

    nonisolated public static func _viewListCount(inputs: _ViewListCountInputs) -> Int? {
        _VariadicView.Children._viewListCount(inputs: inputs)
    }
}
