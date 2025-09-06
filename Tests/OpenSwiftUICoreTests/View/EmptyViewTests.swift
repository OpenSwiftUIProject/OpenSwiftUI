//
//  EmptyViewTests.swift
//  OpenSwiftUICoreTests

@_spi(ForOpenSwiftUIOnly)
import OpenSwiftUICore
import Testing

struct EmptyViewTests {
    @Test("Test EmptyView._viewListCount with various options")
    func viewListCount() {
        let base = _ViewListCountInputs(.init(.invalid))
        var inputs = base
        inputs.options = []
        #expect(EmptyView._viewListCount(inputs: inputs) == 0)

        inputs.options = [.isNonEmptyParent]
        #expect(EmptyView._viewListCount(inputs: inputs) == 1)
    }
}
