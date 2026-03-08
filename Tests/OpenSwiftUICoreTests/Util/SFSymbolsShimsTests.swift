//
//  SFSymbolsShimsTests.swift
//  OpenSwiftUICoreTests

#if canImport(Darwin)
import OpenSwiftUICore
import Testing

struct SFSymbolsShimsTests {
    @Test
    func symbolOrder() {
        let order = SFSymbols.symbol_order
        #expect(!order.isEmpty)
        #expect(order.contains("star"))
        #expect(order.contains("heart"))
    }

    @Test
    func privateSymbolOrder() {
        let order = SFSymbols.private_symbol_order
        #expect(!order.isEmpty)
    }

    @Test
    func nameAliases() {
        let aliases = SFSymbols.name_aliases
        #expect(!aliases.isEmpty)
    }

    @Test
    func privateNameAliases() {
        let aliases = SFSymbols.private_name_aliases
        #expect(!aliases.isEmpty)
    }

    @Test
    func nofillToFill() {
        let mapping = SFSymbols.nofill_to_fill
        #expect(!mapping.isEmpty)
    }

    @Test
    func privateNofillToFill() {
        let mapping = SFSymbols.private_nofill_to_fill
        #expect(!mapping.isEmpty)
    }
}
#endif
